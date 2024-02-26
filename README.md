# Team-FarmNETS

## FarmNETS App Installation Guide

Welcome to FarmNETS! This guide will walk you through the installation process for the FarmNETS Flutter mobile application.

## Prerequisites
**Tested on Android only**
Before you begin, make sure you have the following installed on your development machine:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (for Android development)

## Installation Steps

Follow these steps to install the FarmNETS app on your device:

1. **Clone the Repository:**
   ```
   git clone https://github.com/tettey-exploits/FarmNETS_Mobile-App.git
   ```

2. **Switch to the master branch**
    ```
    git checkout master
    ```

3. **Navigate to the Project Directory:**
   ```
   cd test_1
   ```

4. **Get Dependencies:**
   ```
   flutter pub get
   ```

5. **Run the App:**
   - Connect your Android/iOS device to your computer.
   - Ensure USB debugging is enabled on your Android device.
   - Open a terminal window and navigate to the project directory.
   - Run the following command:
     ```
     flutter run
     ```
   This will build the app and install it on your connected device.

6. **Alternatively, Use an Emulator:**
   - If you don't have a physical device, you can use an emulator.
   - Open Android Studio and launch the Android Virtual Device (AVD) Manager.
   - Create a new virtual device and start the emulator.
   - Once the emulator is running, repeat step 4.

7. **Explore the App:**
   - Once the app is installed, you can explore its features and functionalities.
   - Follow the on-screen instructions to navigate through the app.

## Additional Notes

- If you encounter any issues during the installation process, refer to the [Flutter documentation](https://flutter.dev/docs/get-started/install) for troubleshooting tips.
- For iOS development, you may need to set up code signing and provisioning profiles in Xcode before running the app on a physical iOS device.
- Remember to periodically pull updates from the repository to get the latest features and bug fixes.


## Resolving errors on build
- If you encounter this error when trying to run the app related to the tflite package "FAILURE: Build failed with an exception.

Where:
Build file 'E:\flutter\.pub-cache\hosted\pub.dartlang.org\tflite-1.1.2\android\build.gradle' line: 24
"
- Do this:
"
First visit this directory that is shown in the error E:\flutter.pub-cache\hosted\pub.dartlang.org\tflite-1.1.2\android\build.gradle There change the dependencies at the end to

dependencies {
    implementation 'org.tensorflow:tensorflow-lite:+'
    implementation 'org.tensorflow:tensorflow-lite-gpu:+'
}
"
