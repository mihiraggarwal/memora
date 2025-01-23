# memora

A mobile app to help people suffering from memory disorders.

## Features  

### 1. **Wander Prevention**  

- **Continuous Location Tracking:** Tracks the user's real-time location and displays it using FlutterMap.  
- **Safe Zone Alerts:** Sends notifications to caregivers if users move beyond a defined threshold distance.  
- **Route Guidance:** Displays a route to return home on the app.  

### 2. **Habitual Voice Logging**  

- **Voice Activity Logging:** Users can log activities and thoughts through simple voice commands.  
- **AI-Powered Recall:** Azure OpenAI helps users retrieve information from their logs via voice queries.

### 3. **Emergency Assistance**  

- **One-Tap Emergency Button:** Sends instant notifications to registered caregivers.  

### 4. **Caregiver Dashboard**  

- **Profile Monitoring:** Caregivers can view activity logs, location, and emergency alerts, to stay informed and assist users effectively.  

## Tech Stack  

- **Frontend:** Flutter  
- **Database:** Cloud Firestore
- **Authentication:** Firebase
- **Backend:** Microsoft Azure AI Services  
  - Azure Maps  
  - Azure Speech-to-Text  
  - Azure OpenAI  
  - Azure Text-to-Speech  
