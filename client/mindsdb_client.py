import requests
from typing import Dict, List, Optional
import json

class MindsDBClient:
    def __init__(self, base_url: str = "http://localhost:5001"):
        self.base_url = base_url.rstrip('/')
        
    def get_models(self) -> List[Dict]:
        """Get all models from the server."""
        try:
            response = requests.get(f"{self.base_url}/models")
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching models: {e}")
            return []

    def add_model(self, name: str, description: str) -> Optional[Dict]:
        """Add a new model to the server."""
        try:
            data = {"name": name, "description": description}
            response = requests.post(
                f"{self.base_url}/models",
                json=data,
                headers={"Content-Type": "application/json"}
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error adding model: {e}")
            return None

    def get_model(self, model_id: int) -> Optional[Dict]:
        """Get a specific model by ID."""
        try:
            response = requests.get(f"{self.base_url}/models/{model_id}")
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching model {model_id}: {e}")
            return None

    def update_model(self, model_id: int, name: Optional[str] = None, description: Optional[str] = None) -> Optional[Dict]:
        """Update an existing model."""
        try:
            data = {}
            if name is not None:
                data['name'] = name
            if description is not None:
                data['description'] = description

            response = requests.put(
                f"{self.base_url}/models/{model_id}",
                json=data,
                headers={"Content-Type": "application/json"}
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error updating model {model_id}: {e}")
            return None

    def delete_model(self, model_id: int) -> bool:
        """Delete a model by ID."""
        try:
            response = requests.delete(f"{self.base_url}/models/{model_id}")
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            print(f"Error deleting model {model_id}: {e}")
            return False

def main():
    client = MindsDBClient()
    
    # Example usage of new methods
    model = client.add_model("TestModel", "A test model")
    if model:
        model_id = model['model']['id']
        
        # Get the model
        print("Getting model:", client.get_model(model_id))
        
        # Update the model
        print("Updating model:", client.update_model(model_id, description="Updated description"))
        
        # Delete the model
        print("Deleting model:", client.delete_model(model_id))

if __name__ == "__main__":
    main()
