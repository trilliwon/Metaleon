#!/bin/bash

# Check if a version number is passed
if [ -z "$1" ]; then
  echo "Error: No version number provided."
  echo "Usage: ./release.sh <version>"
  exit 1
fi

VERSION=$1

# Commit any changes
echo "Committing changes..."
git add .
git commit -m "Preparing for release version $VERSION"
git push origin main

# Create a new Git tag
echo "Creating tag $VERSION..."
git tag $VERSION

# Push the tag to the remote repository
echo "Pushing tag $VERSION to origin..."
git push origin $VERSION

# Create a GitHub release with the tag using gh CLI
echo "Creating GitHub release for version $VERSION..."
gh release create $VERSION --title "Release $VERSION" --notes "Release version $VERSION"

echo "Release $VERSION created successfully!"