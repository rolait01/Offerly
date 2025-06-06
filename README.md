# Setup to use this project

1. Open your cmd and type python. If it is not installed, your Microsoft App Store should open where you can download Python
2. Download Android Studio
3. Launch Android Studio. The Welcome to Android Studio dialog displays.
4. Follow the Android Studio Setup Wizard. Install the following components:
   Android SDK Platform, API 35
   Android SDK Command-line Tools
   Android SDK Build-Tools
   Android SDK Platform-Tools
   Android Emulator
5. Download Visual Studio Code
6. Launch VS Code
7. To open the Command Palette, press Control + Shift + P.
8. In the Command Palette, type flutter.
9. Select Flutter: New Project.
10. VS Code prompts you to locate the Flutter SDK on your computer.
    If you have the Flutter SDK installed, click Locate SDK.
    If you don't have the Flutter SDK installed, click Download SDK.

    10.1 When the Select Folder for Flutter SDK dialog displays, choose where you want to install Flutter.

    10.2 Click Clone Flutter.

    10.3 Click Add SDK to PATH.

## Backend 
1. Go in VS Code in the termal to the backend folder
2. pip install -r requirements.txt
3. Then run "python -m fastapi dev .\main.py --host 0.0.0.0 --port 8000"

## Frontend
1. Show available emulators with "flutter emulators" or connect your phone and enable USB-Debugging
2. Start some emulator
3. Run in the frontend/offerly folder "flutter run"
4. Adjust the local IP in frontend/lib/offerly market_service.dart and product_service.dart
