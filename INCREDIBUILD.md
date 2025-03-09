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

If you encounter issues with IncrediBuild:

1. Check that IncrediBuild Agent is running
2. Verify that your license is valid
3. Examine the IncrediBuild logs for errors
4. Contact IncrediBuild support for assistance
