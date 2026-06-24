# 🚀 NetPulse

A Flutter-based Network Device Monitoring application that allows users to upload Excel or CSV files containing IP addresses and instantly check device availability using local system ping commands.

> ⚡ No Database • 🔒 100% Local Processing • 📊 Bulk IP Monitoring

---

## 📖 Overview

NetPulse is a lightweight desktop application built with Flutter for IT administrators and network engineers.

The application reads IP addresses from uploaded Excel or CSV files and executes ping commands directly through the local machine's terminal to determine whether devices are reachable.

Since all operations are performed locally, no data is stored in a database or sent to external servers.

---

## ✨ Features

- 📂 Upload CSV and Excel files
- 🌐 Bulk IP address monitoring
- ⚡ Real-time online/offline status checking
- 🖥️ Terminal-based ping execution
- 📊 Easy-to-read results dashboard
- 🔒 No database required
- 🚀 Fast and lightweight
- 💻 Cross-platform Flutter application

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|----------|
| Flutter | Frontend UI |
| Dart | Application Logic |
| Excel Package | Read Excel Files |
| CSV Package | Parse CSV Files |
| Process API | Execute Terminal Commands |

---

## 🏗️ How It Works

```text
Upload CSV/Excel
        │
        ▼
Read IP Addresses
        │
        ▼
Execute Local Ping Commands
        │
        ▼
Collect Responses
        │
        ▼
Display Online/Offline Status
```

---

## 📂 Supported File Format

### CSV Example

```csv
Device Name,IP Address
Printer,192.168.1.10
Router,192.168.1.1
Server,192.168.1.100
```

### Excel Example

| Device Name | IP Address |
|------------|------------|
| Printer | 192.168.1.10 |
| Router | 192.168.1.1 |
| Server | 192.168.1.100 |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Windows / macOS / Linux

### Installation

```bash
git clone https://github.com/yourusername/netpulse.git

cd netpulse

flutter pub get

flutter run
```

---

## 📸 Application Workflow

1. Upload an Excel or CSV file.
2. Extract IP addresses from the file.
3. Execute ping commands through the local terminal.
4. Analyze ping responses.
5. Display device status in the UI.

---

## 🔍 Example Status Output

| Device | IP Address | Status |
|---------|------------|---------|
| Router | 192.168.1.1 | 🟢 Online |
| Printer | 192.168.1.10 | 🔴 Offline |
| Server | 192.168.1.100 | 🟢 Online |

---

## 🔒 Privacy & Security

NetPulse operates entirely on your local machine.

✔ No Cloud Storage  
✔ No Database  
✔ No External APIs  
✔ No Data Collection  

All uploaded files remain on the user's system.

---

## 🎯 Use Cases

- Network Device Monitoring
- IT Infrastructure Auditing
- Office Network Health Checks
- Device Availability Verification
- Server Reachability Monitoring

---

## 📈 Future Enhancements

- Export Scan Reports
- Auto Refresh Monitoring
- Network Dashboard
- Device Response Time Tracking
- Multi-threaded Scanning
- Email Notifications

---

## 👨‍💻 Author

### Nazmee Jawed

Flutter Developer | Backend Enthusiast | BCA Graduate

---

## ⭐ Support

If you find this project useful, consider giving it a ⭐ on GitHub.

```
Made with ❤️ using Flutter
```
