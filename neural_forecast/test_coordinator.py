import unittest
import pandas as pd
import numpy as np
from neural_coordinator import NeuralForecastCoordinator
import os
import shutil

class TestNeuralForecastCoordinator(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Create test directories
        for dir_name in ['temp', 'logs', 'models']:
            os.makedirs(dir_name, exist_ok=True)
        
        # Initialize coordinator
        cls.coordinator = NeuralForecastCoordinator()
        
        # Create sample data
        cls.sample_data = pd.DataFrame({
            'date': pd.date_range(start='2023-01-01', periods=100),
            'value': np.random.randn(100),
            'feature1': np.random.rand(100),
            'feature2': np.random.rand(100)
        })

    @classmethod
    def tearDownClass(cls):
        # Cleanup test directories
        for dir_name in ['temp', 'logs', 'models']:
            if os.path.exists(dir_name):
                shutil.rmtree(dir_name)

    def test_incredibuild_check(self):
        """Test IncrediBuild availability check"""
        result = self.coordinator.check_incredibuild()
        print(f"IncrediBuild available: {result}")
        # Note: Don't assert result since IncrediBuild might not be installed

    def test_model_training(self):
        """Test model training with IncrediBuild acceleration"""
        success = self.coordinator.train_model(
            'test_model',
            self.sample_data,
            'value',
            ['feature1', 'feature2']
        )
        self.assertTrue(success)

    def test_prediction(self):
        """Test model prediction"""
        # Train model first
        self.coordinator.train_model(
            'prediction_test_model',
            self.sample_data,
            'value',
            ['feature1', 'feature2']
        )
        
        # Make prediction
        new_data = pd.DataFrame({
            'feature1': [0.5],
            'feature2': [0.3]
        })
        prediction = self.coordinator.get_prediction('prediction_test_model', new_data)
        self.assertIsNotNone(prediction)

    def test_build_status(self):
        """Test build status tracking"""
        build_id = '123test'
        self.coordinator.builds_in_progress[build_id] = 'running'
        status = self.coordinator.get_build_status(build_id)
        self.assertEqual(status, 'running')

    def test_cleanup(self):
        """Test build cleanup"""
        build_id = '456test'
        
        # Create test files
        test_files = [
            f'temp/train_{build_id}.py',
            f'temp/data_{build_id}.csv',
            f'logs/build_{build_id}.log'
        ]
        
        for file in test_files:
            os.makedirs(os.path.dirname(file), exist_ok=True)
            with open(file, 'w') as f:
                f.write('test')
        
        self.coordinator.cleanup_build(build_id)
        
        # Check files are removed
        for file in test_files:
            self.assertFalse(os.path.exists(file))

    def test_model_caching(self):
        """Test model caching functionality"""
        model_name = 'cache_test_model'
        
        # Train model
        self.coordinator.train_model(
            model_name,
            self.sample_data,
            'value',
            ['feature1', 'feature2']
        )
        
        # Check model is in cache
        self.assertIn(model_name, self.coordinator.model_cache)

    def test_config_loading(self):
        """Test configuration loading"""
        self.assertIsNotNone(self.coordinator.config)
        self.assertIn('incredibuild', self.coordinator.config)
        self.assertIn('mindsdb', self.coordinator.config)

if __name__ == '__main__':
    unittest.main()