# SimpleJournalApp
Simple journaling app based on Marcus Aurelius meditations

# Description 
The SimpleJournal app lets you write a summary of your day using meditations written by Marcus Aurelius. Additionally, you can add one photo to the day entry - pick wisely. The app is connected to reminders and will let you create, update,complete and delete reminders.

## Main screens
| Home screen | Journal view | Remidners | Settings screen | 
|-------------|--------------|-----------|-----------------|
| ![image](https://user-images.githubusercontent.com/7796745/230874446-e5a79377-2672-404f-b6b6-20084c8fe438.png) | ![image](https://user-images.githubusercontent.com/7796745/230877065-c268dbc5-0a16-426c-a087-456ed156ef73.png) |![image](https://user-images.githubusercontent.com/7796745/230875817-b44b4c6e-c44f-40fb-9205-4c5aecc8fc80.png) | ![image](https://user-images.githubusercontent.com/7796745/230875140-9ccf1aaa-2c44-4f47-ad1a-f507b70d9d23.png) |

## Adding entries and reminders
| Jouraling screen | Adding new reminder | Adding photo |
|----|---|---|
|![adding_entry](https://user-images.githubusercontent.com/7796745/230882115-f3faa27a-eedb-4d90-aa20-babe0e634867.gif)| ![addingReminder](https://user-images.githubusercontent.com/7796745/230882620-7a24cffe-26be-47da-bcae-7c5067b4a608.gif)| ![Simulator Screen Recording - iPhone 14 Pro - 2023-04-10 at 12 05 30](https://user-images.githubusercontent.com/7796745/230881045-5bac6843-ba29-44ba-b416-b0eeec685db0.gif)|

# Technologies

- Dark mode support 
- Swift
- CoreData
- UserDefaults
- EventKit
- Notifications with UNUserNotificationCenter
- UIKit (mix of storyboards + programatic approach with autolayout, some CoreGraphics)
- MVC architecture 
- XCTest for unit and UI testing

# Highlights
- Custom FetchResultsController for EventKit allows using the UITableViews in a simple and hassle-free manner. 
- CalendarDayButton - button with bespoke drawn backgrounds and UIKit elements 
- Custom CoreDataStack, managers for JournalEntries and Reminders

# Build

No additional libraries used - clone with xcode and run!

# Feedback 

Feel free to file an issue or submit a PR.

