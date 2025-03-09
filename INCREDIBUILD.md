# Using IncrediBuild with CodeProject AI-MindsDB Project

This document explains how to use IncrediBuild to accelerate builds for this project.

## Prerequisites

1. Install IncrediBuild from [their official website](https://www.incredibuild.com/downloads)
2. Make sure IncrediBuild is properly configured on your machine

## Using IncrediBuild

### Option 1: Using the provided script

Simply run:

```bash
npm run build:incredibuild
```

This will execute your build using IncrediBuild's distributed build capabilities.

### Option 2: Manual execution

You can also run the build manually:

```bash
BuildConsole.exe incredibuild.xml /profile="CodeProject AI-MindsDB Build" /command="npm install && npm run build"
```

## Configuration

The IncrediBuild configuration is stored in `incredibuild.xml`. You can modify this file to:

- Change the maximum number of cores used
- Configure network settings
- Adjust file synchronization options
- Set environment variables

## Benefits of Using IncrediBuild

- Faster builds through distributed compilation
- Better resource utilization across your network
- Build visualization and analytics
- Seamless integration with existing build processes

## Troubleshooting

### Common Issues and Solutions

#### 1. JSON Parse Error in package.json

If you see an error like `npm error code EJSONPARSE`, it means your package.json file has invalid JSON format. Remember that package.json must contain valid JSON:
- Comments like `// ...` are not allowed
- All property names must be in double quotes
- No trailing commas in arrays or objects

#### 2. Missing Project Files
The build script automatically checks for and creates missing project files:

- SentimentAnalysis.csproj
- PortraitFilter.csproj
- JsonAPI.csproj

If you encounter "Cannot open project file" errors, run the build script which will attempt to create these files with minimal valid content.

#### 3. TargetFramework Issues
If you see errors about unrecognized TargetFramework values, the build script will attempt to fix these by setting the appropriate target framework.

### General Troubleshooting
If you encounter other issues with IncrediBuild:

1. Check that IncrediBuild Agent is running
2. Verify that your license is valid
3. Examine the IncrediBuild logs for errors
4. Contact IncrediBuild support for assistance
