# CodeProject.AI and MindsDB Integration

This directory contains the integration between CodeProject.AI Server and MindsDB, creating a powerful AI processing pipeline with advanced machine learning capabilities.

## Directory Structure

- **CodeProject.AI-Server/**: The main CodeProject.AI Server implementation
- **CodeProject.AI-Modules/**: Various AI processing modules
- **server/**: Custom server components for the integration, including database setup

## Setup Instructions

### Prerequisites

- Python 3.10 or later
- PostgreSQL database
- .NET Runtime for CodeProject.AI Server

### Database Setup

1. Install required Python packages:
   ```
   pip install sqlalchemy psycopg2-binary
   ```

2. Configure the PostgreSQL database:
   - Server: localhost
   - Database name: Neural_Network
   - Port: 5432
   - Username: [your_username]

3. Run the database setup script:
   ```
   python server/database_setup.py
   ```
   This will create the necessary tables including the `ai_models` table.

### Starting the Server

1. Navigate to the CodeProject.AI Server directory:
   ```
   cd CodeProject.AI-Server
   ```

2. Start the server:
   - On Windows: `start.bat`
   - On Linux/macOS: `./start.sh`

## Using Custom Modules

### Available Custom Modules

- **EbaAaZ_module**: Custom AI processing module
- **CeLeBrUm_module**: Neural network processing module
- **SenNnT-i_module**: Specialized AI module
- **NeuUuR-o**: TensorZero middleware (under development)

### Accessing Module APIs

1. EbaAaZ Module:
   - Endpoint: `http://localhost:32168/custom/ebaaz-process`
   - Method: POST
   - Request body:
     ```json
     {
       "input_data": "Your input data here"
     }
     ```

2. CeLeBrUm Module:
   - Endpoint: `http://localhost:32168/neural/cerebrum-process`
   - Method: POST
   - Request body:
     ```json
     {
       "input_data": "Your input data here",
       "parameters": "{\"param_name\": \"param_value\"}"
     }
     ```

## Mesh Network

The CodeProject.AI Server mesh network allows modules to communicate with each other and distribute the workload across multiple servers. The custom modules are configured to participate in the mesh network.

To enable a module for mesh networking:
- Ensure the `MeshEnabled` property is set to `true` in the module's `modulesettings.json` file
- Use the appropriate endpoints to communicate with the modules

## Testing

To verify that the integration is working correctly:

1. Check the database connection:
   ```python
   python -c "from test_app import test_database; print(test_database())"
   ```

2. Test the CodeProject.AI Server:
   ```python
   python -c "from test_app import test_codeproject_ai; print(test_codeproject_ai())"
   ```

3. Test the MindsDB connection:
   ```python
   python -c "from test_app import test_mindsdb; print(test_mindsdb())"
   ```

## Troubleshooting

- If you encounter a "no such table: ai_models" error, run the database setup script to create the missing table.
- For connection issues, check that the server is running and accessible at the expected address and port.
- For module-related issues, verify that the module's adapter script is correctly configured and the required dependencies are installed.

## License

This integration is licensed under the MIT License.
