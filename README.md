# Mini App with CodeProject AI Server and MindsDB

## Description

This project is a mini app built using the duo server side CodeProject AI server and MindsDB. The app intertwines the capabilities of both tools through their REST APIs to ensure constant communication between the backend and frontend. The app also utilizes persistent outside storage to hold databases categorized by coding language: Python, JavaScript, and other languages like Make/Go, bakefiles, .yml, .yaml.

## Installation Instructions

### Prerequisites

- Python 3.8 or higher
- Flask

### Setting up the CodeProject AI Server

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/mini-app-codeproject-ai-mindsdb.git
   ```

2. Navigate to the `server` directory:

   ```bash
   cd server
   ```

3. Install the required dependencies:

   ```bash
   pip install -r requirements.txt
   ```

4. Run the CodeProject AI server:

   ```bash
   python codeproject_ai_server.py
   ```

### Setting up the MindsDB Server

1. Navigate to the `server` directory:

   ```bash
   cd server
   ```

2. Install the required dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Run the MindsDB server:

   ```bash
   python mindsdb_server.py
   ```

   Note: MindsDB server should be configured to use port 5001 instead of the default 47337.

### Setting up the Shared Central Database

1. Navigate to the `server` directory:

   ```bash
   cd server
   ```

2. Run the database setup script:

   ```bash
   python database_setup.py
   ```

   This script will create the necessary database tables including `ai_models` which is required for the application.

### Setting up a Conda Environment

1. Create a conda environment:

   ```bash
   conda create --name myenv python=3.8
   ```

2. Activate the conda environment:

   ```bash
   conda activate myenv
   ```

3. Install the required dependencies using `pip` within the conda environment:

   ```bash
   pip install -r server/requirements.txt
   pip install -r client/requirements.txt
   ```

## Usage Instructions

1. Start the CodeProject AI server and MindsDB server as described in the installation instructions.

2. Navigate to the `client` directory:

   ```bash
   cd client
   ```

3. Install the required dependencies:

   ```bash
   pip install -r requirements.txt
   ```

4. Open `index.html` in a web browser to access the client-side interface.

5. Use the client-side interface to interact with the mini app, which will communicate with the backend servers and the shared central database.

## Troubleshooting

### Python Installation Issues
If you encounter Python installation issues in MSYS2 or similar environments, consider:

1. Using a virtual environment:
   ```bash
   python -m venv path/to/venv
   path/to/venv/bin/pip install -r requirements.txt
   ```

2. Using `pipx` for application installations:
   ```bash
   pacman -S $MINGW_PACKAGE_PREFIX-python-pipx
   pipx install package_name
   ```

### MindsDB Connection Issues
- If you encounter "No connection could be made" errors with port 47337, make sure MindsDB is properly configured to use port 5001 as specified in the server configuration.
- Verify that all services are running before attempting connections.
- Check for any firewall rules that might be blocking the required ports.

### Database Issues
- If you encounter errors like `no such table: ai_models`, run the database setup script:
  ```bash
  python server/database_setup.py
  ```
- Make sure you have write permissions to the database directory.
- If the error persists, try removing the existing database file and running the setup script again:
  ```bash
  rm server/database/app.db
  python server/database_setup.py
  ```

## Contributing Guidelines

We welcome contributions to this project. To contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with a clear message.
4. Push your changes to your fork.
5. Create a pull request to the main repository.

## License Information

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Contact Information

For any questions or inquiries, please contact us at [email@example.com].
