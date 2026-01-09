#!/bin/bash

# Step 1: Build Flutter web
echo "Building Flutter web..."
flutter build web || { echo "Flutter build failed! Exiting."; exit 1; }

# Step 2: Deploy to Firebase Hosting
echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting || { echo "Firebase deploy failed! Exiting."; exit 1; }

# Step 3: Git push
echo "Enter your Git commit message:"
read commit_msg

# Stage changes
git add .

# Commit with the message provided by user
git commit -m "$commit_msg"

# Pull latest remote changes first to avoid conflicts
git pull origin main --no-rebase

# Push to GitHub
git push

echo "✅ Deployment complete!"
