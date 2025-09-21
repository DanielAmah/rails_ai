#!/bin/bash

# Setup GitHub Wiki for Rails AI Gem
echo "Setting up GitHub Wiki for Rails AI Gem..."

# Check if we're in the right directory
if [ ! -d "wiki" ]; then
    echo "Error: wiki directory not found. Please run this script from the rails_ai root directory."
    exit 1
fi

# Clone the wiki repository
echo "Cloning wiki repository..."
git clone https://github.com/DanielAmah/rails_ai.wiki.git wiki_repo

if [ $? -ne 0 ]; then
    echo "Error: Could not clone wiki repository. Make sure the wiki is enabled on GitHub."
    echo "To enable wiki:"
    echo "1. Go to https://github.com/DanielAmah/rails_ai"
    echo "2. Click on 'Settings' tab"
    echo "3. Scroll down to 'Features' section"
    echo "4. Check 'Wikis' to enable it"
    echo "5. Run this script again"
    exit 1
fi

# Copy wiki files
echo "Copying wiki files..."
cp wiki/*.md wiki_repo/

# Navigate to wiki repo
cd wiki_repo

# Add and commit files
echo "Adding wiki files to git..."
git add .
git commit -m "Add comprehensive wiki documentation for Rails AI Gem"

# Push to GitHub
echo "Pushing wiki to GitHub..."
git push origin master

if [ $? -eq 0 ]; then
    echo "✅ Wiki successfully set up!"
    echo "You can now view it at: https://github.com/DanielAmah/rails_ai/wiki"
else
    echo "❌ Error pushing wiki to GitHub"
    exit 1
fi

# Clean up
cd ..
rm -rf wiki_repo

echo "Wiki setup complete!"
