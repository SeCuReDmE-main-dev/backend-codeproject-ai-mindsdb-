import os
import json
import logging
from datetime import datetime
import subprocess
import mindsdb_sdk
from typing import Dict, List, Optional, Union
import pandas as pd
import numpy as np

class NeuralForecastCoordinator:
    def __init__(self, config_path: str = None):
        self.logger = self._setup_logging()
        self.config = self._load_config(config_path)
        self.mindsdb = self._connect_mindsdb()
        self.builds_in_progress: Dict[str, str] = {}
        self.model_cache: Dict[str, object] = {}
        
    def _setup_logging(self) -> logging.Logger:
        logger = logging.getLogger("NeuralForecastCoordinator")
        logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def _load_config(self, config_path: str) -> dict:
        if not config_path:
            config_path = os.path.join(os.path.dirname(__file__), 'coordinator_config.json')
        
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            self.logger.warning(f"Config not found at {config_path}, using defaults")
            return {
                'incredibuild': {
                    'enabled': True,
                    'max_cpus': 16,
                    'build_timeout': 3600
                },
                'mindsdb': {
                    'host': 'localhost',
                    'port': 47334
                },
                'model_cache_size': 10
            }

    def _connect_mindsdb(self) -> Optional[mindsdb_sdk.connect]:
        try:
            server = mindsdb_sdk.connect(
                host=self.config['mindsdb']['host'],
                port=self.config['mindsdb']['port']
            )
            self.logger.info("Connected to MindsDB successfully")
            return server
        except Exception as e:
            self.logger.error(f"Failed to connect to MindsDB: {e}")
            return None

    def check_incredibuild(self) -> bool:
        try:
            result = subprocess.run(['BuildConsole', '--version'], 
                                 capture_output=True, 
                                 text=True)
            return result.returncode == 0
        except FileNotFoundError:
            return False

    def accelerate_build(self, build_command: str, build_id: str) -> bool:
        if not self.check_incredibuild():
            self.logger.warning("IncrediBuild not available, running build normally")
            try:
                subprocess.run(build_command, shell=True, check=True)
                return True
            except subprocess.CalledProcessError as e:
                self.logger.error(f"Build failed: {e}")
                return False

        try:
            command = [
                'BuildConsole',
                build_command,
                f'/cfg="{self.config["incredibuild"]["build_config"]}"',
                f'/out="{os.path.join("logs", f"build_{build_id}.log")}"',
                f'/MaxCPUs={self.config["incredibuild"]["max_cpus"]}',
                '/ShowTime'
            ]
            
            self.builds_in_progress[build_id] = 'running'
            result = subprocess.run(command, capture_output=True, text=True)
            
            if result.returncode == 0:
                self.builds_in_progress[build_id] = 'completed'
                return True
            else:
                self.builds_in_progress[build_id] = 'failed'
                self.logger.error(f"Build failed: {result.stderr}")
                return False
                
        except Exception as e:
            self.builds_in_progress[build_id] = 'failed'
            self.logger.error(f"Build process failed: {e}")
            return False

    def train_model(self, model_name: str, data: pd.DataFrame, target_column: str,
                   features: List[str], build_id: str = None) -> bool:
        if not self.mindsdb:
            self.logger.error("MindsDB connection not available")
            return False

        if not build_id:
            build_id = datetime.now().strftime('%Y%m%d_%H%M%S')

        try:
            project = self.mindsdb.get_project('mindsdb')
            
            # Prepare build command for model training
            build_command = self._prepare_training_command(
                model_name, data, target_column, features
            )
            
            # Accelerate the build using IncrediBuild
            success = self.accelerate_build(build_command, build_id)
            if not success:
                return False

            # Create and train the model
            model = project.models.create(
                name=model_name,
                predict=target_column,
                data=data
            )
            
            # Cache the model
            self.model_cache[model_name] = model
            
            # Cleanup old cache entries if needed
            if len(self.model_cache) > self.config['model_cache_size']:
                oldest_model = next(iter(self.model_cache))
                del self.model_cache[oldest_model]
            
            return True

        except Exception as e:
            self.logger.error(f"Model training failed: {e}")
            return False

    def _prepare_training_command(self, model_name: str, data: pd.DataFrame,
                                target_column: str, features: List[str]) -> str:
        # Create a temporary script for model training
        script_path = os.path.join('temp', f'train_{model_name}.py')
        os.makedirs('temp', exist_ok=True)
        
        with open(script_path, 'w') as f:
            f.write(f'''
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, LSTM
from tensorflow.keras.optimizers import Adam

# Load data
data = pd.read_csv('temp/data_{model_name}.csv')
X = data[{features}]
y = data['{target_column}']

# Preprocessing
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Model architecture
model = Sequential([
    Dense(128, activation='relu', input_shape=(len({features}),)),
    Dense(64, activation='relu'),
    Dense(32, activation='relu'),
    Dense(1)
])

model.compile(optimizer=Adam(learning_rate=0.001),
             loss='mse',
             metrics=['mae'])

# Training
model.fit(X_scaled, y, 
          epochs=100,
          batch_size=32,
          validation_split=0.2,
          verbose=1)

# Save model
model.save('models/{model_name}.h5')
''')
        
        # Save data temporarily
        data.to_csv(f'temp/data_{model_name}.csv', index=False)
        
        return f'python {script_path}'

    def get_prediction(self, model_name: str, input_data: Union[Dict, pd.DataFrame]) -> Optional[np.ndarray]:
        try:
            # Try to get model from cache first
            model = self.model_cache.get(model_name)
            
            # If not in cache, load from MindsDB
            if not model:
                project = self.mindsdb.get_project('mindsdb')
                model = project.models.get(model_name)
                self.model_cache[model_name] = model
            
            # Make prediction
            prediction = model.predict(input_data)
            return prediction
            
        except Exception as e:
            self.logger.error(f"Prediction failed: {e}")
            return None

    def get_build_status(self, build_id: str) -> str:
        return self.builds_in_progress.get(build_id, 'not_found')

    def cleanup_build(self, build_id: str):
        if build_id in self.builds_in_progress:
            del self.builds_in_progress[build_id]
        
        # Cleanup temporary files
        temp_files = [
            f'temp/train_{build_id}.py',
            f'temp/data_{build_id}.csv',
            f'logs/build_{build_id}.log'
        ]
        
        for file in temp_files:
            try:
                if os.path.exists(file):
                    os.remove(file)
            except Exception as e:
                self.logger.warning(f"Failed to cleanup {file}: {e}")

if __name__ == "__main__":
    # Example usage
    coordinator = NeuralForecastCoordinator()
    
    # Test IncrediBuild availability
    if coordinator.check_incredibuild():
        print("IncrediBuild is available for build acceleration")
    else:
        print("IncrediBuild is not available, builds will run normally")
    
    # Create sample data
    sample_data = pd.DataFrame({
        'date': pd.date_range(start='2023-01-01', periods=100),
        'value': np.random.randn(100),
        'feature1': np.random.rand(100),
        'feature2': np.random.rand(100)
    })
    
    # Train a model
    success = coordinator.train_model(
        'test_model',
        sample_data,
        'value',
        ['feature1', 'feature2']
    )
    
    if success:
        # Make a prediction
        new_data = pd.DataFrame({
            'feature1': [0.5],
            'feature2': [0.3]
        })
        prediction = coordinator.get_prediction('test_model', new_data)
        print(f"Prediction: {prediction}")