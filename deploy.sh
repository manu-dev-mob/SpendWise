#!/bin/bash

# Step 1: Get latest code first
echo "Pulling latest changes..."
git pull origin main --no-rebase || { echo "Git pull failed! Exiting."; exit 1; }

# Step 2: Build Flutter web
echo "Building Flutter web..."
flutter build web || { echo "Flutter build failed! Exiting."; exit 1; }

# Step 3: Deploy to Firebase Hosting
echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting || { echo "Firebase deploy failed! Exiting."; exit 1; }

# Step 4: Commit changes
echo "Enter your Git commit message:"
read commit_msg

git add .
git commit -m "$commit_msg"

# Step 5: Push
git push origin main

echo "✅ Deployment complete!"