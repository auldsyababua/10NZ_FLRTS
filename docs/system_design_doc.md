# 10NetZero-FLRTS: System Design Document

Version: 3.0
Date: May 20, 2025

*For all LLM/AI collaboration standards, code commenting, and development philosophy, see [AI_Collaboration_Guide.md](./AI_Collaboration_Guide.md). The field definitions previously in Appendix A of this document are now maintained in separate SQL schema documentation.*

## 0. Document Version Control Log
* **Version 1.0-1.4:** Initial drafts and refinements focusing on an Airtable backend and Telegram MiniApp UI.
* **Version 1.5 (May 14, 2025):** Incorporated AI Collaboration Guide, Project Directives, and Appendix A refinements (Airtable-focused).
* **Version 2.0 (May 15, 2025):** Major architectural revision. Shifted primary data store to Noloco Tables and a primary UI to Noloco's web application. Appendix A updated for Noloco and moved to a separate document. Initial re-scoping of Telegram bot.
* **Version 2.1 (May 15, 2025):** Refined UI strategy, elevating the Telegram bot to a key interaction channel for field technician NLP-driven FLRTS CRUD. Detailed NLP orchestration pipeline in Flask backend. Clarified MVP scope and data flows accordingly.
* **Version 3.0 (May 20, 2025):** Major architectural change. Migrated from Noloco Tables to Supabase PostgreSQL as the primary data store. Implemented robust relational database schema with PostgreSQL functions for business logic. Updated data flows and integration points.

## 1. Introduction

### 1.1. Purpose of the Document

This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model (implemented in Supabase PostgreSQL), user interaction flows (through the Noloco platform and a Telegram bot interface), third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements.

### 1.2. System Overview (10NetZero-FLRTS)

The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows by leveraging:
* A robust PostgreSQL database in **Supabase**, serving as the Single Source of Truth.
* A user-friendly **Noloco web application platform** for structured data interaction and administrative tasks, connected to Supabase.
* A **Telegram bot interface** optimized for low-friction, natural language-based FLRTS management by field technicians.
* A **Flask backend** to support advanced business logic, NLP orchestration, integrations not natively handled by Noloco (Todoist, Google Drive, General Purpose LLM), and to power the Telegram bot.

### 1.3 Stack and Dependencies

#### Core Platforms & Services:

1.  **Supabase:**
    * **Role:** Acts as the Single Source of Truth (SSoT) with PostgreSQL for data storage.
    * **Interface:** Supabase REST/GraphQL API.
    * *Note: This is a PaaS; use its current version.*

2.  **Noloco:**
    * **Role:** Provides the primary web UI connected to the Supabase database.
    * **Interface:** Noloco configuration to connect to Supabase.
    * *Note: This is a PaaS; use its current version.*

3.  **Telegram:**
    * **Role:** Provides the bot interface for field technician interaction using natural language.
    * **Interface:** Telegram Bot API.
    * *Note: This is a PaaS; use its current API version.*

4.  **Todoist:**
    * **Role:** Used for its NLP capabilities (Quick Add) for parsing tasks/reminders and for backend task management.
    * **Interface:** Todoist REST API.
    * *Note: This is a PaaS; use its current API version.*

5.  **Google Drive:**
    * **Role:** Storage and management of Standard Operating Procedure (SOP) documents.
    * **Interface:** Google Drive API.
    * *Note: This is a PaaS; use its current API version.*

6.  **General Purpose LLM Provider (e.g., OpenAI):**
    * **Role:** Handles NLP for parsing field reports, list updates, and other complex natural language inputs.
    * **Interface:** Provider-specific API (e.g., OpenAI API, using models like GPT-4 or as defined by `LLM_MODEL_NAME`).
    * *Note: This is a PaaS; use its current API version.*

#### Backend Development (Python Flask Application):

1.  **Programming Language:**
    * **Python:**
        * **Role:** The language for the entire backend.
        * **Version:** Specified as 3.x. *Advise user to target a recent stable version (e.g., 3.9+).*

2.  **Web Framework:**
    * **Flask:**
        * **Role:** The core web framework for building the backend API, handling bot logic, and orchestrating services.
        * *Version: Recommend latest stable (e.g., Flask 2.x or 3.x).*

3.  **Key Python Libraries:**
    * **`requests`:** For all general-purpose HTTP requests to external APIs. *Version: Latest stable.*
    * **`python-telegram-bot`** (or a similar library like `aiogram`): For Telegram Bot API interaction. *Version: Latest stable, ensure compatibility.*
    * **`google-api-python-client` / `google-auth`:** For Google Drive API interaction. *Version: Latest stable.*
    * **`openai`** (if OpenAI is the chosen provider): Client library for their API. *Version: Latest stable.*
    * **`python-dotenv`:** For managing environment variables from `.env` files. *Version: Latest stable.*
    * **`supabase-py`:** Client library for Supabase interaction. *Version: Latest stable.*
    * **`psycopg2` or `asyncpg`:** For direct PostgreSQL interaction if needed. *Version: Latest stable.*
    * **`Guidance` (Referred to by user as "windows docs"):**
        * **Role:** Being added/considered for orchestrating LLM prompts and embedding control flow for LLM interactions.
        * *Version: Check latest stable if adopted.*
    * **`Guardrails AI`:**
        * **Role:** Being added/considered for validating the structure and type of LLM outputs, particularly for ensuring reliable JSON.
        * *Version: Check latest stable if adopted.*
    * **Standard Libraries:** `json`, `os`, `logging` (built-in).

4.  **WSGI Server (for production):**
    * **E.g., `Gunicorn` or `Waitress`:** To run the Flask application in a production environment. *Version: Latest stable.*

#### Data Formats & Protocols:

1.  **REST APIs:** For most service interactions (Supabase, Todoist).
2.  **GraphQL:** Optional for Supabase API.
3.  **JSON:** For most API request/response payloads.
4.  **SQL:** For direct PostgreSQL operations.

#### Hosting Platform for Flask Backend:

* **Role:** Environment where the Python Flask application will be deployed and run.
* *Note: Specific platform (e.g., PythonAnywhere, Heroku, AWS, Google Cloud) is yet to be finalized by the user.*

## 2. Goals and Objectives

### 2.1. Primary Goals

* **Centralized Data Management:** Provide a single source of truth for all FLRTS data using Supabase PostgreSQL.
* **Robust Business Logic:** Implement business rules directly in the database using PostgreSQL functions and triggers.
* **Optimized User Interfaces:**
    * Offer an intuitive **Noloco web interface** for comprehensive data management, administrative tasks, and users preferring visual forms.
    * Provide a **low-friction, natural language-driven Telegram bot interface** for rapid, on-the-fly FLRTS creation and management by field technicians.
* **Streamlined Workflows:** Simplify and automate operational processes related to field reporting, task management, and list maintenance.
* **Effective Communication:** Ensure timely notifications and easy access to relevant information for all users, through appropriate channels.
* **Scalability & Maintainability:** Build a system that can grow with 10NetZero's needs, leveraging Supabase's capabilities and a well-structured Flask backend.

### 2.2. MVP Scope

The MVP will focus on delivering core FLRTS functionalities with Supabase as the SSoT, Noloco as the primary web UI, alongside a robust natural language interface via Telegram for field technicians.

* **Core FLRTS Modules & Data Management:**
    * All FLRTS data (Sites, Personnel, Field Reports, Lists, List Items, Tasks, FLRTS_Users, etc.) managed in **Supabase PostgreSQL** as the Single Source of Truth.
    * **Markup Manager Business Logic** implemented directly in PostgreSQL using functions and triggers.
    * **Noloco Web Application UI:**
        * Forms, views, and basic dashboards within Noloco connected to Supabase for creating, viewing, and managing all FLRTS items.
        * User management via Noloco's built-in system, linked to `personnel` and `flrts_users` tables.
* **Natural Language FLRTS CRUD for Field Technicians (via Telegram Bot):**
    * **Typed natural language input** (voice-to-text via OS is a user option) for creating, viewing, and performing basic updates on:
        * **Tasks & Reminders:** Leveraging direct Todoist API calls from Flask for NLP (date/time parsing) and task creation, with structured data subsequently synced to Supabase.
        * **Field Reports:** Creation via narrative text input, parsed by a General Purpose LLM.
        * **List Items:** Adding items to predefined lists (e.g., Shopping Lists, Tool Inventories), parsed by a General Purpose LLM.
    * Basic querying of FLRTS items via natural language (e.g., "view my tasks for today").
* **Flask Backend:**
    * Handling all Telegram bot interactions.
    * **Initial Intent Classification** of natural language input received from Telegram.
    * **NLP Orchestration:**
        * Calling Todoist API directly for task/reminder NLP and creation.
        * Calling a General Purpose LLM API for parsing field reports and list updates.
    * All CRUD operations with Supabase via its API.
    * Programmatic generation of master SOP Google Documents for new sites and linking them in Supabase.
    * Automated initial site setup logic (default lists, SOP link).
* **Integrations (MVP Level):**
    * **Todoist API:** For NLP of task/reminder strings and backend task management, with structured task data created/updated in Supabase.
    * **Google Drive API:** For SOP document storage and linking.
    * **General Purpose LLM API:** For NLP of field reports and list updates.

## 3. Data Model and Management

### 3.1. Data Storage (Supabase PostgreSQL)

The primary data store for the 10NetZero-FLRTS system will be **Supabase PostgreSQL**. Supabase's PostgreSQL database will house all tables and manage the relationships between them.

* **Tables:** Data will be organized into logical tables within PostgreSQL (e.g., `sites`, `personnel`, `field_reports`, `lists`, `list_items`, `tasks`).
* **Fields:** Each table will have defined columns with specific PostgreSQL data types.
* **Relationships:** Foreign keys and constraints will ensure proper relationships between tables.
* **Indexes:** Appropriate indexes will optimize query performance.
* **Data Integrity & Validation:** PostgreSQL's constraints (NOT NULL, UNIQUE, CHECK) and triggers will enforce data integrity.
* **Business Logic:** PostgreSQL functions and triggers will implement complex business rules like markup calculations.
* **Views:** Predefined views will simplify common queries and reports.

**For detailed schema definitions, data types, relationships, and PostgreSQL implementation, refer to the SQL schema files in the repository.**

### 3.2. Data Flow

The system supports two primary data flow pathways for FLRTS item creation and modification:

1.  **Natural Language Input Pathway (Primarily for Field Technicians via Telegram):**
    * a. **User Input (Telegram):** User sends a typed natural language command to the Telegram bot.
    * b. **Flask Backend - Intent Classification:** The Flask backend receives the message and classifies the user's intent (e.g., create task, log report, update list, query data).
    * c. **Flask Backend - NLP Orchestration & External API Calls:**
        * **For Tasks/Reminders:** Flask directly calls the Todoist API's Quick Add feature with the relevant natural language string. Todoist parses it, creates the task, and returns structured task data.
        * **For Field Reports, List Updates, Other FLRTS Items:** Flask constructs a prompt for a General Purpose LLM API using the user's input. The LLM processes the text and returns structured data.
    * d. **Flask Backend - Data Structuring & Supabase Interaction:** Flask processes the structured data received from Todoist or the LLM. It then performs the necessary CRUD operations on the appropriate Supabase tables via the Supabase API.
    * e. **Flask Backend - User Feedback (Telegram):** Flask sends a confirmation, the result of a query, or an error message back to the user via the Telegram bot.
    * f. **Supabase PostgreSQL (SSoT):** The data is stored and managed within Supabase.

2.  **Structured Web Input Pathway (Noloco Web Application):**
    * a. **User Input (Noloco Interface):** Users interact directly with the Noloco web application using forms, list views, and action buttons.
    * b. **Noloco to Supabase Direct:** Noloco handles sending the data directly to Supabase via configured connections.
    * c. **Supabase Automated Processing:** PostgreSQL triggers and functions automatically process the data (e.g., calculate markups, create related records).
    * d. **Flask Backend (via Webhook - Optional):** If complex post-processing is needed, Supabase can trigger a webhook to Flask.
    * e. **Supabase PostgreSQL (SSoT):** Data is managed within Supabase.

In both pathways, **Supabase PostgreSQL serves as the Single Source of Truth.**

## 4. User Interface (UI) and User Experience (UX)

The system provides two distinct primary interfaces tailored to different user needs and interaction styles.

### 4.1. Primary User Interface: Noloco Web Application

The Noloco web application serves as the comprehensive primary user interface for the 10NetZero-FLRTS system, connected to the Supabase database.

* **Accessibility:** Accessible via standard web browsers on desktop and mobile devices, providing a responsive experience.
* **Target Users:** Administrators, site managers, office personnel, and any field technicians needing to view detailed information, manage records through forms, or access features not optimized for a conversational interface.
* **Key Features & Purpose:**
    * **Centralized Data Hub & Single Source of Truth Access:** Provides a direct window into the Supabase database, allowing users with appropriate permissions to view and manage all FLRTS data.
    * **Structured Data Entry & Management:** Offers user-friendly forms for detailed creation and editing of all FLRTS records.
    * **Comprehensive Data Views & Reporting:** Leverages Noloco's capabilities to create custom list views, detail record views, Kanban boards, calendars, and dashboards.
    * **Administrative Functions:** Provides the interface for system administrators to manage user accounts.
    * **Action Buttons & Workflow Triggers:** Noloco action buttons can be configured for common operations within the web UI.
    * **User Authentication & Granular Permissions:** Utilizes Noloco's built-in user authentication and role-based permission system.
    * **Search and Filtering:** Provides robust tools for searching and filtering records across all collections.

### 4.2. Key Interaction Channel for Field Operations: Telegram Bot

The Telegram bot serves as a crucial, direct interface for field technicians to perform rapid, low-friction CRUD operations on FLRTS items using typed natural language commands.

* **Accessibility:** Available on any device with Telegram installed.
* **Input Method (MVP):** Typed natural language commands. Users' mobile OS voice-to-text capabilities can naturally be used to populate the text input in Telegram.
* **Core Functionality:**
    * **Natural Language FLRTS Creation:**
        * **Tasks & Reminders:** Users can type commands like, "Tell Bryan to call Anthony tomorrow at 5pm about the new generator controls coming in."
        * **Field Reports:** Users can type narrative reports like, "Field report Site Gamma: Generator A running at 80% load, fuel levels nominal. Noticed slight oil sheen near pump 3."
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
    4.  Flask interacts with Supabase via API to perform the CRUD operation.
    5.  The Telegram bot sends a confirmation, result, or clarifying question back to the user.
* **User Experience Goal:** To make FLRTS management feel like a quick conversation rather than data entry.

## 5. Backend Architecture (Flask Application)

The Flask Python backend acts as the central nervous system for intelligent processing, integrations, and interactions originating from the Telegram bot interface.

### 5.1. Core Responsibilities

* **Receiving and Processing Natural Language Commands:** Handling all input from the Telegram bot interface.
* **Initial Intent Classification:** Performing a preliminary analysis of natural language input from Telegram.
* **NLP Orchestration & External API Integration Management:**
    * **Todoist API:** Directly calling the Todoist API (Quick Add) for natural language parsing of tasks and reminders.
    * **General Purpose LLM API (e.g., OpenAI):** Managing interactions for parsing more complex natural language inputs.
    * **Google Drive API:** Programmatically generating SOP documents, managing permissions, and storing links in Supabase.
* **Supabase API Interaction:** Acting as a robust client to Supabase's API for all programmatic CRUD operations.
* **Telegram Bot Logic:** Managing the conversational flow, sending messages/confirmations, and handling user interactions.
* **Automated Site Setup:** Handling the programmatic creation of SOP documents and default lists.
* **Business Logic Orchestration:** Implementing complex business rules or workflows that require interaction with multiple external services.

### 5.2. Key Modules (Conceptual)

* **`telegram_bot_handler.py`:** Manages interactions with the Telegram Bot API.
* **`intent_classifier.py`:** Contains the logic for initial classification of user intent from natural language strings.
* **`nlp_service.py`:** A module that acts as a façade for different NLP backends.
* **`supabase_client.py`:** Dedicated module for all interactions with the Supabase API.
* **`todoist_integration.py`:** Specific logic for interacting with Todoist API.
* **`google_drive_integration.py`:** Manages SOP document creation and linking.
* **`site_setup_module.py`:** Orchestrates the initial setup for new sites.
* **API Endpoints / Webhooks:** Flask routes for receiving webhooks from external services.

### 5.3. Authentication and Authorization

* **Flask Backend to Supabase:** The Flask backend will use API keys or JWT tokens to authenticate with Supabase.
* **Flask Backend to External Services (Todoist, LLM, Google):** Standard API key/OAuth authentication for each service.
* **External Services to Flask:** Webhooks received by the Flask backend will be secured.
* **Telegram Bot:** Standard Telegram bot token authentication.

### 5.4. NLP Orchestration Pipeline

A core function of the Flask backend is to process natural language commands received, typically from the Telegram bot, and translate them into structured actions and data within the Supabase SSoT. This pipeline generally follows these steps:

1.  **Input Reception:** The Flask backend receives a natural language string (e.g., from a Telegram message).
2.  **Initial Intent Classification:** The input string is analyzed to determine the probable user intent.
3.  **Specialized NLP Processing (based on intent):**
    * **If Intent is `CREATE_TASK` or `Tasks/Reminders`:** The string is passed to the Todoist API's "Quick Add" endpoint.
    * **If Intent is for other FLRTS items:** The Flask backend constructs a prompt for a General Purpose LLM API.
4.  **Data Validation and Structuring:** The structured data is validated and mapped to Supabase tables.
5.  **Supabase Database Interaction:** The Flask backend interacts with the Supabase API to perform CRUD operations.
6.  **User Feedback:** A confirmation or response is sent back to the user via Telegram.

## 6. Third-Party Integrations

* **Supabase:**
    * **Purpose:** Primary data store (PostgreSQL) with built-in authentication and APIs.
    * **Integration:** Flask backend interacts via Supabase's REST or GraphQL API.
* **Noloco:**
    * **Purpose:** Primary web user interface platform.
    * **Integration:** Configured to connect directly to Supabase.
* **Telegram API:**
    * **Purpose:** Key interaction channel for field technicians using natural language.
    * **Integration:** Flask backend uses Telegram Bot API.
* **Todoist API:**
    * **Purpose:** Natural language parsing for tasks/reminders (via Quick Add) and backend task management.
    * **Integration:** Flask backend uses Todoist REST API.
* **Google Drive API:**
    * **Purpose:** Storing and managing SOP master documents.
    * **Integration:** Flask backend uses Google Drive API. Links stored in Supabase.
* **General Purpose LLM (e.g., OpenAI API):**
    * **Purpose:** NLP tasks for field reports, list updates, and other complex natural language understanding needs.
    * **Integration:** Flask backend interacts with the LLM's API.

## 7. Security Considerations

* **Supabase Security:** Leverage Supabase's built-in security features including:
  * **Row-Level Security (RLS):** Implement fine-grained access control directly in PostgreSQL
  * **JWT Authentication:** Secure API access with JWT tokens
  * **Encryption:** Utilize PostgreSQL's encryption capabilities for sensitive data
* **API Keys and Secrets:** All API keys stored securely as environment variables
* **Flask Backend Security:** Secure webhooks, input validation, standard web application security practices
* **Data Privacy:** Ensure compliance with relevant data privacy regulations

## 8. Markup Manager Implementation

### 8.1 Business Logic

The Markup Manager is a critical business function implemented directly in PostgreSQL using functions and triggers.

1. **Core Workflow:**
   * A vendor invoice is created and associated with a specific site
   * The system automatically looks up the partner associated with that site
   * The system applies the markup percentage from the site-partner assignment
   * The final amount is calculated (original amount + markup)
   * A partner billing record is created with the marked-up amount

2. **Key Components:**
   * **PostgreSQL Functions:**
     * `get_site_partner_markup(site_uuid, partner_uuid)`: Retrieves markup percentage
     * `calculate_invoice_markup(invoice_uuid)`: Calculates markup amounts
     * `create_partner_billing(invoice_uuid)`: Creates billing records
   * **PostgreSQL Triggers:**
     * `after_vendor_invoice_insert`: Processes new invoices
     * `after_vendor_invoice_update`: Handles invoice updates
     * `after_site_partner_assignment_update`: Updates invoices when markup percentages change

3. **Benefits of Database Implementation:**
   * **Data Integrity:** Business rules enforced at the database level
   * **Consistency:** Logic applied uniformly regardless of API or interface used
   * **Performance:** Calculations performed close to the data
   * **Auditability:** Changes tracked within the database

## 9. Implementation Plan / Phased Rollout

### Phase 1: Supabase Database Setup & Core Logic Implementation

* **Objective:** Establish Supabase as the SSoT and implement core database functionality
* **Key Activities:**
    1. Create PostgreSQL schema with tables, relationships, and constraints
    2. Implement PostgreSQL functions and triggers for business logic (Markup Manager)
    3. Set up indexes and views for performance and reporting
    4. Create data migration scripts to import from CSVs
    5. Configure Row-Level Security for data access control

### Phase 2: Noloco Integration & Flask Backend Update

* **Objective:** Connect Noloco to Supabase and update Flask backend
* **Key Activities:**
    1. Configure Noloco to connect to Supabase
    2. Update Flask backend to use Supabase API
    3. Test Telegram bot with new backend
    4. Implement enhanced NLP functionality

### Phase 3: Testing, Deployment, and Iteration

* **Objective:** Thoroughly test the system, deploy for production use, and gather feedback
* **Key Activities:** System testing, User Acceptance Testing (UAT), Flask backend deployment, user guides, monitoring

## 10. Future Features

* **Enhanced Analytical Capabilities:**
  * Leverage PostgreSQL for complex data analysis
  * Implement materialized views for performance-intensive reports
* **Advanced PostgreSQL Features:**
  * Implement partitioning for large tables
  * Utilize full-text search capabilities
  * Create specialized indexes for performance
* **Expanded Telegram Bot Functionality:**
  * More complex queries using PostgreSQL's capabilities
  * Rich interactive components
* **API Expansion:**
  * Create a comprehensive REST API for third-party integrations
  * Implement GraphQL endpoints for flexible data access