# Firebase Security Rules

These are recommended Firestore security rules for your Sharpcuts app. You'll need to update these in your Firebase Console under Firestore Database > Rules.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access to the admin collection, but only allow write by authenticated users
    match /Admin/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Allow authenticated users to read and write to the Booking collection
    match /Booking/{document=**} {
      allow read, write: if request.auth != null;
    }

    // Allow users to read and write only their own user data
    match /users/{userId} {
      allow read, write: if request.auth != null && (request.auth.uid == userId || isAdmin());
    }

    // Helper function to check if user is an admin
    function isAdmin() {
      return exists(/databases/$(database)/documents/Admin/$(request.auth.uid)) ||
        exists(/databases/$(database)/documents/Admin/$(request.auth.email));
    }
  }
}
```

## How to Apply These Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Firestore Database in the left sidebar
4. Click on the "Rules" tab
5. Replace the existing rules with the ones above
6. Click "Publish"

## What These Rules Do

-   Allows anyone to read the Admin collection (to check if admin emails exist)
-   Only allows authenticated users to write to the Admin collection
-   Allows authenticated users to read and write to the Booking collection
-   Allows users to only read and write their own user data
-   Admin users can read and write any user data

## Important Notes

-   These rules are fairly permissive to ensure your app works properly during development
-   For a production app, you should implement more restrictive rules
-   The `isAdmin()` function checks if a document with the user's ID or email exists in the Admin collection
