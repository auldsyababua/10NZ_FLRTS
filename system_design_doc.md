# 10NetZero-FLRTS: System Design Document

Version: 2.1
Date: May 15, 2025

*For all LLM/AI collaboration standards, code commenting, and development philosophy, see [AI_Collaboration_Guide.md](./AI_Collaboration_Guide.md). The field definitions previously in Appendix A of this document are now maintained in a separate "Appendix A: Noloco Table Field Definitions" document.*

## 0. Document Version Control Log
* **Version 1.0-1.4:** Initial drafts and refinements focusing on an Airtable backend and Telegram MiniApp UI.
* **Version 1.5 (May 14, 2025):** Incorporated AI Collaboration Guide, Project Directives, and Appendix A refinements (Airtable-focused).
* **Version 2.0 (May 15, 2025):** Major architectural revision. Shifted primary data store to Noloco Tables and a primary UI to Noloco's web application. Appendix A updated for Noloco and moved to a separate document. Initial re-scoping of Telegram bot.
* **Version 2.1 (May 15, 2025):** Refined UI strategy, elevating the Telegram bot to a key interaction channel for field technician NLP-driven FLRTS CRUD. Detailed NLP orchestration pipeline in Flask backend. Clarified MVP scope and data flows accordingly.

## 1. Introduction

### 1.1. Purpose of the Document

This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model (implemented in Noloco Tables), user interaction flows (through the Noloco platform and a Telegram bot interface), third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements.

### 1.2. System Overview (10NetZero-FLRTS)

The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows by leveraging:
* A robust data backend provided by **Noloco Tables**, serving as the Single Source of Truth.
* A user-friendly **Noloco web application platform** for structured data interaction and administrative tasks.
* A **Telegram bot interface** optimized for low-friction, natural language-based FLRTS management by field technicians.
* A **Flask backend** to support advanced business logic, NLP orchestration, integrations not natively handled by Noloco (Todoist, Google Drive, General Purpose LLM), and to power the Telegram bot.

## 2. Goals and Objectives

### 2.1. Primary Goals

* **Centralized Data Management:** Provide a single source of truth for all FLRTS data using Noloco Tables.
* **Optimized User Interfaces:**
    * Offer an intuitive **Noloco web interface** for comprehensive data management, administrative tasks, and users preferring visual forms.
    * Provide a **low-friction, natural language-driven Telegram bot interface** for rapid, on-the-fly FLRTS creation and management by field technicians.
* **Streamlined Workflows:** Simplify and automate operational processes related to field reporting, task management, and list maintenance.
* **Effective Communication:** Ensure timely notifications and easy access to relevant information for all users, through appropriate channels.
* **Scalability & Maintainability:** Build a system that can grow with 10NetZero's needs, leveraging Noloco's platform capabilities and a well-structured Flask backend.

### 2.2. MVP Scope

The MVP will focus on delivering core FLRTS functionalities with Noloco as the SSoT and primary web UI, alongside a robust natural language interface via Telegram for field technicians.

* **Core FLRTS Modules & Data Management:**
    * All FLRTS data (Sites, Personnel, Field Reports, Lists, List Items, Tasks, Users, etc.) managed in **Noloco Tables** as the Single Source of Truth.
    * **Noloco Web Application UI:**
        * Forms, views, and basic dashboards within Noloco for creating, viewing, and managing all FLRTS items by users who prefer a web interface or require comprehensive data views (e.g., administrators, site managers).
        * User management via Noloco's built-in system, linked to `Personnel` and `Users` collections for application-specific roles.
* **Natural Language FLRTS CRUD for Field Technicians (via Telegram Bot):**
    * **Typed natural language input** (voice-to-text via OS is a user option) for creating, viewing, and performing basic updates on:
        * **Tasks & Reminders:** Leveraging direct Todoist API calls from Flask for NLP (date/time parsing) and task creation, with structured data subsequently synced to Noloco Tables.
        * **Field Reports:** Creation via narrative text input, parsed by a General Purpose LLM.
        * **List Items:** Adding items to predefined lists (e.g., Shopping Lists, Tool Inventories), parsed by a General Purpose LLM.
    * Basic querying of FLRTS items via natural language (e.g., "view my tasks for today").
* **Flask Backend:**
    * Handling all Telegram bot interactions.
    * **Initial Intent Classification** of natural language input received from Telegram.
    * **NLP Orchestration:**
        * Calling Todoist API directly for task/reminder NLP and creation.
        * Calling a General Purpose LLM API for parsing field reports and list updates.
    * All CRUD operations with Noloco Tables via its GraphQL API.
    * Programmatic generation of master SOP Google Documents for new sites and linking them in Noloco.
    * Automated initial site setup logic (default lists, SOP link).
* **Integrations (MVP Level):**
    * **Todoist API:** For NLP of task/reminder strings and backend task management, with structured task data created/updated in Noloco.
    * **Google Drive API:** For SOP document storage and linking.
    * **General Purpose LLM API:** For NLP of field reports and list updates.

## 3. Data Model and Management

### 3.1. Data Storage (Noloco Tables)

The primary data store for the 10NetZero-FLRTS system will be **Noloco Tables**. Noloco's internal database will house all collections and manage the relationships between them.

* **Collections:** Data will be organized into logical collections within Noloco (e.g., `Sites`, `Personnel`, `Field_Reports`, `Lists`, `List_Items`, `Tasks`).
* **Fields:** Each collection will have defined fields with specific Noloco data types.
* **Relationships:** Noloco's relationship field types will link records between collections.
* **Data Integrity & Validation:** Noloco's built-in field validation will be utilized. Complex validation may be enforced by the Flask backend or Noloco Workflows.
* **Views and Access Control:** Noloco's interface will be configured for appropriate views, filters, and access permissions.

**For detailed field definitions, data types, and relationships for all Noloco Collections, refer to the separate document: "Appendix A: Noloco Table Field Definitions".**

### 3.2. Data Flow

The system supports two primary data flow pathways for FLRTS item creation and modification:

1.  **Natural Language Input Pathway (Primarily for Field Technicians via Telegram):**
    * a. **User Input (Telegram):** User sends a typed natural language command to the Telegram bot.
    * b. **Flask Backend - Intent Classification:** The Flask backend receives the message and classifies the user's intent (e.g., create task, log report, update list, query data).
    * c. **Flask Backend - NLP Orchestration & External API Calls:**
        * **For Tasks/Reminders:** Flask directly calls the Todoist API's Quick Add feature with the relevant natural language string. Todoist parses it, creates the task, and returns structured task data.
        * **For Field Reports, List Updates, Other FLRTS Items:** Flask constructs a prompt for a General Purpose LLM API using the user's input. The LLM processes the text and returns structured data.
    * d. **Flask Backend - Data Structuring & Noloco Interaction:** Flask processes the structured data received from Todoist or the LLM. It then performs the necessary CRUD operations on the appropriate Noloco Tables via the Noloco GraphQL API.
    * e. **Flask Backend - User Feedback (Telegram):** Flask sends a confirmation, the result of a query, or an error message back to the user via the Telegram bot.
    * f. **Noloco Tables (SSoT):** The data is stored and managed within Noloco.

2.  **Structured Web Input Pathway (Noloco Web Application):**
    * a. **User Input (Noloco Interface):** Users interact directly with the Noloco web application using forms, list views, and action buttons.
    * b. **Noloco Internal Processing:** Noloco handles data validation and directly creates/updates records in its Noloco Tables.
    * c. **Noloco Workflows/Automations (Optional):** Noloco's native automations may trigger further actions or call external webhooks (e.g., to Flask for complex post-processing).
    * d. **Flask Backend (via Webhook - Optional):** If a Noloco workflow triggers a webhook to Flask, it can perform additional logic and update Noloco Tables via the API.
    * e. **Noloco Tables (SSoT):** Data is managed within Noloco.

In both pathways, **Noloco Tables serve as the Single Source of Truth.**

## 4. User Interface (UI) and User Experience (UX)

The system provides two distinct primary interfaces tailored to different user needs and interaction styles.

### 4.1. Primary User Interface: Noloco Web Application

The Noloco web application serves as the comprehensive primary user interface for the 10NetZero-FLRTS system, catering to a broad range of users and functionalities beyond the natural language interactions facilitated by the Telegram bot. It provides a structured, visual environment for data management, detailed record interaction, administrative tasks, and viewing consolidated information.

* **Accessibility:** Accessible via standard web browsers on desktop and mobile devices, providing a responsive experience.
* **Target Users:** Administrators, site managers, office personnel, and any field technicians needing to view detailed information, manage records through forms, or access features not optimized for a conversational interface.
* **Key Features & Purpose:**
    * **Centralized Data Hub & Single Source of Truth Access:** Provides a direct window into the Noloco Tables, allowing users with appropriate permissions to view and manage all FLRTS data.
    * **Structured Data Entry & Management:** Offers user-friendly forms for detailed creation and editing of all FLRTS records (Sites, Personnel, Users, Field Reports, Lists, List Items, Tasks, Licenses & Agreements, Equipment, ASICs, etc.). This is suitable for scenarios where detailed, field-by-field input is necessary or preferred.
    * **Comprehensive Data Views & Reporting:** Leverages Noloco's capabilities to create custom list views, detail record views, Kanban boards, calendars, and dashboards. This allows users to visualize, filter, sort, and analyze FLRTS data in various ways (e.g., view all tasks for a specific site, see field reports pending review, track equipment maintenance schedules).
    * **Administrative Functions:** Provides the interface for system administrators to manage user accounts (via Noloco's user management, linked to the `Users` and `Personnel` collections), configure system settings, and oversee data integrity.
    * **Action Buttons & Workflow Triggers:** Noloco action buttons can be configured for common operations within the web UI (e.g., "Approve Field Report," "Assign Task," "Archive Record"), which can trigger Noloco workflows or update record statuses.
    * **User Authentication & Granular Permissions:** Utilizes Noloco's built-in user authentication and role-based permission system to control access to specific data, views, and functionalities within the web application.
    * **Search and Filtering:** Provides robust tools for searching and filtering records across all collections.

The Noloco web application ensures that while field technicians have a low-friction natural language interface for on-the-fly FLRTS management, there is also a powerful and comprehensive web platform for all other users and for more detailed, structured data interactions. It is the primary interface for viewing the "bigger picture" and performing administrative or complex data management tasks.

### 4.2. Key Interaction Channel for Field Operations: Telegram Bot

The Telegram bot serves as a crucial, direct interface for field technicians to perform rapid, low-friction Create, Read, Update, and Delete (CRUD) operations on FLRTS items using typed natural language commands (for MVP). This interface is optimized for on-the-fly interactions with minimal need for navigating complex forms, addressing the primary pain point of high-friction data entry on mobile devices.

* **Accessibility:** Available on any device with Telegram installed.
* **Input Method (MVP):** Typed natural language commands. Users' mobile OS voice-to-text capabilities can naturally be used to populate the text input in Telegram.
* **Core Functionality:**
    * **Natural Language FLRTS Creation:**
        * **Tasks & Reminders:** Users can type commands like, "Tell Bryan to call Anthony tomorrow at 5pm about the new generator controls coming in." The backend will leverage Todoist's API for date/time parsing and task structuring.
        * **Field Reports:** Users can type narrative reports like, "Field report Site Gamma: Generator A running at 80% load, fuel levels nominal. Noticed slight oil sheen near pump 3." The backend uses a general LLM for parsing.
        * **List Item Additions:** Users can type commands like, "Add 'WD-40' and 'rags' to the Site Alpha shopping list."
    * **Natural Language FLRTS Querying (Basic MVP):**
        * Users can ask for their tasks (e.g., "What are my tasks for today?").
        * View specific lists (e.g., "Show me the Site Alpha shopping list").
    * **Natural Language FLRTS Updates (Basic MVP):**
        * Mark tasks as complete.
        * Make simple updates to list items if feasible via NLP.
* **Interaction Flow:**
    1.  User sends a natural language message to the Telegram bot.
    2.  The Flask backend receives the message.
    3.  Flask performs intent classification and NLP processing (using Todoist API or General LLM API as appropriate).
    4.  Flask interacts with Noloco Tables via API to perform the CRUD operation.
    5.  The Telegram bot sends a confirmation, result, or clarifying question back to the user.
* **User Experience Goal:** To make FLRTS management feel like a quick conversation rather than data entry. The interface avoids presenting users with multiple fields to fill out for common operations.

### 4.3. User Interaction Flows

User interaction flows will primarily occur through the Noloco Web Application for structured input and comprehensive views, and through the Telegram Bot for low-friction, natural language-based input, especially for field technicians.

**Example 1: Creating a Task via Telegram (Field Technician)**

1.  **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2.  **User Types:** "Remind me to inspect the main breaker at Site Bravo tomorrow morning at 9am"
3.  **Telegram Bot:** Sends message to Flask backend.
4.  **Flask Backend:**
    * Receives text.
    * Classifies intent as "create task/reminder."
    * Sends the string "inspect the main breaker at Site Bravo tomorrow morning at 9am" to the Todoist API (Quick Add).
    * Todoist API parses the string, creates a task with the description, due date (tomorrow's date), and due time (9:00 AM), and returns the structured task ID and details.
    * Flask creates a new record in the Noloco `Tasks` collection, populating fields like `TaskTitle`, `DueDate`, `Site_Link` (if "Site Bravo" can be reliably identified and linked), `AssignedTo_User_Link` (to the sending user), and stores the `TodoistTaskID`.
5.  **Telegram Bot (to User):** "OK, I've created a task: 'Inspect the main breaker at Site Bravo' for tomorrow at 9:00 AM."

**Example 2: Logging a Field Report via Telegram (Field Technician)**

1.  **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2.  **User Types:** "Field report for Site Alpha. Unit 5 chiller is cycling too frequently. Ambient temp 35C. No alarms triggered but needs investigation." (User might send a video/photo as a separate message if bot supports file handling for attachment, or mention it for manual linking later).
3.  **Telegram Bot:** Sends message (and potentially file info) to Flask backend.
4.  **Flask Backend:**
    * Receives text.
    * Classifies intent as "create field report."
    * Constructs a prompt for the General Purpose LLM, including the user's text.
    * LLM API processes the text and returns structured data (e.g., JSON identifying Site Alpha, the content of the report, mentions of "Unit 5 chiller").
    * Flask creates a new record in the Noloco `Field_Reports` collection, populating `Site_Link`, `ReportContent_Full`, `SubmittedBy_User_Link`.
5.  **Telegram Bot (to User):** "Field report for Site Alpha logged: 'Unit 5 chiller cycling too frequently...'"

**Example 3: Adding to a Shopping List via Telegram (Field Technician)**

1.  **User (Field Tech):** Opens Telegram chat with the FLRTS Bot.
2.  **User Types:** "Add three 20A fuses and a roll of electrical tape to the Site Charlie shopping list"
3.  **Telegram Bot:** Sends message to Flask backend.
4.  **Flask Backend:**
    * Receives text.
    * Classifies intent as "update list / add item."
    * Constructs a prompt for the General Purpose LLM to identify the list ("Site Charlie shopping list") and the items ("three 20A fuses," "a roll of electrical tape").
    * LLM API returns structured data.
    * Flask finds the correct `Lists` record for "Site Charlie shopping list" in Noloco.
    * Flask creates new `List_Item` records ("20A fuses" with detail "quantity: 3", "electrical tape" with detail "quantity: 1 roll") and links them to the parent list in Noloco.
5.  **Telegram Bot (to User):** "OK, added '20A fuses (3)' and 'electrical tape (1 roll)' to the Site Charlie shopping list."

**Example 4: Creating a Site Record (Administrator via Noloco Web UI)**

1.  **User (Admin):** Logs into the Noloco web application.
2.  **User:** Navigates to the "Sites" collection view.
3.  **User:** Clicks the "Add New Site" button (a Noloco action).
4.  **Noloco UI:** Displays the form for creating a new site.
5.  **User:** Fills in the required fields (SiteName, SiteID_Display, etc.) and any optional fields.
6.  **User:** Clicks "Save."
7.  **Noloco:** Creates the new site record in the `Sites` Noloco Table.
8.  **Noloco Workflow/Flask (Post-Creation Hook - if configured):**
    * This action (new site creation) might trigger a Noloco workflow.
    * The workflow could call a webhook to the Flask backend.
    * Flask backend then executes the "Initial Site Setup" logic:
        * Generates the SOP Google Document for the new site.
        * Creates default FLRTS lists (Tools, Shopping, Master Tasks) in Noloco, linking them to the new Site.
        * Updates the new `Site` record in Noloco with the SOP document link and sets `Initial_Site_Setup_Completed_by_App` to TRUE.
9.  **User (Admin):** Can view the newly created site and its linked information within the Noloco Web UI.

## 5. Backend Architecture (Flask Application)

The Flask Python backend acts as the central nervous system for intelligent processing, integrations, and interactions originating from the Telegram bot interface.

### 5.1. Core Responsibilities

* **Receiving and Processing Natural Language Commands:** Handling all input from the Telegram bot interface.
* **Initial Intent Classification:** Performing a preliminary analysis of natural language input from Telegram to determine the user's intent (e.g., create a task, log a field report, update a list, query data) before routing to specialized NLP processing.
* **NLP Orchestration & External API Integration Management:**
    * **Todoist API:** Directly calling the Todoist API (Quick Add) for natural language parsing of tasks and reminders, and synchronizing structured task data with Noloco.
    * **General Purpose LLM API (e.g., OpenAI):** Managing interactions for parsing more complex or varied natural language inputs like field reports and list updates into structured data.
    * **Google Drive API:** Programmatically generating SOP documents, managing permissions, and storing links in Noloco.
* **Noloco API Interaction:** Acting as a robust client to Noloco's GraphQL API for all programmatic CRUD (Create, Read, Update, Delete) operations on Noloco Tables based on processed data from Telegram/NLP or other internal logic.
* **Telegram Bot Logic:** Managing the conversational flow, sending messages/confirmations, and handling user interactions within Telegram.
* **Automated Site Setup:** Handling the programmatic creation of SOP documents and default lists in Noloco for new sites (can be triggered via webhook from Noloco or a manual admin action).
* **Business Logic Orchestration:** Implementing complex business rules or workflows that are not suitable for Noloco's native automations or require interaction with multiple external services.
* **Data Validation (Complex):** Enforcing backend data validation rules before writing to Noloco if Noloco's native validation is insufficient.
* **Scheduled Tasks/Cron Jobs (If Needed):** Running periodic tasks.

### 5.2. Key Modules (Conceptual)

* **`telegram_bot_handler.py`:** Manages interactions with the Telegram Bot API (receiving messages, sending replies/notifications). Orchestrates calls for intent classification and NLP processing.
* **`intent_classifier.py`:** (Or logic within `telegram_bot_handler.py`) Contains the logic for initial classification of user intent from natural language strings.
* **`nlp_service.py`:** A module that acts as a façade for different NLP backends.
    * Contains functions to call the Todoist API for task/reminder parsing.
    * Contains functions to call the General Purpose LLM API for other FLRTS types, including prompt construction.
* **`noloco_client.py`:** Dedicated module for all interactions with the Noloco GraphQL API (authentication, queries, mutations for all collections).
* **`todoist_integration.py`:** Specific logic for interacting with Todoist API beyond simple Quick Add, if needed (e.g., fetching task details, handling webhooks if Todoist is used more deeply). For MVP, primarily focused on Quick Add via `nlp_service.py`.
* **`google_drive_integration.py`:** Manages SOP document creation and linking.
* **`site_setup_module.py`:** Orchestrates the initial setup for new sites.
* **API Endpoints / Webhooks:** Flask routes for receiving webhooks from external services (e.g., Noloco, potentially Todoist post-MVP) or serving internal needs.

### 5.3. Authentication and Authorization

* **Flask Backend to Noloco:** The Flask backend will use an API key to authenticate with the Noloco GraphQL API.
* **Flask Backend to External Services (Todoist, LLM, Google):** Standard API key/OAuth authentication for each service.
* **External Services to Flask:** Webhooks received by the Flask backend will be secured (e.g., using signature verification or secret tokens).
* **Telegram Bot:** Standard Telegram bot token authentication.

### 5.4. NLP Orchestration Pipeline

A core function of the Flask backend is to process natural language commands received, typically from the Telegram bot, and translate them into structured actions and data within the Noloco SSoT. This pipeline generally follows these steps:

1.  **Input Reception:** The Flask backend receives a natural language string (e.g., from a Telegram message). Associated user information (e.g., Telegram User ID) is also received.
2.  **Initial Intent Classification:**
    * The input string is analyzed to determine the probable user intent (e.g., `CREATE_TASK`, `CREATE_FIELD_REPORT`, `Notes`, `QUERY_TASKS`).
    * This can be achieved using a combination of keyword matching, pattern recognition, or a lightweight classification model/LLM prompt.
3.  **Specialized NLP Processing (based on intent):**
    * **If Intent is `CREATE_TASK` or `Tasks/Reminders`:**
        * The relevant part of the natural language string is passed directly to the Todoist API's "Quick Add" endpoint.
        * Todoist's NLP engine parses the string, creating a task within Todoist and identifying due dates, times, recurrence, etc.
        * The Flask backend receives the structured task details (including the Todoist Task ID) from the Todoist API response.
    * **If Intent is `CREATE_FIELD_REPORT`, `Notes`, `UPDATE_LIST_ITEM`, or other intents requiring more flexible parsing:**
        * The Flask backend constructs a specific prompt tailored to the intent and the expected output structure.
        * This prompt, along with the user's natural language input, is sent to a General Purpose LLM API (e.g., OpenAI).
        * The LLM processes the input and returns structured data (typically JSON) as defined by the prompt (e.g., for a field report: `{ "site_name": "Site Alpha", "report_text": "...", "equipment_mentioned": [...] }`).
4.  **Data Validation and Structuring:**
    * The structured data received from Todoist or the LLM is validated by the Flask backend.
    * Data is mapped to the fields of the relevant Noloco Collection(s) (e.g., `Tasks`, `Field_Reports`, `List_Items`). This may involve looking up foreign keys (e.g., finding the `SiteID_PK_Noloco` for a given `site_name`, linking to the `User` record).
5.  **Noloco Database Interaction:**
    * The Flask backend uses its `noloco_client.py` module to interact with the Noloco GraphQL API.
    * The structured data is used to create new records or update existing records in the appropriate Noloco Tables.
6.  **User Feedback:**
    * A confirmation message, the results of a query, or an error message is constructed.
    * This feedback is sent back to the user via the original input channel (e.g., Telegram bot).

This pipeline ensures that natural language inputs are intelligently processed and accurately reflected in the Noloco SSoT.

## 6. Third-Party Integrations

* **Noloco:**
    * **Purpose:** Primary data store (Noloco Tables) and primary web user interface platform.
    * **Integration:** Flask backend interacts via Noloco's GraphQL API. Noloco may trigger Flask via webhooks.
* **Telegram API:**
    * **Purpose:** Key interaction channel for field technicians using natural language.
    * **Integration:** Flask backend uses Telegram Bot API.
* **Todoist API:**
    * **Purpose:** Natural language parsing for tasks/reminders (via Quick Add) and backend task management.
    * **Integration:** Flask backend uses Todoist REST API.
* **Google Drive API:**
    * **Purpose:** Storing and managing SOP master documents.
    * **Integration:** Flask backend uses Google Drive API. Links stored in Noloco.
* **General Purpose LLM (e.g., OpenAI API):**
    * **Purpose:** NLP tasks for field reports, list updates, and other complex natural language understanding needs.
    * **Integration:** Flask backend interacts with the LLM's API.

## 7. Security Considerations

* **Noloco Platform Security:** Rely on Noloco's built-in security features for user authentication, authorization, data encryption. Configure user roles and permissions carefully.
* **API Keys and Secrets:** All API keys will be stored securely as environment variables.
* **Flask Backend Security:** Secure webhooks, input validation, standard web application security practices.
* **Data Privacy:** Ensure compliance with relevant data privacy regulations.

## 8. Implementation Plan / Phased Rollout

### Phase 1: Core Setup, Noloco Configuration & NLP FLRTS Backbone (MVP Focus)

* **Objective:** Establish Noloco as the SSoT, configure its basic web UI, and implement the core natural language processing pathway via Telegram for essential FLRTS operations.
* **Key Activities:**
    1.  **Finalize Noloco Data Model & UI Basics:** Implement all collections and fields in Noloco Tables as per "Appendix A: Noloco Table Field Definitions." Manually configure relationships. Set up basic Noloco forms and views for key collections. Implement user roles.
    2.  **Develop Flask `noloco_client.py`:** Create the core module for interacting with Noloco's GraphQL API.
    3.  **Develop Site Setup Module (Flask):** Google Drive integration for SOP document creation. Logic to create default `List` records in Noloco for a new site. Mechanism to link SOP and update `Site` record in Noloco.
    4.  **Develop Telegram Bot & NLP FLRTS Backbone (Flask):**
        * Set up basic Telegram bot command handling in Flask.
        * Implement **Initial Intent Classification** logic.
        * Integrate with **Todoist API** for natural language task/reminder creation and sync to Noloco `Tasks`.
        * Integrate with **General Purpose LLM API** for natural language creation of Field Reports and adding items to Lists, storing results in Noloco.
        * Implement basic NLP-driven querying (e.g., view tasks).
        * Ensure robust interaction with `noloco_client.py` for all data operations.
    5.  **Core FLRTS Management in Noloco Web UI:** Ensure users can also perform basic CRUD operations for all FLRTS items directly within the Noloco web interface for consistency and alternative access.
* **Deliverables:**
    * Configured Noloco instance with data model and web UI for core FLRTS functions.
    * Flask backend capable of:
        * Noloco API interaction.
        * Initial site setup.
        * Handling Telegram bot input, performing intent classification, NLP (via Todoist & General LLM), and full CRUD operations on Noloco Tables for tasks, field reports, and list items based on natural language commands.

### Phase 2: Integrations & Enhanced Noloco UI

* **Objective:** Refine integrations and the Noloco user experience.
* **Key Activities:**
    1.  **Refine Telegram Bot Interactions:** Improve conversational flow, error handling, and feedback. Expand query capabilities.
    2.  **Refine Noloco UI:** Create more advanced views, dashboards, and action buttons. Implement more granular permissions. Explore Noloco workflows for in-app automations.
    3.  **Deeper Todoist Synchronization (Post-MVP):** Explore two-way sync if needed, or handling task updates from Todoist via webhooks.
    4.  **LLM Integration Enhancements (Post-MVP):** More sophisticated parsing, summarization of field reports displayed in Noloco, etc.
* **Deliverables:**
    * More polished Noloco app and Telegram bot with enhanced features.

### Phase 3: Testing, Deployment, and Iteration

* **Objective:** Thoroughly test the system, deploy for production use, and gather feedback.
* **Key Activities:** System testing, User Acceptance Testing (UAT), Flask backend deployment, final Noloco configuration, user guides, monitoring.
* **Deliverables:** Fully tested and deployed FLRTS system, user documentation, support plan.

## 9. Future Features

* **Enhanced NLP & AI Capabilities (via Flask & LLM):**
    * LLM Interaction with SOP Google Docs (querying, suggesting updates).
    * Automated Field Report Summarization/Analysis displayed in Noloco.
    * "Licenses & Agreements" parsing and field pre-filling in Noloco.
* **Advanced Noloco Dashboards & Reporting.**
* **Offline Capabilities (if feasible and critical).**
* **Expanded Telegram Bot Functionality:** More complex queries, interactive components (keyboards).
* **Direct Noloco Webhooks for more complex workflows if capabilities expand.**

**(Appendix A is now a separate document: "Appendix A: Noloco Table Field Definitions")**