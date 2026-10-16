# Together

A native SwiftUI iPhone starter app for a couple’s memories, targeting iOS 17 or later.

## Included

- Photo selection from your library, with resized copies saved in the app.
- Memories with a title, date, and optional note; tap to view, with confirmed deletion.
- Special occasions with optional annual recurrence and day countdowns.
- Local persistence with atomic writes and file protection.
- A cream and rose interface with separate Memories and Dates tabs.

## Run on a Mac

1. Open `Together.xcodeproj` in Xcode with the iOS 17 SDK or later.
2. Select the Together target and an iPhone simulator, then press Run.
3. To run on an iPhone, select your signing team under Signing & Capabilities and replace `com.example.together` with a unique bundle identifier.

The app has passed a GitHub Actions iOS Simulator build and launch check. CI also runs UI tests for blank-title validation and saving, reopening, and deleting memories and annual occasions. Photo-library interaction and visual verification still need device testing.

## Check on a device or simulator

Add a photo memory, close and reopen the app, and verify that its image, text, and date persist. Add a yearly anniversary and a one-time occasion; check the countdown and annual rollover. Verify that blank titles cannot be saved, photo-load errors are shown, and deletion works.

## Scope

Photos are imported and stored locally, not uploaded to a server. Both partners cannot yet share the same collection. There are no accounts, cloud sync, scheduled notifications, or editing of existing entries in this starter. Removing the app removes its local data. Add cloud storage and partner invitations for a shared version; add an app icon and complete device testing before distribution.

Annual February 29 occasions use the calendar’s next-time matching policy in non-leap years. The app stores compressed photos inside one JSON archive, suitable for an initial small collection; a larger library should use separate image files and a database.

## Version 1.1

Memories support up to 20 ordered photos, with a swipeable gallery and photo counts. Use Edit on a memory to change its text or add/remove photos. Existing single-photo archives load automatically without losing their original photos. The app uses a light blush-and-burgundy design for readable contrast. CI checks legacy migration and multi-photo persistence in addition to the simulator UI flows.
