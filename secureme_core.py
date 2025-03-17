#!/usr/bin/env python
"""
SeCuReDmE Core Management System
This script serves as the central management system for all AI components in the SeCuReDmE project.
It handles module registration, initialization, and provides a unified API.
"""

import os
import sys
import json
import time
import logging
import subprocess
import argparse
import platform
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(), logging.FileHandler("secureme_core.log")]
)
logger = logging.getLogger("SeCuReDmE Core")

class SeCuReDmECore:
    def __init__(self, config_path="config.json"):
        self.base_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = self.base_dir / config_path
        self.config = self._load_config()
        self.processes = {}

    def _load_config(self):
        """Load configuration from JSON file"""
        try:
            with open(self.config_path, 'r') as f:
                config = json.load(f)
                logger.info(f"Configuration loaded from {self.config_path}")
                return config
        except Exception as e:
            logger.error(f"Failed to load configuration: {e}")
            sys.exit(1)

    def _save_config(self):
        """Save configuration to JSON file"""
        try:
            with open(self.config_path, 'w') as f:
                json.dump(self.config, f, indent=2)
                logger.info(f"Configuration saved to {self.config_path}")
        except Exception as e:
            logger.error(f"Failed to save configuration: {e}")

    def start_service(self, service_type, service_name):
        """Start a specified service (server or module)"""
        if service_type == "server":
            if service_name == "codeproject_ai":
                return self._start_codeproject_ai()
            elif service_name == "mindsdb":
                return self._start_mindsdb()
        elif service_type == "module":
            return self._start_module(service_name)
        
        logger.error(f"Unknown service: {service_type}/{service_name}")
        return False

    def _start_codeproject_ai(self):
        """Start the CodeProject AI Server"""
        server_dir = self.base_dir / "CodeProject.AI-Server"
        if not server_dir.exists():
            logger.error(f"CodeProject AI Server directory not found: {server_dir}")
            return False
        
        logger.info("Starting CodeProject AI Server...")
        cmd = ["python", "src/server/server.py"]
        
        try:
            process = self._run_command(cmd, server_dir)
            self.processes["codeproject_ai"] = process
            logger.info("CodeProject AI Server started")
            return True
        except Exception as e:
            logger.error(f"Failed to start CodeProject AI Server: {e}")
            return False

    def _start_mindsdb(self):
        """Start the MindsDB Server"""
        mindsdb_dir = self.base_dir / "MindsDB"
        if not mindsdb_dir.exists():
            logger.error(f"MindsDB directory not found: {mindsdb_dir}")
            return False
        
        logger.info("Starting MindsDB Server...")
        cmd = ["python", "-m", "mindsdb"]
        
        try:
            process = self._run_command(cmd, mindsdb_dir)
            self.processes["mindsdb"] = process
            logger.info("MindsDB Server started")
            return True
        except Exception as e:
            logger.error(f"Failed to start MindsDB Server: {e}")
            return False

    def _start_module(self, module_name):
        """Start a specific module"""
        if module_name not in self.config["modules"]:
            logger.error(f"Module {module_name} not found in configuration")
            return False
        
        module_config = self.config["modules"][module_name]
        if not module_config.get("enabled", False):
            logger.warning(f"Module {module_name} is disabled")
            return False
        
        module_path = self.base_dir / module_config["path"]
        if not module_path.exists():
            logger.error(f"Module path not found: {module_path}")
            return False
        
        logger.info(f"Starting module: {module_name}...")
        
        # Check if it's a .NET module
        if (module_path / f"{module_name}.csproj").exists():
            cmd = ["dotnet", "run"]
        # Check if it's a Python module
        elif (module_path / "__init__.py").exists() or (module_path / f"{module_name}.py").exists():
            cmd = ["python", "-m", module_name] 
        else:
            logger.error(f"Unknown module type for {module_name}")
            return False
        
        try:
            process = self._run_command(cmd, module_path)
            self.processes[module_name] = process
            logger.info(f"Module {module_name} started")
            return True
        except Exception as e:
            logger.error(f"Failed to start module {module_name}: {e}")
            return False

    def _run_command(self, cmd, cwd):
        """Run a command in a separate process"""
        is_windows = platform.system() == "Windows"
        
        if is_windows:
            # For Windows, use CREATE_NEW_CONSOLE to create a new window
            process = subprocess.Popen(
                cmd, 
                cwd=str(cwd),
                creationflags=subprocess.CREATE_NEW_CONSOLE
            )
        else:
            # For non-Windows platforms
            terminal_cmd = ["gnome-terminal", "--", "bash", "-c", " ".join(cmd) + "; exec bash"]
            process = subprocess.Popen(terminal_cmd, cwd=str(cwd))
        
        return process

    def start_all(self):
        """Start all enabled components"""
        # Start servers first
        logger.info("Starting all servers...")
        self._start_codeproject_ai()
        time.sleep(5)  # Give the CodeProject AI server time to start
        
        self._start_mindsdb()
        time.sleep(5)  # Give the MindsDB server time to start
        
        # Then start modules
        logger.info("Starting all enabled modules...")
        for module_name, module_config in self.config["modules"].items():
            if module_config.get("enabled", False):
                self._start_module(module_name)
                time.sleep(2)  # Small delay between module starts
        
        logger.info("All components started")

        # Start the new AI model
        if "new_ai_model" in self.config["models"]:
            self._start_module("new_ai_model")
            logger.info("New AI model started")

    def register_module(self, module_name, module_path, description="", dependencies=None):
        """Register a new module in the system"""
        if dependencies is None:
            dependencies = []
        
        if module_name in self.config["modules"]:
            logger.warning(f"Module {module_name} already exists, updating configuration")
        
        # Create module configuration
        self.config["modules"][module_name] = {
            "enabled": True,
            "description": description,
            "path": str(module_path),
            "dependencies": dependencies
        }
        
        # Save updated configuration
        self._save_config()
        logger.info(f"Module {module_name} registered successfully")
        
        # Check if the module path exists, if not create it
        module_full_path = self.base_dir / module_path
        if not module_full_path.exists():
            os.makedirs(module_full_path, exist_ok=True)
            logger.info(f"Created module directory: {module_full_path}")
        
        return True

    def unregister_module(self, module_name):
        """Unregister a module from the system"""
        if module_name not in self.config["modules"]:
            logger.warning(f"Module {module_name} not found")
            return False
        
        # Remove the module from configuration
        del self.config["modules"][module_name]
        
        # Save updated configuration
        self._save_config()
        logger.info(f"Module {module_name} unregistered successfully")
        return True

    def create_dotnet_module(self, module_name, description=""):
        """Create a new .NET module with template code"""
        module_path = f"CodeProject.AI-Modules/CodeProject.AI-{module_name}"
        
        # Register the module
        self.register_module(
            module_name, 
            module_path,
            description,
            ["codeproject_ai"]
        )
        
        # Create directory and project file
        full_path = self.base_dir / module_path
        os.makedirs(full_path, exist_ok=True)
        
        # Create .csproj file
        proj_file = full_path / f"{module_name}.csproj"
        with open(proj_file, 'w') as f:
            f.write(f"""<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
""")
        
        # Create Program.cs file
        program_file = full_path / "Program.cs"
        with open(program_file, 'w') as f:
            f.write(f"""using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace {module_name}
{{
    class Program
    {{
        private static readonly HttpClient client = new HttpClient();
        private static readonly string codeProjectApiUrl = "http://localhost:32168/v1";

        static async Task Main(string[] args)
        {{
            Console.WriteLine("Starting {module_name} Module");
            Console.WriteLine("This is a SeCuReDmE AI module");

            // TODO: Implement module functionality
            
            while (true)
            {{
                Console.WriteLine("\\nPress 'Q' to exit or any other key to continue...");
                var key = Console.ReadKey(true).Key;
                if (key == ConsoleKey.Q)
                    break;
                    
                // Your module's main loop code here
                Console.WriteLine("Processing...");
            }}
        }}
    }}
}}
""")
        
        logger.info(f"Created .NET module {module_name} at {full_path}")
        return True

    def create_python_module(self, module_name, description=""):
        """Create a new Python module with template code"""
        module_path = f"CodeProject.AI-Server/modules/{module_name}"
        
        # Register the module
        self.register_module(
            module_name, 
            module_path,
            description,
            ["codeproject_ai"]
        )
        
        # Create directory and Python files
        full_path = self.base_dir / module_path
        os.makedirs(full_path, exist_ok=True)
        
        # Create __init__.py
        init_file = full_path / "__init__.py"
        with open(init_file, 'w') as f:
            f.write(f"""# {module_name} module for SeCuReDmE project
""")
        
        # Create main module file
        main_file = full_path / f"{module_name}.py"
        with open(main_file, 'w') as f:
            f.write(f"""#!/usr/bin/env python
\"\"\"{module_name} - A SeCuReDmE AI Module
This module connects to the CodeProject AI Server and MindsDB.
\"\"\"

import os
import sys
import json
import time
import requests

# Try to import CodeProject AI SDK
try:
    from codeproject_ai_sdk import ModuleRunner, LogMethod
except ImportError:
    print("CodeProject AI SDK not found. Please install it or add it to the Python path.")
    sys.exit(1)

class {module_name.capitalize()}Module:
    def __init__(self):
        self.module_name = "{module_name}"
        self.module_id = "{module_name.lower()}"
        self.module_runner = ModuleRunner(self.module_id)
        
    def start(self):
        \"\"\"Start the module\"\"\"
        print(f"Starting {{self.module_name}} Module...")
        
        # Register with CodeProject AI Server
        self.module_runner.register_callbacks(
            self.process_request, self.status_check, self.get_capabilities
        )
        
        # Start the module runner
        self.module_runner.start()
        
    def process_request(self, data):
        \"\"\"Process incoming requests\"\"\"
        try:
            print(f"Processing request: {{data}}")
            
            # TODO: Implement your module logic here
            
            # Return a sample response
            return {{
                "module": self.module_name,
                "success": True,
                "message": "Request processed successfully",
                "data": {{}}
            }}
            
        except Exception as ex:
            print(f"Error processing request: {{ex}}")
            return {{
                "success": False,
                "error": str(ex)
            }}
    
    def status_check(self, data):
        \"\"\"Return the status of this module\"\"\"
        return {{
            "module": self.module_name,
            "status": "Running"
        }}
    
    def get_capabilities(self, data):
        \"\"\"Return the capabilities of this module\"\"\"
        return {{
            "capabilities": [
                # TODO: List module capabilities
            ]
        }}

if __name__ == "__main__":
    module = {module_name.capitalize()}Module()
    module.start()
""")
        
        # Create install.bat and install.sh
        install_bat = full_path / "install.bat"
        with open(install_bat, 'w') as f:
            f.write(f"""@echo off
echo Installing {module_name} module...
pip install -r requirements.txt
echo Installation complete
""")
        
        install_sh = full_path / "install.sh"
        with open(install_sh, 'w') as f:
            f.write(f"""#!/bin/bash
echo "Installing {module_name} module..."
pip install -r requirements.txt
echo "Installation complete"
""")
        os.chmod(install_sh, 0o755)  # Make the script executable
        
        # Create requirements.txt
        req_file = full_path / "requirements.txt"
        with open(req_file, 'w') as f:
            f.write("""requests>=2.28.0
""")
        
        # Create module settings
        settings_file = full_path / "modulesettings.json"
        with open(settings_file, 'w') as f:
            f.write(f"""{{
  "Enabled": true,
  "Arguments": {{
    "defaults": {{
      "ModelPath": "{{InternalModelsPath}}/{module_name}/model"
    }}
  }},
  "LaunchSettings": {{
    "AutoStart": true,
    "FilePath": "python",
    "Debug": false,
    "DebugSettings": {{
      "DebuggerPort": 0,
      "EnableDebugger": false,
      "DebugAdapter": ""
    }},
    "Args": "{module_name}.py",
    "WorkingDirectory": "{{ModulePath}}"
  }}
}}
""")
        
        logger.info(f"Created Python module {module_name} at {full_path}")
        return True

def main():
    """Main entry point for the script"""
    parser = argparse.ArgumentParser(description="SeCuReDmE Core Management System")
    
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # Start command
    start_parser = subparsers.add_parser("start", help="Start services")
    start_parser.add_argument("service", choices=["all", "codeproject", "mindsdb", "module"], help="Service to start")
    start_parser.add_argument("--module", help="Module name (required if service is 'module')")
    
    # Create command
    create_parser = subparsers.add_parser("create", help="Create a new module")
    create_parser.add_argument("type", choices=["dotnet", "python"], help="Module type")
    create_parser.add_argument("name", help="Module name")
    create_parser.add_argument("--description", help="Module description")
    
    # Register command
    register_parser = subparsers.add_parser("register", help="Register an existing module")
    register_parser.add_argument("name", help="Module name")
    register_parser.add_argument("path", help="Module path")
    register_parser.add_argument("--description", help="Module description")
    register_parser.add_argument("--dependencies", help="Comma-separated list of dependencies")
    
    # Unregister command
    unregister_parser = subparsers.add_parser("unregister", help="Unregister a module")
    unregister_parser.add_argument("name", help="Module name")
    
    # Parse arguments
    args = parser.parse_args()
    
    # Initialize core
    core = SeCuReDmECore()
    
    if args.command == "start":
        if args.service == "all":
            core.start_all()
        elif args.service == "codeproject":
            core.start_service("server", "codeproject_ai")
        elif args.service == "mindsdb":
            core.start_service("server", "mindsdb")
        elif args.service == "module":
            if not args.module:
                logger.error("Module name is required for 'start module' command")
                parser.print_help()
                sys.exit(1)
            core.start_service("module", args.module)
    
    elif args.command == "create":
        description = args.description or f"{args.name} module"
        if args.type == "dotnet":
            core.create_dotnet_module(args.name, description)
        elif args.type == "python":
            core.create_python_module(args.name, description)
    
    elif args.command == "register":
        dependencies = []
        if args.dependencies:
            dependencies = [d.strip() for d in args.dependencies.split(",")]
        core.register_module(args.name, args.path, args.description or "", dependencies)
    
    elif args.command == "unregister":
        core.unregister_module(args.name)
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
