# Varity
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/Asb1FQegzN8/0.jpg)](https://www.youtube.com/watch?v=Asb1FQegzN8)

Varity is an application to manage your device volume and brightness for each different app by taking advantage of android accessibility service. It can save your volume/brightness state when you open other app and restore it when you open that app again.

## Required permission
- Modify system settings (used to change your brightness)
- Accessibility Service (used to watch your active app and change volume/brightness based on what app you open.)

## Features
- It works on rooted/non-rooted device
- Save brightness/volume state for each different app
- Show notification to configure brightness/volume when you install new app

## Note 
This app probably won't work on multi window mode, i never tried this app in androidx86 or similar os, so i would appreciate it if you can give me a feedback about it.

For now this app is only available on Android, but I may consider adding another platform except for the web. But it would be a different kind of app because this app only support a fullscreen app and probably not working in multi window.

## Notice
This app has been released in google play store before but lately play console just want to make it hard for me to update my app in there so i decide to move it somewhere else, if you have any suggestion about where i should publish my app you can contact me.

Note that never ever in my whole life I do data mining and selling/sharing it to a third party. even though sometimes I collected your personal data like email, it was only so I can organize your other data in the database based on your email. From my point of view, email can act as your unique id because you can't make an email that is already being used by another user.

In Varity i didn't receive any personal data from you, the data that i use in this app will only stay in your phone so you can just clear the app data from your settings app, but i do collect some info from your phone but it was only for detecting crash/issue in Varity.

## TODO
- [ ] Add support to differentiate volume when connected to hadphone/handsfree
- [ ] Add support to change ring volume
- [ ] Add support to make phone silent on holiday by checking calender schedule
- [ ] Add support to make phone silent on weekend
- [x] Add default volume/brightness configuration in settings
- [ ] Add support to detect a player when it's in picture-in-picture mode
- [ ] Add some tests

## Known Issue
- [x] sometime got sqlite error database locked

