# Employee & Expense Management Mobile Application

## Overview
A role-based mobile application developed using **Flutter and Firebase** to manage employee expenses, approvals, payments, and notifications.  
The application is designed to reflect **real-world business workflows** commonly used in organizations for expense and payment management.

---

## Key Features

### Authentication & Roles
- Firebase Authentication with **role-based access**
- Separate **Admin** and **Employee** modules

### Employee Module
- Submit expense details
- View expense status (Pending / Approved / Rejected)
- View payment status
- Download expense reports in **PDF** and **CSV** formats
- Receive notifications with read/unread status

### Admin Module
- View all employee expenses
- Approve or reject submitted expenses
- Manage payment status (Pending / Paid / Failed)
- Generate **PDF and CSV reports** for expense and payment data
- Send notifications to employees

---

## Expense & Payment Workflow
1. Employee submits an expense  
2. Admin reviews and approves/rejects the expense  
3. Approved expenses move to payment processing  
4. Payment status is updated and reflected in dashboards  
5. Notifications are sent for each status change  

This workflow closely follows **organizational expense management systems**.

---

## Tech Stack
- **Frontend:** Flutter, Dart  
- **Backend & Database:** Firebase Authentication, Cloud Firestore  
- **Tools:** Git, VS Code, Android Studio  
- **Reports:** PDF & CSV generation  

---

## Project Structure
The application follows a **feature-based folder structure** for better scalability and maintainability:


---

## Data Handling
- Cloud Firestore collections designed for:
  - Users
  - Expenses
  - Payments
  - Notifications
- Status-based queries and updates
- Tested with **100+ sample expense records** during development

---

## Learning Outcomes
- Hands-on experience with **Flutter application architecture**
- Practical usage of **Firebase Authentication and Firestore**
- Implementation of **real-world business workflows**
- Report generation and structured data export
- End-to-end ownership of a mobile application

---

## Repository
https://github.com/huggeashwinihugge-ops/Employee_management_app

---

## Recruiter Note
This project was developed as a **self-driven application** to gain practical experience in mobile application development and backend integration using Firebase.
