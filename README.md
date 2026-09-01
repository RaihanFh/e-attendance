# E-Attendance

A Flutter-based employee attendance and task management application for Lakeside FnB.

The application allows employees to view their work schedules, clock in and out based on their physical location, manage assigned tasks, and review attendance information. Managers have additional functionality for assigning tasks to employees.

## ✨ Features

### 🔐 Authentication

Login using:
- Username and password
- Phone number and password
- Session persistence using Hive local storage.
- Automatic navigation to the home page when an authenticated session exists.
- Logout functionality.

### 🏠 Home & Attendance

- Displays the logged-in employee's information.
- Shows the employee's schedule for the current day.
Displays:
- Outlet
- Job/position
- Scheduled clock-in time
- Scheduled clock-out time
- Attendance status
- Pull-to-refresh support.
- Clock in and clock out using a slide interaction.
- GPS/location verification to ensure the employee is at the assigned outlet before clocking in or out.
Attendance status tracking, including:
- On Time
- Late
- Overtime
- Didn't attend

### ✅ Task Management

Employees can:
- View assigned tasks.
- View tasks grouped by outlet, date, and shift.
- Mark individual tasks as completed.
- Refresh task information.
- See when all tasks for a shift have been completed.
Managers can additionally:
- View upcoming employee shifts.
- Select an employee/shift.
- Add tasks to a shift.
- Remove existing tasks.
- Manage task status.

### 👤 Account & Attendance Summary

- Displays employee information.
- Shows attendance statistics for the current period.
- Provides attendance history.
- Supports logout.

### 💾 Local Data

- The application uses Hive for local persistence.
Local storage is used for:
- Logged-in user information.
- Cached daily clock/attendance schedule.
- Current attendance period information.
- Daily attendance data is refreshed when the cached schedule is no longer associated with the current date.

## 🚀 Getting Started

Prerequisites

Install the following:

Flutter SDK
Dart SDK compatible with the project's Dart constraint
Android Studio or another Flutter-compatible IDE
Android SDK for Android builds
Xcode for iOS development

Check your Flutter installation:

flutter doctor
Installation

Clone the repository:

git clone <repository-url>
cd lakeside

Install dependencies:

flutter pub get

Run the application:

flutter run
