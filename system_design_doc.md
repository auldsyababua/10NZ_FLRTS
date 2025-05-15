# 10NetZero-FLRTS: System Design Document

Version: 2.0 (Shift to Noloco as Primary UI and Data Store)
Date: May 15, 2025

*For all LLM/AI collaboration standards, code commenting, and development philosophy, see [AI_Collaboration_Guide.md](./AI_Collaboration_Guide.md). The field definitions previously in Appendix A of this document are now maintained in a separate "Appendix A: Noloco Table Field Definitions" document.*

## 0. Document Version Control Log
* **Version 1.0-1.4:** Initial drafts and refinements focusing on an Airtable backend and Telegram MiniApp UI.
* **Version 1.5 (May 14, 2025):** Incorporated AI Collaboration Guide, Project Directives, and Appendix A refinements (still Airtable-focused).
* **Version 2.0 (May 15, 2025):** Major architectural revision. Shifted primary data store from Airtable to Noloco Tables and primary User Interface from Telegram MiniApp to Noloco's web application platform. Appendix A (field definitions) moved to a separate document and updated for Noloco. This document reflects these fundamental changes.

## 1. Introduction

### 1.1. Purpose of the Document

This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model (now implemented in Noloco Tables), user interaction flows (primarily through the Noloco platform), third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements based on the Noloco platform.

### 1.2. System Overview (10NetZero-FLRTS)

The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows for users, particularly those in field operations, by leveraging a robust data backend provided by **Noloco Tables** and a user-friendly interface built on the **Noloco web application platform**. A Flask backend will support advanced business logic, integrations not natively handled by Noloco, and potential secondary interfaces like a Telegram bot for notifications or specific quick actions. Integrations with a General Purpose LLM (for NLP), Todoist (for task/reminder management), and Google Drive (for SOP documents) will be maintained and accessed via Noloco or the Flask backend as appropriate.

## 2. Goals and Objectives

### 2.1. Primary Goals

* **Centralized Data Management:** Provide a single source of truth for all FLRTS data using Noloco Tables.
* **Intuitive User Interface:** Offer a user-friendly web interface via the Noloco platform for creating, viewing, updating, and managing all FLRTS items.
* **Streamlined Workflows:** Simplify and automate operational processes related to field reporting, task management, and list maintenance.
* **Effective Communication:** Ensure timely notifications and easy access to relevant information for all users.
* **Scalability & Maintainability:** Build a system that can grow with 10NetZero's needs and is relatively easy to maintain, leveraging Noloco's platform capabilities.

### 2.2. MVP Scope

The MVP will focus on delivering core FLRTS functionalities with Noloco as the SSoT and primary web UI, and a robust natural language interface via Telegram for field technicians.
- **Core FLRTS Modules & Data Management:**
  - All FLRTS data (Sites, Personnel, Field Reports, Lists, List Items, Tasks, Users, etc.) managed in **Noloco Tables** as the Single Source of Truth.
  - **Noloco Web Application UI:**
    - Forms, views, and basic dashboards within Noloco for creating, viewing, and managing all FLRTS items by users who prefer a web interface or require comprehensive data views (e.g., administrators, site managers).
    - User management via Noloco's built-in system, linked to `Personnel` and `Users` collections for application-specific roles.
- **Natural Language FLRTS CRUD for Field Technicians (via Telegram Bot):**
  - **Typed natural language input** for creating, viewing, and updating:
    - **Tasks & Reminders:** Leveraging Todoist API for NLP (date/time parsing) and task creation, with data synced to Noloco Tables.
    - **Field Reports:** Creation via narrative text input.
    - **List Items:** Adding items to predefined lists (e.g., Shopping Lists, Tool Inventories).
  - Basic querying of FLRTS items (e.g., "view my tasks for today").
- **Flask Backend:**
  - Handling all Telegram bot interactions.
  - **Initial Intent Classification** of natural language input from Telegram.
  - **NLP Orchestration:**
    - Calling Todoist API for task/reminder NLP and creation.
    - Calling a General Purpose LLM API for parsing field reports and list updates.
  - All CRUD operations with Noloco Tables via its API.
  - Programmatic generation of master SOP Google Documents for new sites and linking them in Noloco.
  - Automated initial site setup logic (default lists, SOP link).
- **Integrations (MVP Level):**
  - **Todoist:** For task NLP and backend task management, synced with Noloco.
  - **Google Drive:** For SOP document storage and linking.
  - **General Purpose LLM:** For NLP of field reports and list updates.

## 3. Data Model and Management

### 3.1. Data Storage (Noloco Tables)

The primary data store for the 10NetZero-FLRTS system will be **Noloco Tables**. Noloco's internal database will house all collections (formerly referred to as tables in an Airtable context) and manage the relationships between them.

* **Collections:** Data will be organized into logical collections within Noloco, such as `Sites`, `Personnel`, `Field_Reports`, `Lists`, `List_Items`, `Tasks`, etc.
* **Fields:** Each collection will have defined fields with specific Noloco data types (e.g., Text, Number, Date, Relationship, Boolean, File, URL, Single/Multiple Option Select).
* **Relationships:** Noloco's relationship field types will be used to link records between collections (e.g., linking a `Field_Report` to a `Site` and a `User`). Junction collections will be used for many-to-many relationships where necessary (e.g., `Site_Partner_Assignments`).
* **Data Integrity & Validation:** Noloco's built-in field validation capabilities will be utilized where possible. Additional complex validation rules may be enforced by the Flask backend before writing data to Noloco via its API, or through Noloco Workflows.
* **Views and Access Control:** Noloco's interface will be configured to provide appropriate views, filters, and access permissions for different user roles.

**For detailed field definitions, data types, and relationships for all Noloco Collections, refer to the separate document: "Appendix A: Noloco Table Field Definitions".**

### 3.2. Data Flow

The system supports two primary data flow pathways for FLRTS item creation and modification:
1. **Natural Language Input Pathway (Primarily for Field Technicians via Telegram):**
   - **a. User Input (Telegram):** User sends a typed natural language command to the Telegram bot (e.g., "create task...", "log field report...", "add to shopping list...").
   - **b. Flask Backend - Intent Classification:** The Flask backend receives the message. An initial processing step classifies the user's intent (e.g., is this a request to create a task, log a report, update a list, or query data?).
   - **c. Flask Backend - NLP Orchestration & External API Calls:**
     - **For Tasks/Reminders:** Flask calls the Todoist API's Quick Add feature with the relevant part of the natural language string. Todoist parses it, creates the task, and returns structured task data.
     - **For Field Reports, List Updates, Other FLRTS Items:** Flask constructs a prompt for a General Purpose LLM (e.g., OpenAI API) using the user's input and context. The LLM processes the text and returns structured data (e.g., JSON).
   - **d. Flask Backend - Data Structuring & Noloco Interaction:** Flask processes the structured data received from Todoist or the LLM. It then performs the necessary CRUD (Create, Read, Update, Delete) operations on the appropriate Noloco Tables via the Noloco GraphQL API. For new items, this includes creating new records; for updates, it involves modifying existing records.
   - **e. Flask Backend - User Feedback (Telegram):** Flask sends a confirmation, the result of a query, or an error message back to the user via the Telegram bot.
   - **f. Noloco Tables (SSoT):** The data is now stored and managed within Noloco.
2. **Structured Web Input Pathway (Noloco Web Application):**
   - **a. User Input (Noloco Interface):** Users interact directly with the Noloco web application using forms, list views, and action buttons to create, view, update, or delete FLRTS records.
   - **b. Noloco Internal Processing:** Noloco handles the data validation (as configured) and directly creates/updates records in its underlying Noloco Tables.
   - **c. Noloco Workflows/Automations (Optional):** Noloco's native automation capabilities may trigger further actions within Noloco or call external webhooks (e.g., to the Flask backend for complex post-processing) based on data changes.
   - **d. Flask Backend (via Webhook - Optional):** If a Noloco workflow triggers a webhook to the Flask backend, Flask can perform additional business logic, interact with third-party services, and potentially update Noloco Tables further via the API.
   - **e. Noloco Tables (SSoT):** Data is managed within Noloco.

In both pathways, **Noloco Tables serve as the Single Source of Truth.** Data entered or processed via the Telegram/Flask/NLP pathway is accessible and manageable through the Noloco Web UI, and vice-versa (respecting user permissions).

## 4. User Interface (UI) and User Experience (UX)

### 4.1. Primary User Interface (Noloco Web Application)

The primary interface for the 10NetZero-FLRTS system will be a web application built on the Noloco platform.

* **Accessibility:** Accessible via web browsers on desktop and mobile devices.
* **Key Features:**
    * **Custom Views:** List views, detail views, Kanban boards, calendars, and dashboards configured within Noloco to display FLRTS data.
    * **Forms:** User-friendly forms for creating and editing records in all relevant collections (Sites, Field Reports, Tasks, etc.).
    * **Action Buttons:** Noloco action buttons for triggering specific operations (e.g., "Complete Task," "Submit Report," "Add Item to List").
    * **User Authentication & Roles:** Managed by Noloco's built-in user authentication and permission system. Different user roles will have access to different data and functionalities.
    * **Search and Filtering:** Utilize Noloco's built-in search and filtering capabilities.

### 4.2. Key Interaction Channel for Field Operations: Telegram Bot

The Telegram bot serves as a crucial, direct interface for field technicians to perform rapid, low-friction Create, Read, Update, and Delete (CRUD) operations on FLRTS items using typed natural language commands (for MVP). This interface is optimized for on-the-fly interactions with minimal need for navigating complex forms, addressing the primary pain point of high-friction data entry on mobile devices.
- **Accessibility:** Available on any device with Telegram installed.
- **Input Method (MVP):** Typed natural language commands. Users' mobile OS voice-to-text capabilities can naturally be used to populate the text input in Telegram.
- **Core Functionality:**
  - **Natural Language FLRTS Creation:**
    - **Tasks & Reminders:** Users can type commands like, "Tell Bryan to call Anthony tomorrow at 5pm about the new generator controls coming in." The backend will leverage Todoist's NLP for date/time parsing and task structuring.
    - **Field Reports:** Users can type narrative reports like, "Field report Site Gamma: Generator A running at 80% load, fuel levels nominal. Noticed slight oil sheen near pump 3." The backend uses a general LLM for parsing.
    - **List Item Additions:** Users can type commands like, "Add 'WD-40' and 'rags' to the Site Alpha shopping list."
  - **Natural Language FLRTS Querying (Basic MVP):**
    - Users can ask for their tasks (e.g., "What are my tasks for today?").
    - View specific lists (e.g., "Show me the Site Alpha shopping list").
  - **Natural Language FLRTS Updates (Basic MVP):**
    - Mark tasks as complete.
    - Make simple updates to list items if feasible via NLP.
- **Interaction Flow:**
  1. User sends a natural language message to the Telegram bot.
  2. The Flask backend receives the message.
  3. Flask performs intent classification and NLP processing (using Todoist API or General LLM API as appropriate).
  4. Flask interacts with Noloco Tables via API to perform the CRUD operation.
  5. The Telegram bot sends a confirmation, result, or clarifying question back to the user.
- **User Experience Goal:** To make FLRTS management feel like a quick conversation rather than data entry. The interface avoids presenting users with multiple fields to fill out for common operations.

### 4.3. User Interaction Flows

User interaction flows will primarily occur through the Noloco Web Application for structured input and comprehensive views, and through the Telegram Bot for low-friction, natural language-based input, especially for field technicians.

**Example 1: Creating a Task via Telegram (Field Technician)**
1. **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2. **User Types:** "Remind me to inspect the main breaker at Site Bravo tomorrow morning at 9am"
3. **Telegram Bot:** Sends message to Flask backend.
4. **Flask Backend:**
   - Receives text.
   - Classifies intent as "create task/reminder."
   - Sends the string "inspect the main breaker at Site Bravo tomorrow morning at 9am" to the Todoist API (Quick Add).
   - Todoist API parses the string, creates a task with the description, due date (tomorrow's date), and due time (9:00 AM), and returns the structured task ID and details.
   - Flask creates a new record in the Noloco `Tasks` collection, populating fields like `TaskTitle`, `DueDate`, `Site_Link` (if "Site Bravo" can be reliably identified and linked), `AssignedTo_User_Link` (to the sending user), and stores the `TodoistTaskID`.
5. **Telegram Bot (to User):** "OK, I've created a task: 'Inspect the main breaker at Site Bravo' for tomorrow at 9:00 AM."

**Example 2: Logging a Field Report via Telegram (Field Technician)**
1. **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2. **User Types:** "Field report for Site Alpha. Unit 5 chiller is cycling too frequently. Ambient temp 35C. No alarms triggered but needs investigation. Took a video and uploaded it." (Assume user separately sends the video file to the bot if the bot supports file handling, or provides a link).
3. **Telegram Bot:** Sends message (and potentially file info) to Flask backend.
4. **Flask Backend:**
   - Receives text (and file info).
   - Classifies intent as "create field report."
   - Constructs a prompt for the General Purpose LLM, including the user's text.
   - LLM API processes the text and returns structured data (e.g., JSON identifying Site Alpha, the content of the report, mentions of "Unit 5 chiller").
   - Flask creates a new record in the Noloco `Field_Reports` collection, populating `Site_Link`, `ReportContent_Full`, `SubmittedBy_User_Link`, and potentially linking the video file if handled.
5. **Telegram Bot (to User):** "Field report for Site Alpha logged: 'Unit 5 chiller cycling too frequently...'"

**Example 3: Adding to a Shopping List via Telegram (Field Technician)**
1. **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2. **User Types:** "Add three 20A fuses and a roll of electrical tape to the Site Charlie shopping list"
3. **Telegram Bot:** Sends message to Flask backend.
4. **Flask Backend:**
   - Receives text.
   - Classifies intent as "update list / add item."
   - Constructs a prompt for the General Purpose LLM to identify the list ("Site Charlie shopping list") and the items ("three 20A fuses," "a roll of electrical tape").
   - LLM API returns structured data.
   - Flask finds the correct `Lists` record for "Site Charlie shopping list" in Noloco.
   - Flask creates new `List_Item` records ("20A fuses" with detail "quantity: 3", "electrical tape" with detail "quantity: 1 roll") and links them to the parent list in Noloco.
5. **Telegram Bot (to User):** "OK, added '20A fuses (3)' and 'electrical tape (1 roll)' to the Site Charlie shopping list."

## 5. Backend Architecture (Flask Application)

The Flask Python backend will continue to play a crucial role, focusing on logic and integrations that are complex or external to Noloco's native capabilities.

### 5.1. Core Responsibilities

The Flask Python backend acts as the central nervous system for intelligent processing, integrations, and interactions originating from non-Noloco interfaces.
- **Receiving and Processing Natural Language Commands:** Handling all input from the Telegram bot interface.
- **Initial Intent Classification:** Performing a preliminary analysis of natural language input from Telegram to determine the user's intent (e.g., create a task, log a field report, update a list, query data) before routing to specialized NLP processing.
- **NLP Orchestration & External API Integration Management:**
  - **Todoist API:** Directly calling the Todoist API (Quick Add) for natural language parsing of tasks and reminders, and synchronizing structured task data with Noloco.
  - **General Purpose LLM API (e.g., OpenAI):** Managing interactions for parsing more complex or varied natural language inputs like field reports and list updates into structured data.
  - **Google Drive API:** Programmatically generating SOP documents, managing permissions, and storing links in Noloco.
- **Noloco API Interaction:** Acting as a robust client to Noloco's GraphQL API for all programmatic CRUD (Create, Read, Update, Delete) operations on Noloco Tables based on processed data from Telegram/NLP or other internal logic.
- **Telegram Bot Logic:** Managing the conversational flow, sending messages/confirmations, and handling user interactions within Telegram.
- **Automated Site Setup:** Handling the programmatic creation of SOP documents and default lists in Noloco for new sites.
- **Business Logic Orchestration:** Implementing complex business rules or workflows that are not suitable for Noloco's native automations or require interaction with multiple external services.
- **Data Validation (Complex):** Enforcing backend data validation rules before writing to Noloco if Noloco's native validation is insufficient.
- **Scheduled Tasks/Cron Jobs (If Needed):** Running periodic tasks.

### 5.2. Key Modules (Conceptual)

* **`noloco_client.py`:** A module dedicated to all interactions with the Noloco GraphQL API. This will include functions for authentication, querying collections, creating records, updating records, and deleting records. It will abstract the complexities of GraphQL for other parts of the backend.
* **`telegram_bot_handler.py`:** Manages interactions with the Telegram Bot API (receiving messages, sending replies/notifications).
* **`todoist_integration.py`:** Handles communication with the Todoist API.
* **`google_drive_integration.py`:** Manages SOP document creation and linking.
* **`llm_service.py`:** Interfaces with the chosen General Purpose LLM.
* **`site_setup_module.py`:** Orchestrates the initial setup for new sites.
* **API Endpoints / Webhooks:** Flask routes for receiving webhooks from external services (e.g., Todoist, Noloco if it can send webhooks) or serving internal needs.

### 5.3. Authentication and Authorization

* **Flask Backend to Noloco:** The Flask backend will use an API key to authenticate with the Noloco GraphQL API.
* **External Services to Flask:** Webhooks received by the Flask backend (e.g., from Todoist) will be secured using signature verification (e.g., HMAC).
* **Telegram Bot:** Standard Telegram bot token authentication.

### 5.4 NLP Orchestration Pipeline

A core function of the Flask backend is to process natural language commands received, typically from the Telegram bot, and translate them into structured actions and data within the Noloco SSoT. This pipeline generally follows these steps:
1. **Input Reception:** The Flask backend receives a natural language string (e.g., from a Telegram message). Associated user information (e.g., Telegram User ID) is also received.
2. **Initial Intent Classification:**
   - The input string is analyzed to determine the probable user intent (e.g., `CREATE_TASK`, `CREATE_FIELD_REPORT`, `Notes`, `QUERY_TASKS`).
   - This can be achieved using a combination of keyword matching, pattern recognition, or a lightweight classification model/LLM prompt.
3. **Specialized NLP Processing (based on intent):**
   - **If Intent is **`CREATE_TASK`** or **`Tasks/Reminders`**:**
     - The relevant part of the natural language string is passed directly to the Todoist API's "Quick Add" endpoint.
     - Todoist's NLP engine parses the string, creating a task within Todoist and identifying due dates, times, recurrence, etc.
     - The Flask backend receives the structured task details (including the Todoist Task ID) from the Todoist API response.
   - **If Intent is **`CREATE_FIELD_REPORT`**, **`Notes`**, **`UPDATE_LIST_ITEM`**, or other intents requiring more flexible parsing:**
     - The Flask backend constructs a specific prompt tailored to the intent and the expected output structure.
     - This prompt, along with the user's natural language input, is sent to a General Purpose LLM API (e.g., OpenAI).
     - The LLM processes the input and returns structured data (typically JSON) as defined by the prompt (e.g., for a field report: `{ "site_name": "Site Alpha", "report_text": "...", "equipment_mentioned": [...] }`).
4. **Data Validation and Structuring:**
   - The structured data received from Todoist or the LLM is validated by the Flask backend.
   - Data is mapped to the fields of the relevant Noloco Collection(s) (e.g., `Tasks`, `Field_Reports`, `List_Items`). This may involve looking up foreign keys (e.g., finding the `SiteID_PK_Noloco` for a given `site_name`).
5. **Noloco Database Interaction:**
   - The Flask backend uses its `noloco_client.py` module to interact with the Noloco GraphQL API.
   - The structured data is used to create new records or update existing records in the appropriate Noloco Tables.
6. **User Feedback:**
   - A confirmation message, the results of a query, or an error message is constructed.
   - This feedback is sent back to the user via the original input channel (e.g., Telegram bot).

This pipeline ensures that natural language inputs are intelligently processed and accurately reflected in the Noloco SSoT.

*(Ensure Section 5.2 Key Modules (Conceptual) reflects any new modules or responsibilities implied by this detailed pipeline, e.g., a more explicit* `intent_classifier.py` *or ensuring* `telegram_bot_handler.py` *clearly orchestrates calls to these NLP steps.)*

## 6. Third-Party Integrations

* **Noloco:** (Now the core platform)
    * **Purpose:** Primary data store (Noloco Tables) and primary user interface platform.
    * **Integration:** Flask backend interacts via Noloco's GraphQL API. Noloco may trigger Flask via webhooks. Users interact directly via Noloco's web UI.
* **Telegram:**
    * **Purpose:** Secondary notification channel and potentially for very specific, simple inputs.
    * **Integration:** Flask backend uses Telegram Bot API.
* **Todoist:**
    * **Purpose:** Task and reminder synchronization/management.
    * **Integration:** Flask backend uses Todoist API. May receive webhooks from Todoist. Tasks in Noloco can be pushed to Todoist.
* **Google Drive:**
    * **Purpose:** Storing and managing SOP master documents.
    * **Integration:** Flask backend uses Google Drive API to create documents and manage links. Links stored in Noloco.
* **General Purpose LLM (e.g., OpenAI API):**
    * **Purpose:** NLP tasks like summarization, data extraction (for future features), and potentially natural language interaction.
    * **Integration:** Flask backend interacts with the LLM's API.

## 7. Security Considerations

* **Noloco Platform Security:** Rely on Noloco's built-in security features for user authentication, authorization, data encryption at rest and in transit. Configure user roles and permissions within Noloco carefully.
* **API Keys and Secrets:** All API keys (Noloco, Telegram, Todoist, Google, LLM) will be stored securely as environment variables and not hardcoded. Use a `.env` file for local development and secure environment variable management in production.
* **Flask Backend Security:**
    * Secure webhooks with signature verification.
    * Input validation for all data received from external sources.
    * Standard web application security practices (e.g., protection against common vulnerabilities if exposing any public endpoints).
* **Data Privacy:** Ensure compliance with relevant data privacy regulations. Sensitive data should be handled with care.

## 8. Implementation Plan / Phased Rollout (Revised)

### Phase 1: Core Setup, Noloco Configuration & NLP FLRTS Backbone (MVP Focus)

- **Objective:** Establish Noloco as the SSoT, configure its basic web UI, and implement the core natural language processing pathway via Telegram for essential FLRTS operations.
- **Key Activities:**
  1. **Finalize Noloco Data Model & UI Basics:** (As previously defined)
  2. **Develop Flask **`noloco_client.py`**:** (As previously defined)
  3. **Develop Site Setup Module (Flask):** (As previously defined)
  4. **Develop Telegram Bot & NLP FLRTS Backbone (Flask):**
     - Set up basic Telegram bot command handling in Flask.
     - Implement **Initial Intent Classification** logic.
     - Integrate with **Todoist API** for natural language task/reminder creation and sync to Noloco `Tasks`.
     - Integrate with **General Purpose LLM API** for natural language creation of Field Reports and adding items to Lists, storing results in Noloco.
     - Implement basic NLP-driven querying (e.g., view tasks).
     - Ensure robust interaction with `noloco_client.py` for all data operations.
  5. **Core FLRTS Management in Noloco Web UI:** Ensure users can also perform basic CRUD operations for all FLRTS items directly within the Noloco web interface.
- **Deliverables:**
  - Configured Noloco instance with data model and web UI for core FLRTS functions.
  - Flask backend capable of:
    - Noloco API interaction.
    - Initial site setup.
    - **Handling Telegram bot input, performing intent classification, NLP (via Todoist & General LLM), and full CRUD operations on Noloco Tables for tasks, field reports, and list items based on natural language commands.**

### Phase 2: Integrations & Enhanced Noloco UI

* **Objective:** Integrate key third-party services and refine the Noloco user experience.
* **Key Activities:**
    1.  **Todoist Integration (Flask & Noloco):**
        * Develop Flask modules for Todoist API interaction.
        * Allow tasks created in Noloco to be pushed to Todoist.
        * (Optional) Handle Todoist webhooks to update task status in Noloco.
    2.  **Telegram Notifications (Flask):**
        * Develop Flask module for sending notifications via Telegram based on events/data from Noloco (e.g., new task, report submitted).
    3.  **Refine Noloco UI:**
        * Create more advanced views, dashboards, and action buttons in Noloco.
        * Implement more granular permissions.
        * Explore Noloco workflows for in-app automations.
    4.  **LLM Integration (Basic - Flask):** Initial setup for future NLP features, e.g., a simple text processing task.
* **Deliverables:**
    * Noloco app with richer UI/UX and integrated Todoist/Telegram notification features.

### Phase 3: Testing, Deployment, and Iteration

* **Objective:** Thoroughly test the system, deploy for production use, and gather feedback for further improvements.
* **Key Activities:**
    * System testing (Flask backend, Noloco configurations, integrations).
    * User Acceptance Testing (UAT) with target users on the Noloco platform.
    * Deployment of the Flask backend to a production environment.
    * Final configuration of Noloco for production.
    * Develop user guides/training materials for the Noloco application.
    * Monitor system performance and gather user feedback.
* **Deliverables:**
    * Fully tested and deployed FLRTS system on Noloco.
    * User documentation.
    * Plan for ongoing support and future iterations.

## 9. Future Features

* **Enhanced NLP & AI Capabilities (via Flask & LLM):**
    * **LLM Interaction with SOP Google Docs:** Enable users (perhaps via a dedicated Noloco interface section that calls the Flask backend) to query SOP content or request updates.
    * **Automated Field Report Summarization/Analysis:** Use LLM to process `Field_Report` content in Noloco.
    * **"Licenses & Agreements" Parsing:** Upload agreement PDFs to Noloco, trigger Flask backend to use LLM for parsing and pre-filling fields in the corresponding Noloco record.
* **Advanced Noloco Dashboards & Reporting:** Utilize Noloco's full charting and reporting capabilities.
* **Offline Capabilities (if Noloco or PWA supports):** Explore options for offline data access or entry if critical for field users.
* **Expanded Telegram Bot Functionality:** Based on MVP feedback, selectively add more quick actions or data retrieval commands to the Telegram bot if there's a strong use case not well covered by the Noloco mobile web experience.
* **Direct Noloco Webhooks:** If Noloco enhances its webhook capabilities, utilize them to trigger Flask backend processes more directly, potentially reducing polling or complex state management.

**(Appendix A is now a separate document: "Appendix A: Noloco Table Field Definitions")**