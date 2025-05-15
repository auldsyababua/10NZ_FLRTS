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

* **Core FLRTS Modules:**
    * Field Reports: Creation, submission, viewing, and basic status tracking within Noloco.
    * Lists (Tools, Shopping, Master Task Lists): Creation, item management, and viewing within Noloco. Site-specific lists auto-generated upon site creation.
    * Tasks & Subtasks: Creation, assignment (to users defined in Noloco), status updates, and viewing within Noloco. Potential integration with Todoist.
    * Reminders: Creation and viewing within Noloco. Potential integration with Todoist.
* **User Management:** Utilize Noloco's built-in user management, potentially augmented by the `Personnel` and `Users` collections for application-specific roles and Telegram IDs (if Telegram bot functionality is retained for notifications/specific actions).
* **Basic Reporting/Views:** Leverage Noloco's capabilities to provide views and filters for FLRTS data.
* **SOP Document Generation & Linking:** Flask application to programmatically generate a master SOP Google Document for each new site and link it within the site's record in Noloco.
* **Flask Backend:** To handle SOP generation, initial site setup logic, and any necessary integrations or complex business rules not achievable directly within Noloco.
* **Telegram Bot (Reduced Scope):** Primarily for notifications triggered by events in Noloco (via Flask backend or Noloco webhooks if available) or for very specific, quick interactions if deemed necessary. The Telegram MiniApp as a full UI is deprioritized for the MVP in favor of the Noloco web interface.

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

1.  **User Input (Noloco Interface):** Users primarily interact with the system via forms, lists, and views configured in the Noloco web application. Data is created or updated directly in Noloco Tables.
2.  **User Input (Telegram Bot - Secondary):** For any retained Telegram functionality (e.g., quick report snippet, task update), the Telegram bot communicates with the Flask backend.
3.  **Flask Backend Processing:**
    * Receives data from the Telegram bot (if applicable).
    * Performs business logic, validation, and data transformation.
    * Interacts with Noloco Tables via the Noloco API (GraphQL) to create, read, update, or delete records.
    * Handles integrations with other services (Todoist, Google Drive, LLM) based on triggers or data from Noloco.
    * Generates SOP documents and links them in Noloco.
    * Can be triggered by Noloco webhooks (if configured) for reactive processing.
4.  **Noloco Workflows/Automations:** Noloco's native automation capabilities may be used for simpler in-app logic, notifications, or data updates that don't require the Flask backend.
5.  **Data Display (Noloco Interface):** Users view and manage data through the configured Noloco interface.
6.  **Notifications:**
    * Noloco may provide its own in-app or email notifications.
    * The Flask backend can send notifications via Telegram or other channels based on system events or data changes in Noloco.

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

### 4.2. Secondary User Interface (Telegram Bot - Reduced Scope)

The Telegram bot's role will be significantly reduced compared to the initial concept. It will primarily serve as:

* **Notification Channel:** Receiving alerts and updates triggered by events within the FLRTS system (e.g., new task assignment, reminder due, report submitted/actioned). These notifications will likely be orchestrated by the Flask backend based on data from Noloco.
* **Quick Input/Actions (Optional, Post-MVP or if high-value):** Potentially allow for very simple, structured inputs like submitting a quick voice note for a field report snippet, or responding to a yes/no prompt. This will depend on the ease of integration and clear user benefit compared to using the Noloco web app.
* **No MiniApp for MVP:** The development of a full Telegram MiniApp UI is deprioritized for the MVP.

### 4.3. User Interaction Flows

User interaction flows will be redesigned to center around the Noloco web interface. Examples:

* **Creating a Field Report:**
    1.  User logs into the Noloco web application.
    2.  Navigates to the "Field Reports" section.
    3.  Clicks "Add New Field Report."
    4.  Fills out the form (Site, Report Type, Content, attaches files) provided by Noloco.
    5.  Clicks "Submit." The record is saved in the `Field_Reports` Noloco Collection.
    6.  Relevant personnel may be notified (via Noloco notification or Telegram via Flask).
* **Managing a Site's Tool List:**
    1.  Site Manager logs into Noloco.
    2.  Navigates to the specific `Site` record.
    3.  Accesses the linked "Tools List" (a `List` record of type "Tools Inventory").
    4.  Adds, edits, or removes `List_Item` records associated with that list.
* **Initial Site Setup:**
    1.  Admin creates a new `Site` record in Noloco.
    2.  This action (potentially via a Noloco webhook to Flask, or a manual trigger) initiates a process in the Flask backend.
    3.  Flask backend:
        * Generates the SOP Google Document.
        * Creates default FLRTS lists for the site (Tools, Shopping, Master Tasks) in Noloco, linking them to the Site.
        * Updates the `Site` record in Noloco with the SOP document link and sets the `Initial_Site_Setup_Completed_by_App` flag to TRUE.

## 5. Backend Architecture (Flask Application)

The Flask Python backend will continue to play a crucial role, focusing on logic and integrations that are complex or external to Noloco's native capabilities.

### 5.1. Core Responsibilities

* **Business Logic Orchestration:** Implementing complex business rules and workflows that span multiple steps or services.
* **Third-Party API Integration Management:**
    * **Todoist:** Creating tasks/reminders in Todoist based on FLRTS data in Noloco, and potentially handling webhooks from Todoist to update Noloco.
    * **Google Drive:** Programmatically generating SOP documents, managing permissions, and storing links in Noloco.
    * **General Purpose LLM:** Sending data for NLP processing (e.g., summarizing field reports, parsing data for future features) and updating Noloco with the results.
* **Noloco API Interaction:** Acting as a client to Noloco's GraphQL API for programmatic CRUD operations on Noloco Tables when triggered by external events (e.g., Telegram bot command, webhook from another service) or internal scheduled jobs.
* **Telegram Bot Handler:** Processing incoming messages/commands from the Telegram bot and sending outgoing notifications/messages via the Telegram Bot API.
* **Automated Site Setup:** Handling the programmatic creation of SOP documents and default lists for new sites.
* **Data Validation (Complex):** Enforcing complex data validation rules before writing to Noloco if Noloco's native validation is insufficient.
* **Scheduled Tasks/Cron Jobs:** Running periodic tasks (e.g., data aggregation, report generation if not handled by Noloco).

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

### Phase 1: Core Setup & Noloco Configuration (MVP Focus)

* **Objective:** Establish Noloco as the central hub.
* **Key Activities:**
    1.  **Finalize Noloco Data Model:** Implement all collections and fields in Noloco Tables as per "Appendix A: Noloco Table Field Definitions." Manually configure relationships.
    2.  **Configure Noloco UI:**
        * Set up basic forms for creating/editing records in key collections (Sites, Personnel, Users, Field Reports, Lists, List Items, Tasks).
        * Create list views and detail views for these collections.
        * Implement user roles and basic permissions within Noloco.
    3.  **Develop Flask `noloco_client.py`:** Create the core module for interacting with Noloco's GraphQL API (authentication, basic CRUD).
    4.  **Develop Site Setup Module (Flask):**
        * Google Drive integration for SOP document creation.
        * Logic to create default `List` records in Noloco for a new site.
        * Mechanism to link SOP and update `Site` record in Noloco.
    5.  **Basic Field Report & Task Management in Noloco:** Ensure users can create, view, and update basic field reports and tasks directly within Noloco.
* **Deliverables:**
    * Configured Noloco instance with data model and basic UI for core FLRTS functions.
    * Flask backend capable of Noloco API interaction and initial site setup.

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