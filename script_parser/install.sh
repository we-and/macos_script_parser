#!/bin/bash

# Ensure the target directory exists
mkdir -p /opt/homebrew/
mkdir -p /opt/homebrew/opt
mkdir -p /opt/homebrew/opt/libzip
mkdir -p /opt/homebrew/opt/xz
mkdir -p /opt/homebrew/opt/icu4c
mkdir -p /opt/homebrew/opt/zstd
mkdir -p /opt/homebrew/opt/libxml2

# Copy the .dylib file to /opt/homebrew/opt
cp "$(dirname "$0")/libzip.5.5.dylib" /opt/homebrew/opt/libzip/lib/libzip.5.5.dylib 
cp "$(dirname "$0")/libxml2.2.dylib" /opt/homebrew/opt/libxml2/lib/libxml2.2.dylib 
cp "$(dirname "$0")/liblzma.5.dylib" /opt/homebrew/opt/xz/lib/liblzma.5.dylib 
cp "$(dirname "$0")/libicui18n.74.dylib" /opt/homebrew/opt/icu4c/lib/libicui18n.74.dylib  
cp "$(dirname "$0")/libzstd.1.dylib" /opt/homebrew/opt/zstd/lib/libzstd.1.dylib  
cp "$(dirname "$0")/libicuuc.74.dylib" /opt/homebrew/opt/icu4c/lib/libicuuc.74.dylib 
cp "$(dirname "$0")/libicudata.74.dylib" /opt/homebrew/opt/icu4c/lib/libicudata.74.dylib 


echo "Installation complete."