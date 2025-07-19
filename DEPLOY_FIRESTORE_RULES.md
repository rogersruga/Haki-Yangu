# Deploy Firestore Rules

## Manual Deployment Steps

Since Firebase CLI is not configured in this project, you need to manually update the Firestore rules:

### 1. Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **haki-yangu**
3. Go to **Firestore Database**
4. Click on **Rules** tab

### 2. Replace the Current Rules
Copy and paste the following rules to replace the existing ones:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Learning content is read-only for authenticated users
    match /content/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write content (via Firebase Admin SDK)
    }
    
    // Quizzes are read-only for authenticated users
    match /quizzes/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write quizzes (via Firebase Admin SDK)
    }
    
    // Categories are read-only for authenticated users
    match /categories/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write categories (via Firebase Admin SDK)
    }
    
    // User activities - users can only read/write their own activities
    match /activities/{document} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
    }
    
    // App settings are read-only for all authenticated users
    match /settings/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write settings (via Firebase Admin SDK)
    }

    // Chat sessions - users can only access their own chats
    match /chats/{chatId} {
      allow read: if request.auth != null && 
                  request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                   request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
                   request.auth.uid == resource.data.userId &&
                   request.auth.uid == request.resource.data.userId;
      allow delete: if request.auth != null && 
                   request.auth.uid == resource.data.userId;
    }
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    function isValidUserData() {
      return request.resource.data.keys().hasAll(['email', 'createdAt', 'lastLoginAt', 'progress', 'preferences']) &&
             request.resource.data.email is string &&
             request.resource.data.createdAt is timestamp &&
             request.resource.data.lastLoginAt is timestamp &&
             request.resource.data.progress is map &&
             request.resource.data.preferences is map;
    }
    
    function isValidActivity() {
      return request.resource.data.keys().hasAll(['userId', 'activityType', 'contentId', 'contentTitle', 'timestamp']) &&
             request.resource.data.userId is string &&
             request.resource.data.activityType is string &&
             request.resource.data.contentId is string &&
             request.resource.data.contentTitle is string &&
             request.resource.data.timestamp is timestamp;
    }
  }
}
```

### 3. Publish the Rules
1. Click **Publish** button
2. Confirm the deployment

## Key Changes Made

### Fixed Chat Permissions
- **Before**: Used generic `read, write` which didn't work for updates
- **After**: Separated into specific operations:
  - `read`: Check user owns the chat
  - `create`: Check user ID in new document
  - `update`: Check user owns both existing and updated document
  - `delete`: Check user owns the document

### Why This Fixes the Permission Error
The original rules used `allow read, write` which is too generic. The new rules:
1. **Create**: Works when creating new chat sessions
2. **Update**: Works when adding messages to existing sessions
3. **Read**: Works when loading chat history
4. **Delete**: Works when removing chat sessions

## Testing After Deployment

1. **Deploy the rules** using the steps above
2. **Restart the app** to clear any cached permissions
3. **Try sending a message** in the chat
4. **Check debug console** for:
   - `🟢 Message saved successfully to Firestore` (success)
   - No more `permission-denied` errors

## Alternative: Temporary Permissive Rules (For Testing Only)

If you want to test quickly, you can temporarily use these permissive rules (NOT for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ WARNING**: These rules allow any authenticated user to read/write any document. Only use for testing, then revert to the secure rules above.
