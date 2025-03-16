# IncrediBuild Integration for SeCuReDmE

This document describes how to use IncrediBuild with the SeCuReDmE project to accelerate build times by distributing build tasks across multiple cores or networked computers.

## Prerequisites

- IncrediBuild installed (version 10.0 or higher)
- Windows operating system
- .NET SDK installed
- CodeProject AI Server solution files correctly set up

## Configuration Files

The IncrediBuild integration consists of two main files:

1. `build-with-incredibuild.bat` - The main script to configure agents and run the build
2. `incredibuild.xml` - The XML configuration profile for IncrediBuild

## Agent Configuration

The script automatically configures the IncrediBuild agents with the following settings:

- **Memory Allocation**: 4GB per agent
- **CPU Utilization**: 80% (allows system to remain responsive during builds)
- **Idle Timeout**: 5 minutes (agents return to the pool after 5 minutes of inactivity)
- **Network Scope**: Local network only (WAN agents are disabled)

These settings can be modified in the `build-with-incredibuild.bat` file under the "Configure Incredibuild agent settings" section.

## Using the Build Script

To use IncrediBuild for accelerated builds:

1. Open a command prompt in the SeCuReDmE project directory
2. Run: `.\mini-app-codeproject-ai-mindsdb\build-with-incredibuild.bat`
3. Follow the on-screen prompts to select build options

### Available Build Options

The script provides several build options:

1. **Release build (x64)** - Standard release build for 64-bit systems
2. **Debug build (x64)** - Debug build with symbols for 64-bit systems
3. **Release build (Any CPU)** - Platform-independent release build
4. **Debug build (Any CPU)** - Platform-independent debug build
5. **Clean solution** - Clean all compiled files from the solution
6. **Build specific module** - Build a single module (SentimentAnalysis, PortraitFilter, or MultiModeLLM)

### Building Specific Modules

When choosing to build a specific module (option 6), you can select from:

1. SentimentAnalysis
2. PortraitFilter
3. MultiModeLLM
4. All modules

## XML Profile Configuration

The `incredibuild.xml` file contains detailed settings for the build process:

- **Core Allocation**: Automatically determines the optimal number of cores to use
- **Local Cores**: Limits the number of local cores used to 4 (configurable)
- **Parallel Build**: Enabled for maximum performance
- **Multi-process Compilation**: Enabled to utilize multiple cores effectively
- **Prediction**: Build prediction is enabled to anticipate and optimize build steps
- **Visual Studio Integration**: Supports VS2019 and VS2022

## Optimizing Performance

For best performance with IncrediBuild:

1. **Coordinator Machine**: The machine running the build script should be powerful and have good network connectivity
2. **Network Throughput**: Ensure good network throughput between build agents
3. **SSD Storage**: Using SSD storage for the build directories improves performance
4. **Memory**: Allocate sufficient memory to agents (default is 4GB per agent)
5. **Clean Builds**: Occasional clean builds help prevent incremental build issues

## Troubleshooting

If you encounter issues with IncrediBuild:

1. **Check Agent Status**: Run `ibconsole /command=getavailableagents` to verify agents are connected
2. **Check Build Logs**: Examine the build logs in the root directory (`build-log.txt`)
3. **Reset Agent Configuration**: Use the option at the end of the build script to reset agents to default settings
4. **Update IncrediBuild**: Ensure you're using the latest version of IncrediBuild
5. **Verify Project Files**: Run `fix_project_files.bat` to ensure all project files are correctly configured

## Advanced Configuration

Advanced users can modify the `incredibuild.xml` file directly to:

- Change memory allocation per agent
- Adjust CPU utilization percentage
- Modify build prediction settings
- Add custom environment variables
- Configure output verbosity levels

## License Requirements

IncrediBuild functionality depends on your license:

- **Free Version**: Limited cores and build types
- **Build Tools**: Full support for C++ and .NET builds
- **Enterprise**: Full distribution of all build processes

Contact IncrediBuild sales for license options if you need additional capabilities.

## For More Information

- IncrediBuild Documentation: https://www.incredibuild.com/docs
- CodeProject AI Documentation: https://www.codeproject.com/AI
- SeCuReDmE Documentation: Refer to the project's main README files
