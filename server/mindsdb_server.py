from flask import Flask, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os
from sqlalchemy.exc import SQLAlchemyError
from functools import wraps

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mindsdb_server.db'
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
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(200), nullable=False

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description
        }

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
        
    db.session.commit()
    return jsonify({'message': 'Model updated successfully', 'model': model.to_dict()})

@app.route('/models/<int:model_id>', methods=['DELETE'])
@handle_errors
def delete_model(model_id):
    model = Model.query.get_or_404(model_id)
    db.session.delete(model)
    db.session.commit()
    return jsonify({'message': 'Model deleted successfully'})

if __name__ == '__main__':
    with app.app_context():
        if not os.path.exists('mindsdb_server.db'):
            db.create_all()
        app.run(host='0.0.0.0', port=5001)
