from flask import Flask, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mindsdb_server.db'
db = SQLAlchemy(app)

class Model(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(200), nullable=False)

@app.route('/')
def home():
    return redirect(url_for('get_models'))

@app.route('/models', methods=['GET'])
def get_models():
    models = Model.query.all()
    return jsonify([{'id': model.id, 'name': model.name, 'description': model.description} for model in models])

@app.route('/models', methods=['POST'])
def add_model():
    data = request.get_json()
    new_model = Model(name=data['name'], description=data['description'])
    db.session.add(new_model)
    db.session.commit()
    return jsonify({'message': 'Model added successfully'}), 201

if __name__ == '__main__':
    with app.app_context():
        if not os.path.exists('mindsdb_server.db'):
            db.create_all()
        app.run(host='0.0.0.0', port=5001)
