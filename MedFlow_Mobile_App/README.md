MedFlow: AI-Powered Resourcew Management Platform
A Comprehensive Healthcare Suite for Seamless Patient Management and AI-Driven Diagnostics.

Overview
MedFlow is a high-performance Flutter application designed to digitize the patient experience. By integrating Supabase for backend services and AI Voice Agents, it streamlines everything from basic appointment booking to complex medical document parsing.This is the patient end of the resource management platform.

Prerequisites
Flutter SDK: ^3.0.0
Dart SDK: ^3.0.0

Supabase Account: For database and authentication.
 Core Feature Roadmap
Based on the project architecture, here is the functional breakdown of the MedFlow application:

1.  Authentication & User Management
Secure Entry: Located in login_and_signup/, providing dedicated flows for patient onboarding and secure login.
Data Persistence: Managed via patient_data.dart to maintain user profiles and session states.

2.  Smart Appointment System (take_appointment.dart)
Tiered Selection: Context-aware selection of Hospitals, Departments, and Doctors.
Real-time Scheduling: Integrated date and time pickers with validation.
Automated Sync: Instant synchronization with the Supabase appointments table.

3.  AI Voice Concierge (voice_agent_page.dart)
Hands-Free Navigation: A dedicated AI agent page that allows users to interact with the app using natural language.
Smart Assistant: Designed to handle queries that might otherwise require manual form entry.

4. Document Intelligence (doc_prescription/)
Optical Character Recognition (OCR): Using text_recognition_page.dart to parse physical prescriptions into digital data.
Medical Camera: Specialized camera interface (camera_page.dart) optimized for capturing medical documents clearly.

5. Emergency & Critical Care
SOS Trigger: sos.dart provides a one-tap emergency signal for immediate assistance.
Ambulance Booking: ambs.dart manages rapid transport requests.
Precautionary Guides: precaution.dart offers immediate medical advice for first-aid scenarios.

6. Hospital & Pharmacy Integration
Directory Services: hosp_list.dart and Pharmacy.dart allow users to browse nearby medical facilities and retail pharmacies.
Medication Flow: medflow_splash.dart handles the specialized onboarding for medication tracking.

7. Wellness & Monitoring
Dietary Tracking: diet_screen.dart helps patients manage nutritional intake.
Health Updates: healthupdates.dart provides a feed of the patient's latest vitals or hospital news.
Interactive Chatbot: chatbot.dart for 24/7 basic medical inquiries.

Installation & SetupClone the Repository:
Bash git clone https://github.com/Tejashj/Built-for-Bengaluru

Environment Setup:Create a .env file or update main.dart with your Supabase URL and Anon Key.Ensure google-services.json (Android) or GoogleService-Infoplist (iOS) is present for Firebase features.Fetch 
Packages:
Bash flutter pub get
Launch:
Bash flutter run

Module                        Files                       Description
Patient End            dashboard.dart                     The central hub for all patient activities.
Prescription AI     text_recognition_page.dart            Extracting text from uploaded prescription images.
Notifications             notif.dart                      Handling push notifications for appointments and meds.
Identity               patient_end.dart                   Root wrapper for the patient-side navigation logic.

Security & ComplianceData Encryption: All patient data is transmitted over HTTPS via Supabase.Row Level Security (RLS): Database policies ensure patients can only view their own records.

