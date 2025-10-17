# Fix for MissingPluginException - image_picker

## Problem
`MissingPluginException(No implementation found for method pickImage on channel plugins.flutter.io/image_picker)`

This error occurs because the native platform code for the image_picker plugin hasn't been properly linked after adding the package.

## Solution

### Steps to fix:

1. **Stop the running app completely**
   - Close the app on your device/emulator
   - Stop the Flutter debug session

2. **Clean the build**
   ```bash
   cd "c:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615\mobile"
   flutter clean
   ```

3. **Reinstall packages**
   ```bash
   flutter pub get
   ```

4. **Rebuild and run the app**
   ```bash
   flutter run
   ```

### Why this happens:
- When you add a new plugin that requires native code (like image_picker), Flutter needs to register it with the platform
- Hot reload/hot restart won't pick up new plugin registrations
- You must do a full rebuild for the native code to be linked properly

### Additional Notes:

**For Android:**
- The image_picker requires these permissions in `AndroidManifest.xml` (usually auto-added):
  ```xml
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  ```

**For iOS (if testing on iOS):**
- Requires permissions in `Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need camera access to take receipt photos</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need gallery access to upload receipt photos</string>
  ```

### After Rebuild:
The upload receipt feature should work properly:
1. Tap "Upload Receipt" button
2. Image picker should open
3. Select image from gallery
4. Image will be uploaded to the server

### Alternative: Test without image_picker first

If you want to test the payment screen without image upload, you can temporarily comment out the upload functionality and just view the payment list.
