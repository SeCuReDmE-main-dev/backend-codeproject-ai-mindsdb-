from flask import Flask, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os
from sqlalchemy.exc import SQLAlchemyError

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mindsdb_server.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

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
def get_models():
    try:
        models = Model.query.all()
        return jsonify([model.to_dict() for model in models])
    except SQLAlchemyError as e:
        return jsonify({'error': str(e)}), 500

@app.route('/models', methods=['POST'])
def add_model():
    try:
        data = request.get_json()
        if not data or 'name' not in data or 'description' not in data:
            return jsonify({'error': 'Missing required fields'}), 400

        new_model = Model(name=data['name'], description=data['description'])
        db.session.add(new_model)
        db.session.commit()
        return jsonify({'message': 'Model added successfully', 'model': new_model.to_dict()}), 201
    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    with app.app_context():
        if not os.path.exists('mindsdb_server.db'):
            db.create_all()
        app.run(host='0.0.0.0', port=5001)
