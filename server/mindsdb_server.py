import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mindsdb_server.db'
db = SQLAlchemy(app)

class MindsDBModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(200), nullable=False)

@app.route('/mindsdb_models', methods=['GET'])
def get_mindsdb_models():
    models = MindsDBModel.query.all()
    return jsonify([{'id': model.id, 'name': model.name, 'description': model.description} for model in models])

@app.route('/mindsdb_models', methods=['POST'])
def add_mindsdb_model():
    data = request.get_json()
    new_model = MindsDBModel(name=data['name'], description=data['description'])
    db.session.add(new_model)
    db.session.commit()
    return jsonify({'message': 'MindsDB model added successfully'}), 201

if __name__ == '__main__':
    if not os.path.exists('mindsdb_server.db'):
        db.create_all()
    app.run(host='0.0.0.0', port=5001)
