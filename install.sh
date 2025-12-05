#!/bin/bash

# Install Rust
if ! command -v cargo &> /dev/null
then
    echo "Rust is not installed. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Install Node.js
if ! command -v npm &> /dev/null
then
    echo "Node.js is not installed. Please install Node.js manually."
    exit 1
fi

# Build the project
make all

# Instructions
echo "Build complete. Run the following commands to start the application:"
echo "- Rust Agent: ./agent/target/release/antivirus-agent"
echo "- API: cd api && node server.js"
echo "- UI: Open the built files in ./ui/dist"