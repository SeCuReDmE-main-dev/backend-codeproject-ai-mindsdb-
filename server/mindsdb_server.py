from flask import Flask, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os
from sqlalchemy.exc import SQLAlchemyError
from functools import wraps
import json
import mindsdb_sdk
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///shared_central_database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

def handle_errors(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except SQLAlchemyError as e:
            db.session.rollback()
            return jsonify({'error': str(e)}), 500
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    return wrapper

class Model(db.Model):
    __tablename__ = 'ai_models'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(200), nullable=False)
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())
    predictions = db.relationship('Prediction', backref='model', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Prediction(db.Model):
    __tablename__ = 'predictions'
    id = db.Column(db.Integer, primary_key=True)
    model_id = db.Column(db.Integer, db.ForeignKey('ai_models.id'), nullable=False)
    input_data = db.Column(db.Text, nullable=False)
    output_data = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, server_default=db.func.now())

    def to_dict(self):
        return {
            'id': self.id,
            'model_id': self.model_id,
            'input_data': json.loads(self.input_data),
            'output_data': json.loads(self.output_data),
            'timestamp': self.timestamp.isoformat() if self.timestamp else None
        }

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/')
def home():
    return redirect(url_for('get_models'))

@app.route('/models', methods=['GET'])
@handle_errors
def get_models():
    models = Model.query.all()
    return jsonify([model.to_dict() for model in models])

@app.route('/models', methods=['POST'])
@handle_errors
def add_model():
    data = request.get_json()
    if not data or 'name' not in data or 'description' not in data:
        return jsonify({'error': 'Missing required fields'}), 400

    new_model = Model(name=data['name'], description=data['description'])
    db.session.add(new_model)
    db.session.commit()
    return jsonify({'message': 'Model added successfully', 'model': new_model.to_dict()}), 201

@app.route('/models/<int:model_id>', methods=['GET'])
@handle_errors
def get_model(model_id):
    model = Model.query.get_or_404(model_id)
    return jsonify(model.to_dict())

@app.route('/models/<int:model_id>', methods=['PUT'])
@handle_errors
def update_model(model_id):
    model = Model.query.get_or_404(model_id)
    data = request.get_json()
    
    if 'name' in data:
        model.name = data['name']
    if 'description' in data:
        model.description = data['description']
    if 'status' in data:
        model.status = data['status']
        
    model.updated_at = datetime.utcnow()
    db.session.commit()
    return jsonify({'message': 'Model updated successfully', 'model': model.to_dict()})

@app.route('/models/<int:model_id>', methods=['DELETE'])
@handle_errors
def delete_model(model_id):
    model = Model.query.get_or_404(model_id)
    db.session.delete(model)
    db.session.commit()
    return jsonify({'message': 'Model deleted successfully'})

@app.route('/models/<int:model_id>/predict', methods=['POST'])
@handle_errors
def make_prediction(model_id):
    model = Model.query.get_or_404(model_id)
    data = request.get_json()
    
    if not data or 'input_data' not in data:
        return jsonify({'error': 'Missing input_data'}), 400
    
    try:
        # Initialize MindsDB connection
        server = mindsdb_sdk.connect()
        
        # Get the project and model
        project = server.get_project('mindsdb')
        mindsdb_model = project.get_model(model.name)
        
        # Make prediction using MindsDB
        prediction_result = mindsdb_model.predict(data['input_data'])
        
        # Store prediction in database
        prediction = Prediction(
            model_id=model.id,
            input_data=json.dumps(data['input_data']),
            output_data=json.dumps(prediction_result)
        )
        
        db.session.add(prediction)
        db.session.commit()
        
        return jsonify({
            'message': 'Prediction made successfully',
            'prediction': prediction.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({'error': f'Prediction failed: {str(e)}'}), 500

if __name__ == '__main__':
    with app.app_context():
        if not os.path.exists('shared_central_database.db'):
            db.create_all()
        app.run(host='0.0.0.0', port=5002)

import os
import sys
import json
import logging
import mindsdb
from mindsdb.api.http.start import start as start_mindsdb
from logging.handlers import RotatingFileHandler

# Setup logging
logger = logging.getLogger("mindsdb_server")
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Console handler
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# File handler with rotation
file_handler = RotatingFileHandler('mindsdb_server.log', maxBytes=10485760, backupCount=5)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

class MindsDBServer:
    def __init__(self, config_path=None):
        self.config = self._load_config(config_path)
        self.mindsdb_config = self._load_mindsdb_config()
        self.federation_config = self._load_federation_config()
        
    def _load_config(self, config_path):
        """Load main application config"""
        if config_path is None:
            config_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'config.json')
        
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.error(f"Config file not found: {config_path}")
            return {
                "mindsdb_server": {
                    "host": "localhost",
                    "port": 47335
                }
            }
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON in config file: {config_path}")
            return {
                "mindsdb_server": {
                    "host": "localhost",
                    "port": 47335
                }
            }
    
    def _load_mindsdb_config(self):
        """Load MindsDB configuration"""
        mindsdb_config_path = os.path.join(os.path.dirname(__file__), 'mindsdb.json')
        try:
            with open(mindsdb_config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.warning(f"MindsDB config file not found: {mindsdb_config_path}. Using default settings.")
            return None
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON in MindsDB config file: {mindsdb_config_path}")
            return None
    
    def _load_federation_config(self):
        """Load federation configuration"""
        federation_config_path = os.path.join(os.path.dirname(__file__), 'federation_config.json')
        try:
            with open(federation_config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.warning(f"Federation config file not found: {federation_config_path}. Using default settings.")
            return None
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON in federation config file: {federation_config_path}")
            return None
    
    def start(self):
        """Start the MindsDB server"""
        logger.info("Starting MindsDB server...")
        
        try:
            # Configure MindsDB with our settings
            if self.mindsdb_config:
                mindsdb_config_dir = os.path.dirname(__file__)
                os.environ['MINDSDB_CONFIG_PATH'] = mindsdb_config_dir
                logger.info(f"Using MindsDB config from: {mindsdb_config_dir}")
            
            # Start MindsDB server
            mindsdb_port = self.config["mindsdb_server"]["port"]
            mindsdb_host = self.config["mindsdb_server"]["host"]
            logger.info(f"Starting MindsDB on {mindsdb_host}:{mindsdb_port}")
            
            # Start MindsDB HTTP API server
            start_mindsdb(verbose=False, api_host=mindsdb_host, api_port=mindsdb_port)
            
            logger.info("MindsDB server started successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to start MindsDB server: {str(e)}")
            return False

if __name__ == "__main__":
    server = MindsDBServer()
    server.start()
