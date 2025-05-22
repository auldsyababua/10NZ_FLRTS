# 10NetZero-FLRTS: System Design Document

Version: 1.5 (Incorporated AI Collaboration Guide, Project Directives, and Appendix A refinements)  
Date: May 14, 2025

*For all LLM/AI collaboration standards, code commenting, and development philosophy, see [AI_Collaboration_Guide.md](./AI_Collaboration_Guide.md).*

## 1. Introduction

### 1.1. Purpose of the Document

This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model, user interaction flows, third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements.

### 1.2. System Overview (10NetZero-FLRTS)

The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows for users, particularly those in field operations, by leveraging natural language processing, a robust data backend, and seamless integration with tools like Telegram and Todoist. The system will feature a Telegram bot and MiniApp as the primary user interfaces, supported by a Flask backend, Airtable databases, and AI capabilities for parsing. Integration of specialized AI for document-based knowledge work (like SiteGPT concepts) is deferred post-MVP. This system integrates and expands upon concepts from the user's "10NetZero Integrated Platform Design (TgBot + SiteGPT)" document.

### 1.3. Core Goals

* **Centralized Data Management:** Establish a single source of truth for core business entities and FLRTS items.
* **Intuitive User Experience:** Prioritize natural language input and conversational interfaces for ease of use, especially on mobile devices.
* **Efficient Workflow Automation:** Streamline the creation, assignment, and tracking of FLRTS items.
* **Seamless Integration:** Leverage existing tools like Todoist for their strengths in task management and reminders.
* **Scalability and Maintainability:** Design a modular architecture that can adapt to future needs and growth.

## 2. System Architecture

### 2.1. Key Components

The 10NetZero-FLRTS system comprises the following key components:

1. **Telegram Bot & MiniApp (Primary User Interface):**
    * Built using the Telegram Bot API.
    * MiniApp for richer UI interactions within Telegram (e.g., displaying lists, review/confirmation screens).
    * Handles user input (natural language, button interactions) and displays system responses.

2. **Flask Backend (Application Server):**
    * Python-based web server using the Flask framework.
    * Hosts the API endpoints for the Telegram bot/MiniApp.
    * Orchestrates interactions between other components (LLM, Todoist, Airtable, Google Drive for SOPs).
    * Manages business logic, user authentication (for web admin UI), and permissions.

3. **General Purpose LLM (e.g., OpenAI API):**
    * Used for parsing natural language input from users to create structured FLRTS data.
    * Identifies item types, extracts entities (titles, descriptions, sites, assignees, dates), and prepares text for Todoist.

4. **Todoist (Task Management & Reminders):**
    * Integrated via its API.
    * Handles detailed NLP for dates, times, and recurring patterns for tasks and reminders.
    * Manages the lifecycle of tasks (creation, completion) and the delivery of reminders.
    * Serves as the source of truth for due dates and completion status of tasks managed within it.

5. **Airtable (Data Storage):**
    * **10NetZero_Main_Datastore Base:** The central repository for master data (Sites, Personnel, Partners, Vendors, etc.).
    * **10NetZero-FLRTS Base:** Stores operational data specific to the FLRTS application, including FLRTS_Items and synced master data.

6. **Admin Web UI (Conceptual for MVP):**
    * A separate web interface for administrators to manage users, permissions, system settings, and potentially view/manage FLRTS items in bulk.

7. **Google Drive (SOP Document Storage):**
    * Integrated via its API.
    * Used to automatically create, store, and manage Standard Operating Procedure (SOP) documents for each site.
    * Links to these documents are stored in the Sites table in Airtable.

### 2.2. High-Level Data Flow for FLRTS Creation (Natural Language via Telegram)

1. **User Input:** User sends a natural language command to the Telegram bot/MiniApp.
2. **Flask Backend:** Receives the input.
3. **General LLM Processing:** Backend sends raw text to the General LLM (e.g., OpenAI) with a structured prompt (including "bumpers" like lists of sites/personnel). LLM returns a JSON object with parsed entities and a formatted string for Todoist.
4. **Review & Correction (MiniApp):** The parsed information is presented to the user for confirmation or conversational correction. This loop continues until the user confirms.
5. **Todoist Integration:** If the item is a Task or Reminder, the relevant text is sent to Todoist for task creation and detailed date/time parsing. Todoist returns its task ID and confirmed due date.
6. **Airtable Update:**
    * If a new master entity (e.g., Site) was identified and confirmed for creation, the Flask backend first writes it to the 10NetZero_Main_Datastore via API (this includes creating the SOP Google Doc for new sites).
    * The FLRTS item is then created in the 10NetZero-FLRTS base, linking to the Todoist Task ID (if applicable) and any master data (Sites, Personnel).
7. **User Confirmation:** Bot/MiniApp confirms item creation to the user.

## 3. Data Model (Airtable)

### 3.1. 10NetZero_Main_Datastore Base

This base serves as the Single Source of Truth (SSoT) for core business entities. It is designed as a single Airtable base containing multiple interlinked tables.

#### 3.1.1. Sites Table (Master)

* **Purpose:** Master list of all operational sites, including designated warehouse locations.
* **Key Fields (See Appendix A for full list):**
    * **SiteID_PK** (Primary Key)
    * **SiteName** (Single Line Text, Required)
    * **SiteAddress_Street** (Single Line Text)
    * **SiteAddress_City** (Single Line Text)
    * **SiteAddress_State** (Single Line Text)
    * **SiteAddress_Zip** (Single Line Text)
    * **SiteLatitude** (Number, Decimal)
    * **SiteLongitude** (Number, Decimal)
    * **SiteStatus** (Single Select: e.g., "Commissioning", "Running", "In Maintenance", "Contracted", "Planned", "Decommissioned")
    * **Operator_Link** (Link to Operators table)
    * **Site_Partner_Assignments_Link** (Link to Site_Partner_Assignments table)
    * **Site_Vendor_Assignments_Link** (Link to Site_Vendor_Assignments table)
    * **Licenses_Agreements_Link** (Link to Licenses & Agreements table)
    * **Equipment_At_Site_Link** (Link to Equipment table)
    * **ASICs_At_Site_Link** (Link to ASICs table)
    * **SOP_Document_Link** (URL - Link to Google Doc)
    * **IsActive** (Checkbox)
    * **Initial_Site_Setup_Completed_by_App** (Checkbox, Default: FALSE - System field: Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists and SOP Google Document. Used by safety net automations.)

#### 3.1.2. Personnel Table (Master)

* **Purpose:** Master list of all employees/users who might interact with or be referenced in the system.
* **Key Fields (See Appendix A for full list):**
    * **PersonnelID_PK** (Primary Key)
    * **FullName** (Single Line Text, Required)
    * **WorkEmail** (Email, Unique)
    * **PhoneNumber** (Phone Number)
    * **TelegramUserID** (Number, Unique - for bot interaction)
    * **TelegramHandle** (Single Line Text, Optional)
    * **EmployeePosition** (Single Line Text, e.g., "Field Technician", "Ops Manager")
    * **StartDate** (Date)
    * **EmploymentContract_Link** (Link to Licenses & Agreements table, Optional)
    * **Assigned_Equipment_Log_Link** (Link to Employee_Equipment_Log table)
    * **IsActive** (Checkbox, Default: TRUE)
    * **Default_Employee_Lists_Created** (Checkbox, Default: FALSE - System field: Set to TRUE by the Flask application after successfully creating the employee's default "Onboarding" list. Used by safety net automations.)

#### 3.1.3. Partners Table (Master)

* **Purpose:** Master list of partner organizations or individuals, primarily those with an investment, lending, or funding relationship concerning 10NetZero projects/sites.
* **Key Fields (See Appendix A for full list):**
    * **PartnerID_PK** (Primary Key)
    * **PartnerName** (Single Line Text, Required)
    * **PartnerType** (Single Select: e.g., "Co-Investor", "Site JV Partner", "Lender")
    * **Logo** (Attachment)
    * **ContactPerson_FirstName** (Single Line Text)
    * **ContactPerson_LastName** (Single Line Text)
    * **Email** (Email)
    * **Phone** (Phone Number)
    * **Address_Street1** (Single Line Text)
    * **Address_Street2** (Single Line Text)
    * **Address_City** (Single Line Text)
    * **Address_State** (Single Line Text)
    * **Address_Zip** (Single Line Text)
    * **FullAddress** (Formula)
    * **Website** (URL)
    * **RelevantAgreements_Link** (Link to Licenses & Agreements table)
    * **Site_Assignments_Link** (Link to Site_Partner_Assignments table)
    * **Notes** (Long Text)
    * **IsActive** (Checkbox, Default: TRUE)

#### 3.1.4. Site_Partner_Assignments Table (Junction Table)

* **Purpose:** Links Sites and Partners to define specific partnership details for each site.
* **Key Fields (See Appendix A for full list):**
    * **AssignmentID_PK** (Primary Key)
    * **LinkedSite** (Link to Sites table, Required)
    * **LinkedPartner** (Link to Partners table, Required)
    * **PartnershipStartDate** (Date)
    * **OwnershipPercentage** (Percent)
    * **PartnerResponsibilities** (Long Text, Rich Text)
    * **10NZ_Responsibilities** (Long Text, Rich Text)
    * **PartnershipContract_Link** (Link to Licenses & Agreements table)
    * **Notes** (Long Text)

#### 3.1.5. Vendors Table (Master)

* **Purpose:** Master list of vendor organizations/individuals.
* **Key Fields (See Appendix A for full list):**
    * **VendorID_PK** (Primary Key)
    * **VendorName** (Single Line Text, Required, Unique)
    * **ServiceType** (Multiple Select: e.g., "Electrical Services," "Legal Services")
    * **ContactPerson_FirstName** (Single Line Text)
    * **ContactPerson_LastName** (Single Line Text)
    * **Email** (Email)
    * **Phone** (Phone Number)
    * **Address_Street1** (Single Line Text)
    * **Address_Street2** (Single Line Text)
    * **Address_City** (Single Line Text)
    * **Address_State** (Single Line Text)
    * **Address_Zip** (Single Line Text)
    * **FullAddress** (Formula)
    * **Website** (URL)
    * **RelevantAgreements_Link** (Link to Licenses & Agreements table)
    * **Vendor_General_Attachments** (Attachment)
    * **Site_Assignments_Link** (Link to Site_Vendor_Assignments table)
    * **Notes** (Long Text)
    * **IsActive** (Checkbox, Default: TRUE)

#### 3.1.6. Site_Vendor_Assignments Table (Junction Table)

* **Purpose:** Links Sites and Vendors to define specific service or supply details for each site.
* **Key Fields (See Appendix A for full list):**
    * **VendorAssignmentID_PK** (Primary Key)
    * **LinkedSite** (Link to Sites table, Required)
    * **LinkedVendor** (Link to Vendors table, Required)
    * **ServiceDescription_SiteSpecific** (Long Text, Rich Text)
    * **VendorContract_Link** (Link to Licenses & Agreements table)
    * **Notes** (Long Text)

#### 3.1.7. Equipment Table (Master - General Assets)

* **Purpose:** Master list of general physical assets (non-ASIC). A "Warehouse" can be a designated Site record for location tracking.
* **Key Fields (See Appendix A for full list):**
    * **AssetTagID_PK** (Primary Key)
    * **EquipmentName** (Single Line Text, Required)
    * **Make** (Single Line Text)
    * **Model** (Single Line Text)
    * **EquipmentType** (Single Select: e.g., "Generator", "Pump", "Vehicle", "Heavy Equipment", "Power Tool", "IT Hardware - Laptop", "Safety Gear")
    * **SerialNumber** (Single Line Text, Unique if possible)
    * **SiteLocation_Link** (Link to Sites table - can be an operational site or a "Warehouse" site)
    * **Specifications** (Long Text, Rich Text)
    * **PurchaseDate** (Date)
    * **PurchasePrice** (Currency)
    * **PurchaseReceipt** (Attachment)
    * **CurrentStatus** (Single Select: e.g., "Operational", "Needs Maintenance", "Out of Service", "In Storage", "Irreparable/Disposed")
    * **WarrantyExpiryDate** (Date)
    * **LastMaintenanceDate** (Date)
    * **NextScheduledMaintenanceDate** (Date)
    * **Eq_Manual** (Attachment)
    * **EquipmentPictures** (Attachment)
    * **Employee_Log_Link** (Link to Employee_Equipment_Log table)
    * **Notes** (Long Text)

#### 3.1.8. ASICs Table (Master - Mining Hardware)

* **Purpose:** Dedicated master list for Bitcoin mining hardware. A "Warehouse" can be a designated Site record for location tracking.
* **Key Fields (See Appendix A for full list):**
    * **ASIC_ID_PK** (Primary Key - Autonumber, or SerialNumber if reliably unique)
    * **SerialNumber** (Single Line Text, Required, Unique)
    * **ASIC_Make** (Single Select - e.g., "Bitmain," "MicroBT," "Canaan")
    * **ASIC_Model** (Single Select - e.g., "S21 XP," "M60S," "A1366")
    * **SiteLocation_Link** (Link to Sites table - can be an operational site or a "Warehouse" site)
    * **RackLocation_In_Site** (Single Line Text)
    * **PurchaseDate** (Date)
    * **PurchasePrice** (Currency)
    * **CurrentStatus** (Single Select: "Mining", "Idle", "Needs Maintenance", "Error", "Offline", "Decommissioned")
    * **NominalHashRate_THs** (Number, Decimal)
    * **NominalPowerConsumption_W** (Number, Integer)
    * **HashRate_Actual_THs** (Number, Decimal)
    * **PowerConsumption_Actual_W** (Number, Integer)
    * **PoolAccount_Link** (Link to Mining_Pool_Accounts table)
    * **FirmwareVersion** (Single Line Text)
    * **IP_Address** (Single Line Text)
    * **MAC_Address** (Single Line Text)
    * **LastMaintenanceDate** (Date)
    * **WarrantyExpiryDate** (Date)
    * **ASIC_Manual** (Attachment)
    * **Notes** (Long Text)

#### 3.1.9. Employee_Equipment_Log Table (Junction Table)

* **Purpose:** Tracks equipment/tools lent to employees.
* **Key Fields (See Appendix A for full list):**
    * **LogID_PK** (Primary Key)
    * **LinkedEmployee** (Link to Personnel table, Required)
    * **LinkedEquipment** (Link to Equipment table, Required)
    * **DateIssued** (Date, Required)
    * **DateReturned** (Date, null if currently issued)
    * **ConditionIssued** (Single Select: e.g., "New", "Good", "Fair")
    * **ConditionReturned** (Single Select: e.g., "Good", "Fair", "Damaged")
    * **IsCurrentlyAssigned** (Checkbox or Formula based on DateReturned)
    * **Notes** (Long Text, Rich Text)

#### 3.1.10. Operators Table (Master)

* **Purpose:** Master list of entities operating the wells/sites.
* **Key Fields (See Appendix A for full list):**
    * **OperatorID_PK** (Primary Key)
    * **OperatorName** (Text, Required)
    * **ContactPerson** (Text)
    * **Email** (Email)
    * **Phone** (Phone)
    * **Address** (Long Text)
    * **OperatedSites_Link** (Link to Sites table)
    * **Notes** (Long Text)

#### 3.1.11. Licenses & Agreements Table (Master)

* **Purpose:** Consolidated repository for contracts, permits, licenses, and other agreements.
* **Key Fields (See Appendix A for full list):**
    * **AgreementID_PK** (Primary Key)
    * **AgreementName** (Text, Required)
    * **AgreementType** (Single Select: "Gas Purchase Agreement", "Permit", "License", "Service Agreement", "Lease Agreement", "Partner Agreement", "Vendor Agreement", "NDA", "Employment Agreement", "SOW", "PO")
    * **Status** (Single Select: "Active", "Expired", "Pending", "Terminated", "Under Review")
    * **CounterpartyName** (Text)
    * **Counterparty_Link_Partner** (Link to Partners table, optional)
    * **Counterparty_Link_Vendor** (Link to Vendors table, optional)
    * **Counterparty_Link_Operator** (Link to Operators table, optional)
    * **Counterparty_Link_Personnel** (Link to Personnel table, optional - for employment agreements)
    * **Site_Link** (Link to Sites table - can allow multiple)
    * **EffectiveDate** (Date)
    * **ExpiryDate** (Date)
    * **RenewalReminderDate** (Date)
    * **Document** (Attachment)
    * **KeyTerms_Summary** (Long Text, Rich Text)
    * **Notes** (Long Text)

#### 3.1.12. Mining_Pool_Accounts Table (Master)

* **Purpose:** Information about accounts with Bitcoin mining pools.
* **Key Fields (See Appendix A for full list):**
    * **PoolAccountID_PK** (Primary Key)
    * **PoolName** (Text, Required)
    * **PoolWebsite** (URL)
    * **AccountUsername** (Text)
    * **DefaultWorkerNameBase** (Text)
    * **StratumURL_Primary** (Text)
    * **StratumURL_Backup** (Text, optional)
    * **ExpectedFeePercentage** (Percent)
    * **CurrentTotalHashRate** (Number - Intended for periodic update via external process/API)
    * **PayoutWalletAddress** (Text)
    * **API_Key_ForStats** (Text - store securely)
    * **ASICs_Using_Pool_Link** (Link to ASICs table)
    * **Notes** (Long Text)

---

### 3.2. 10NetZero-FLRTS Base

This base holds operational data for the FLRTS application and synced data from the Main Datastore.

#### 3.2.1. Synced_Sites Table

* **Source:** One-way sync from Sites table in 10NetZero_Main_Datastore.
* **Purpose:** Provides a read-only local reference to sites for linking within the FLRTS base.
* **Fields:** Mirrors the Sites table from the Main Datastore.

#### 3.2.2. Synced_Personnel Table

* **Source:** One-way sync from Personnel table in 10NetZero_Main_Datastore.
* **Purpose:** Provides a read-only local reference to personnel for linking.
* **Fields:** Mirrors the Personnel table from the Main Datastore.

#### 3.2.3. Users Table (FLRTS App Specific)

* **Purpose:** Manages FLRTS application-specific user records, primarily linking authenticated Personnel (via their TelegramUserID from the Synced_Personnel table) to their activity within the FLRTS system. For the MVP, detailed role-based permissioning through specific flags in this table is largely deferred for users interacting via the Telegram Bot/MiniApp; such users operate under a unified "FLRTS Operator" model as described in Section 4.1.

* **Key Fields (See Appendix A, Section A.2.3 for the complete and detailed list, including all permission flags retained for future use):**
    * **UserID_PK** (Primary Key)
    * **Personnel_Link** (Link to Synced_Personnel table, Required, Unique)
    * **FLRTS_Role** (Single Select - For MVP, defaults to "FLRTS Operator" for bot users. Options like "Admin", "Manager" are for future differentiation and potential Admin Panel use.)
    * **PasswordHash** (Text - Conceptual for potential future direct FLRTS app login, not used for Telegram bot or primary Flask Admin Panel authentication in MVP.)
    * **IsActive** (Checkbox - To enable/disable a user's bot access.)
    * **DateAdded** (Created Time)
    * **LastLoginTimestamp** (Date)
    * **Permission Flags** (Various Checkboxes): A comprehensive set of permission flags (e.g., Can_Create_MasterData_Site, Can_View_MasterData_Partners) are defined in the schema in Appendix A, Section A.2.3.

* **MVP Note:** As detailed in SDD Section 4 and Appendix A.2.3, these granular flags are primarily for future enhancements and potential use by the Flask Admin Panel. They are generally not actively checked or enforced by the MVP application logic for users interacting via the Telegram Bot/MiniApp.

#### 3.2.4. FLRTS_Items Table

* **Purpose:** Core table for all FLRTS items.
* **Key Fields (See Appendix A for full list):**
    * **ItemID_PK** (Primary Key - Autonumber or UUID)
    * **ItemType** (Single Select: "Field Report", "List", "Reminder", "Task", "Subtask")
    * **Title** (Single Line Text, Required - content varies by ItemType, LLM sets to null for new Field Reports)
    * **Description** (Long Text - main content for Field Reports)
    * **Status** (Single Select: "Open", "In Progress", "Completed", "Pending", "Archived")
    * **Priority** (Single Select: "Low", "Medium", "High")
    * **DueDate** (Date, with time option - authoritative source is Todoist if linked)
    * **ReminderTime** (Date, with time option - for items where Todoist reminder is not primary)
    * **CreatedDate** (Created Time)
    * **CreatedBy_UserLink** (Link to Users table)
    * **LastModifiedDate** (Last Modified Time)
    * **AssignedTo_UserLink** (Link to Users table, allow multiple)
    * **Site_Link** (Link to Synced_Sites table)
    * **Scope** (Single Select: "site", "general")
    * **Visibility** (Single Select: "public", "private")
    * **ParentItem_Link** (Link to another FLRTS_Items record - for subtasks or items in a list)
    * **TodoistTaskID** (Text, Unique - if synced with Todoist)
    * **RawTelegramInput** (Long Text)
    * **ParsedLLM_JSON** (Long Text, AI-enabled in Airtable optional - stores JSON from General LLM)
    * **Source** (Single Select: "Telegram", "MiniApp", "AdminUI", "SiteGPT Suggestion", "Todoist Sync")
    * **IsSystemGenerated** (Checkbox, Default: FALSE) - TRUE for lists programmatically created by the system, e.g., default site lists
    * **SystemListCategory** (Single Select, Optional) - e.g., "Site_Tools", "Site_Tasks_Master", "Site_Shopping"; null for user-created items
    * **IsArchived** (Checkbox)
    * **ArchivedBy_UserLink** (Link to Users table)
    * **ArchivedAt_Timestamp** (Date, with time option)
    * **DoneAt_Timestamp** (Date, with time option)

#### 3.2.5. Field_Report_Edits Table

* **Purpose:** Stores append-only edits for Field Reports, ensuring history is maintained.
* **Key Fields (See Appendix A for full list):**
    * **EditID_PK** (Primary Key - Autonumber)
    * **ParentFieldReport_Link** (Link to FLRTS_Items where ItemType="Field Report", Required)
    * **Author_UserLink** (Link to Users table, Required)
    * **Timestamp** (Created Time)
    * **EditText** (Long Text, Required)

---

### 3.3. Data Synchronization Strategy

This section outlines the methods and rules for keeping data consistent across the different storage components of the 10NetZero-FLRTS system, specifically between the two Airtable bases (`10NetZero_Main_Datastore` and `10NetZero-FLRTS Base`) and with the external Todoist service.

#### 3.3.1. Main Datastore to FLRTS Base (Airtable Sync)

* **Mechanism:** The `Synced_Sites` and `Synced_Personnel` tables in the `10NetZero-FLRTS Base` are populated via a **one-way synchronization** from their respective master tables (`Sites` and `Personnel`) in the `10NetZero_Main_Datastore` base.
* **Technology:** This synchronization will be implemented using **Airtable's native cross-base sync feature.**
    * The sync configuration should include all relevant fields from the source tables to ensure the `Synced_Sites` and `Synced_Personnel` tables in the `10NetZero-FLRTS Base` are complete read-only replicas.
* **Purpose:** This provides readily available, read-access to essential master data (like site names, personnel details, and their Airtable Record IDs) within the `10NetZero-FLRTS Base`, enabling efficient linking of FLRTS items to this master data without requiring direct API calls to the `10NetZero_Main_Datastore` for every lookup.
* **Frequency:** The Airtable sync frequency should be configured to be as near real-time as Airtable permits (typically within minutes), ensuring that data in the `10NetZero-FLRTS Base` reflects recent changes in the master datastore reasonably quickly.

#### 3.3.2. FLRTS App Writing to Main Datastore (API)

This strategy applies when a new master data record (e.g., a new Site or a new Personnel entry) needs to be created as a result of user input within the FLRTS application (e.g., a user creates a task for a site that doesn't exist yet).

1. **Initiation:** The Flask backend application identifies the need to create a new master record.
2. **API Call to Main Datastore:**
    * The Flask backend will make a programmatic API call directly to the `10NetZero_Main_Datastore` Airtable base to create the new record in the appropriate master table (e.g., `Sites` or `Personnel`).
    * **Authentication:** This API call will be authenticated using a dedicated Airtable API key for the `10NetZero_Main_Datastore`, stored securely as an environment variable (e.g., `___AIRTABLE_MAIN_DATASTORE_API_KEY___`).
3. **Retrieve Record ID:** Upon successful creation, the Airtable API will return the unique Record ID of the newly created master record.
4. **Link in FLRTS Base:** The Flask backend will use this returned Record ID to immediately populate the relevant linked record field in the `FLRTS_Items` table (or other tables within the `10NetZero-FLRTS Base`). This ensures immediate data integrity and correct linking for the newly created FLRTS item, even before Airtable's native sync (Section 3.3.1) updates the corresponding `Synced_Sites` or `Synced_Personnel` table.
5. **Trigger Programmatic Post-Creation Actions:** After successfully creating the new master record via API (e.g., a new `Sites` record):
    * The Flask application will then directly invoke the logic detailed in **SDD Section 7.1 (Programmatic Site List & SOP Document Creation)** or **SDD Section 7.2 (Programmatic Employee "Onboarding" List Creation)** as appropriate. This includes actions like creating default FLRTS lists for the new site/employee and generating the SOP Google Document for a new site.
    * The relevant flags on the master record (e.g., `Initial_Site_Setup_Completed_by_App` on `Sites`, `Default_Employee_Lists_Created` on `Personnel`) will be set to TRUE by the Flask application upon successful completion of these programmatic actions.
6. **Error Handling Strategy:**
    * **Transient API Errors:** For temporary issues (e.g., network timeouts, Airtable API rate limits), implement a retry mechanism (e.g., 2-3 retries with exponential backoff) for the API call to the Main Datastore.
    * **Persistent API Errors:** If master record creation fails after retries (e.g., due to invalid data, persistent API unavailability):
        * The error, along with relevant contextual information (e.g., input data, user ID), must be logged vigorously (as per SDD Section 0.5).
        * An alert notification should be sent to a designated system administrator (e.g., via Telegram to `@colinaulds` or a dedicated admin channel).
        * **FLRTS Item Handling:**
            * **Option A (Safer):** The FLRTS item creation process that depended on this master record should be halted, and the user should be informed of the failure to create the master record. No partial FLRTS item should be created.
            * **Option B (If partial creation is permissible):** If an FLRTS item can exist meaningfully without the master record link, it could be created with a status indicating "Pending Master Record Creation," and the system (or admin) would need a mechanism to reconcile this later. *For MVP, Option A is recommended for simplicity unless a strong use case for Option B exists.*
    * **Failure in Post-Creation Actions (SOP/Default Lists):** If the master record is created successfully but subsequent programmatic actions (like SOP or default list creation) fail, this failure should also be logged and an admin notified. The master record will exist, but the associated setup flag (e.g., `Initial_Site_Setup_Completed_by_App`) will remain FALSE, triggering the safety net automations described in SDD Sections 7.1 and 7.2.

#### 3.3.3. Todoist and Airtable Synchronization

This section details how FLRTS items designated as "Task" or "Reminder" are synchronized with Todoist.

* **Source of Truth Principle:**
    * **Airtable (`FLRTS_Items` table):** Serves as the primary System of Record (SoR) for the complete FLRTS item, including its 10NetZero-specific metadata (e.g., `Site_Link`, `Scope`, `RawTelegramInput`, `ParsedLLM_JSON`, `Source`).
    * **Todoist:** Serves as the SoR for task-specific attributes it excels at managing, such as precise due dates (including recurring patterns), completion status, and the delivery of reminders.
* **Initial Creation (FLRTS App to Todoist):**
    1. When an FLRTS item (Task or Reminder) is created in the FLRTS application, the Flask backend sends the relevant details (e.g., task title, description derived from `FLRTS_Items.Title` and `FLRTS_Items.Description`) to the Todoist API to create a new task.
    2. Todoist processes the input (including its NLP for dates/times) and returns its unique `TodoistTaskID` and the parsed/confirmed `DueDate`.
    3. The Flask backend stores this `TodoistTaskID` and the Todoist-confirmed `DueDate` in the corresponding `FLRTS_Items` record in Airtable.
* **Updates (Todoist to Airtable via Webhooks):**
    * **Mechanism:** The primary method for updating Airtable based on changes in Todoist is via **Todoist Webhooks.**
        * A webhook endpoint in the Flask backend will be registered with Todoist for relevant events (e.g., `task:completed`, `task:updated` particularly for due date changes, `task:deleted`).
        * Detailed implementation specifics for this webhook handler, including request signature validation (`X-Todoist-Hmac-SHA256`) and idempotency (`X-Todoist-Delivery-ID`), are covered in the **10NetZero-FLRTS LLM Implementation Guide (Section 2)** and referenced in **SDD Section 6.1 (Webhook Setup for Updates from Todoist)**.
    * **Processing:** When the Flask backend receives a valid webhook notification:
        1. It identifies the corresponding `FLRTS_Items` record in Airtable using the `TodoistTaskID` from the webhook payload.
        2. It updates the necessary fields in the Airtable record. **Specific fields to be updated include:**
            * `Status`: (e.g., to "Completed" if `event_name` is `item:completed`).
            * `DueDate`: If the due date is changed in Todoist.
            * `DoneAt_Timestamp`: When a task is completed.
            * `IsArchived` / `ArchivedAt_Timestamp`: If a task is deleted or archived in Todoist, the corresponding FLRTS item might be marked as archived.
    * **Polling (MVP Alternative/Fallback):** If Todoist webhooks prove unreliable or overly complex to implement robustly for MVP, a polling mechanism can be used as an alternative. The Flask backend would periodically query the Todoist API for recently updated tasks associated with the application and then update Airtable accordingly. This is less efficient and not real-time, so webhooks are preferred.
    * **Error Handling for Webhook Processing:**
        * If the `TodoistTaskID` from a webhook payload is not found in the `FLRTS_Items` table, the event should be logged, and an admin potentially notified, as this indicates a desynchronization.
        * If the Flask backend encounters an error communicating with Airtable while trying to update an `FLRTS_Items` record (e.g., Airtable API down), the error should be logged. For critical updates, a retry mechanism or a "dead letter queue" for failed webhook events could be considered for post-MVP. For MVP, robust logging and admin notification are key.
* **Updates (Airtable to Todoist - Minimized for MVP):**
    * For MVP, direct modifications to task-related fields (like `DueDate` or `Status`) within Airtable are **not expected to automatically sync back to Todoist.**
    * Changes to core task properties should ideally be initiated through application interfaces (e.g., Telegram bot commands) that would instruct the Flask backend to first update the task in Todoist via its API. The changes would then flow back to Airtable via the Todoist webhook, maintaining Todoist as the SoR for those fields.
    * If direct Airtable edits for such fields are allowed, users must be made aware that these changes will not be reflected in Todoist for the MVP.

## 4. User Roles, Permissions, and Access Control (MVP Simplification)

For the Minimum Viable Product (MVP), the roles and permissions structure within the 10NetZero-FLRTS application is simplified to expedite development and leverage the trusted nature of the initial user base. The primary goal is to provide core FLRTS functionality through the Telegram Bot/MiniApp interface while ensuring that system-critical administrative functions and master data management are handled through separate, more controlled channels.

### 4.1. FLRTS Operator Role (Telegram Bot/MiniApp Users)

* **Description:** For MVP, all users interacting with the system via the Telegram Bot or MiniApp will operate under a single, unified role designated as "FLRTS Operator."
* **Access & Authentication:** Users are authenticated by linking their `TelegramUserID` (from the `Personnel` table) to a record in the `Users` table within the `10NetZero-FLRTS Base`.
* **Capabilities via Telegram Bot/MiniApp:**
    * **FLRTS Item Management:**
        * Can create, view, edit, assign, and manage their own Tasks, Reminders, Field Reports, and Lists.
        * Can add items to system-generated or publicly accessible lists (e.g., Site Shopping Lists).
    * **FLRTS Item Visibility (MVP Simplification):**
        * Can view all FLRTS items within the system, including Tasks, Reminders, Field Reports, and Lists created by or assigned to other users. For MVP, specific privacy or restricted views for Tasks/Reminders are deferred, relying on the trusted nature of the team.
    * **Master Data Interaction:**
        * Can view records from synced master data tables as needed for context within the FLRTS application (e.g., selecting a Site or Personnel when creating/assigning an FLRTS item).
        * Cannot directly create, edit, or delete records in any master data tables (e.g., `Sites`, `Personnel`, `Partners`, `Vendors`, etc.) through the Telegram Bot/MiniApp interface.
* **Limitations:**
    * FLRTS Operators cannot perform system-wide configurations, manage other user accounts, or execute any administrative functions described in Section 4.2 through the Telegram Bot/MiniApp.

### 4.2. Administrative Functions & Access

* **Description:** System-critical administrative functions, master data management (including creation of new Sites and Personnel which trigger programmatic backend processes), and operations that could pose a risk to data integrity or system stability are handled exclusively outside the standard FLRTS Operator interface (Telegram Bot/MiniApp).
* **Access Mechanisms:**
    1.  **Direct Airtable Access:** Authorized team members with appropriate Airtable base permissions (e.g., Creator, Editor) can directly manage data within the `10NetZero_Main_Datastore` and `10NetZero-FLRTS Base`. This includes creating and editing master data records.
    2.  **Flask Admin Panel:** A dedicated web-based Admin Panel, built as part of the Flask backend, will provide a controlled interface for specific administrative tasks.
        * **Authentication:** Access to the Flask Admin Panel will be secured by a distinct admin authentication mechanism (e.g., a specific username and password defined via environment variables: `___FLASK_ADMIN_USER___` and `___FLASK_ADMIN_PASS___`).
        * **Key Functions (Conceptual for MVP):**
            * Creating new `Sites` (which will trigger SOP document generation and default list creation as per SDD Section 8.1).
            * Creating new `Personnel` records (which will trigger default "Onboarding" list creation as per SDD Section 8.2).
            * Viewing system logs (potentially).
            * Managing system configurations (if any are exposed via UI beyond environment variables).
            * Overseeing FLRTS items if a broader administrative view is needed beyond what the bot provides.
* **Data Integrity Note:** When master data (like new Sites or Personnel) is created via the Flask Admin Panel or direct Airtable manipulation, the system's programmatic post-creation actions (SOPs, default lists, flag setting) as detailed in SDD Sections 8.1 and 8.2 must be reliably triggered and completed. If creation occurs via direct Airtable entry, these processes will rely on Airtable Automations (as safety nets) or require manual initiation if direct Flask app interaction is bypassed. The Flask Admin Panel is the preferred route for programmatic creation to ensure all system steps are executed.

## 5. User Interface (UI) and User Experience (UX) Design

## 6. Todoist Integration Details
### 6.1. Todoist Webhook Configuration
* **Purpose:** To enable real-time synchronization between Todoist and the FLRTS system.
* **Implementation:**
  * Configure Todoist to send webhooks to the Flask backend whenever a task status changes or a new task is created.
  * The Flask backend will then update the corresponding FLRTS_Items record in Airtable.

## 7. Other Key Functionalities / Features (MVP)

### 7.1. Programmatic Site List & SOP Document Creation

* **Trigger:** Automatically initiated by the Flask backend immediately after a new Site record is successfully created in the 10NetZero_Main_Datastore (typically by a Manager or Admin via the Admin Web UI or an authorized application interface).
* The Flask application will:
    1. Create the default FLRTS lists for the site (Tools, Master Task, Shopping).
    2. Connect to Google Drive, create a new SOP Google Document (e.g., from a template, titled "[SiteName] - SOP"), and retrieve its shareable link.
    3. Store this link in the SOP_Document_Link field of the new Site record.
* Upon successful creation of the site's lists and SOP document, the Flask application will set the Initial_Site_Setup_Completed_by_App flag (Checkbox field) on the Sites record to TRUE.
* **Default Lists Created (per new Site):** The following FLRTS_Items of ItemType="List" will be created:
    1. **Site Tools List:**
        * Title: "[SiteName] - Tools List"
        * Description: "List of tools and general equipment available or needed at [SiteName]."
        * SystemListCategory: "Site_Tools_List"
        * Scope: "site" (linked to the new Site)
        * Visibility: "public" (globally readable by all roles)
        * IsSystemGenerated: TRUE
        * CreatedBy_UserLink: "System" user.
        * AssignedTo_UserLink: Null/Empty.
        * Pre-populated items: None by default for MVP.
    2. **Site Master Task List:**
        * Title: "[SiteName] - Master Task List"
        * Description: "Master list of standard operational tasks and checklists for [SiteName]."
        * SystemListCategory: "Site_Master_Task_List"
        * Scope: "site"
        * Visibility: "public"
        * IsSystemGenerated: TRUE
        * CreatedBy_UserLink: "System" user.
        * AssignedTo_UserLink: Null/Empty.
        * Pre-populated items: None by default for MVP (can be added later as standard tasks).
    3. **Site Shopping List:**
        * Title: "[SiteName] - Shopping List"
        * Description: "List of items to be purchased for [SiteName]."
        * SystemListCategory: "Site_Shopping_List"
        * Scope: "site"
        * Visibility: "public"
        * IsSystemGenerated: TRUE
        * CreatedBy_UserLink: "System" user.
        * AssignedTo_UserLink: Null/Empty.
        * Pre-populated items: None by default for MVP.
* **Safety Net:** An Airtable Automation will trigger upon the creation of any new Sites record.
    * It will check the value of the Initial_Site_Setup_Completed_by_App flag after a short delay (e.g., 1-2 minutes to allow the Flask app to complete its work).
    * If this flag is FALSE (or not set) after the delay, the automation will immediately delete the newly created Sites record and send a Telegram notification to a designated admin (e.g., @colinaulds), informing them of the deletion and advising them to recreate the site via the application, as the automated setup likely failed.

### 7.2. Programmatic Employee "Onboarding" List Creation

* **Trigger:** Automatically initiated by the Flask backend immediately after a new Personnel record is successfully created in the 10NetZero_Main_Datastore (typically by a Manager or Admin via the Admin Web UI or an authorized application interface).
* Upon successful creation of the employee and their "Onboarding" list, the Flask application will set the Default_Employee_Lists_Created flag (Checkbox field) on the Personnel record to TRUE.
* **Default List Created (per new Employee):** One FLRTS_Item of ItemType="List":
    * **Employee Onboarding List:**
        * Title: "[Employee_FullName]'s Onboarding Tasks" (e.g., "John Doe's Onboarding Tasks")
        * Description: "Standard onboarding tasks for new personnel."
        * SystemListCategory: "Employee_Onboarding"
        * Scope: "general"
        * Visibility: "public" (globally readable by all roles)
        * IsSystemGenerated: TRUE
        * CreatedBy_UserLink: "System" user.
        * AssignedTo_UserLink: The new employee.
        * Pre-populated items: One default task: Title="Report for duty", Description="Initial check-in and reporting task.", assigned to the new employee, linked to this parent "Onboarding" list. Other standard onboarding tasks can be added to this template over time.
* **Safety Net:** An Airtable Automation will trigger upon the creation of any new Personnel record.
    * It will check the value of the Default_Employee_Lists_Created flag after a short delay.
    * If this flag is FALSE (or not set) after the delay, the automation will immediately delete the newly created Personnel record and send a Telegram notification to a designated admin (e.g., @colinaulds), informing them of the deletion and advising them to recreate the employee via the application.

## 8. Development Phases

### 8.1. Noloco Data Setup
1. **Register/Access Noloco Account**
   * Sign up or log in to Noloco platform
   * Create a new project named "10NetZero-FLRTS"

2. **Prepare CSV Files for Initial Data Import (Optional)**
   * Create CSV templates for each collection with proper headers matching field names
   * For each collection in Appendix A (Sites, Personnel, Partners, etc.), create a separate CSV
   * Include at least 2-3 sample records for testing

3. **Create Collections in Noloco**
   * **Sites Collection**
     * Navigate to Collections section in Noloco
     * Click "Create new collection" and name it "Sites"
     * Add fields according to Appendix A.1.1, setting proper field types:
       * SiteID_Display (Text)
       * SiteName (Text)
       * SiteAddress_Street (Text)
       * SiteAddress_City (Text) 
       * [Continue with all other fields]
     * Set field validations (required fields, unique constraints)
     * Import sample data if available

   * **Personnel Collection**
     * Create "Personnel" collection
     * Add fields according to Appendix A.1.2
     * Set validations
     * Import sample data if available

   * **Partners Collection**
     * Create "Partners" collection
     * Add fields according to Appendix A.1.3
     * Set validations
     * Import sample data if available

   * **[Continue with all other collections from Appendix A]**
     * Vendors (A.1.4)
     * Operators (A.1.5)
     * Site_Partner_Assignments (A.1.6)
     * Site_Vendor_Assignments (A.1.7)
     * Equipment (A.1.8)
     * ASICs (A.1.9)
     * Licenses & Agreements (A.1.10)
     * Users (A.1.11)
     * Field_Reports (A.2.1)
     * Lists (A.2.2)
     * List_Items (A.2.3)
     * Tasks (A.2.4)
     * Reminders (A.2.5)
     * Notifications_Log (A.2.6)
     * Field_Report_Edits (A.2.7)

4. **Set Up Relationships Between Collections**
   * Configure one-to-many and many-to-many relationships:
     * Link Sites to Equipment, ASICs, Partners, etc.
     * Set up junction tables for many-to-many relationships
     * Test relationship navigation

5. **Create Basic Noloco Views and Forms**
   * Create default views for each collection
   * Set up forms for data entry
   * Configure dashboard views for commonly accessed data

6. **Get Noloco API Information**
   * Navigate to API settings in Noloco
   * Generate API key and copy it securely
   * Note the GraphQL endpoint URL
   * Save these for use in the .env file later

7. **Test Noloco Setup**
   * Create test records through Noloco interface
   * Verify relationships work properly
   * Ensure required fields and validations are working

### 8.2. External Services Setup

1. **Telegram Bot Setup**
   * Visit https://t.me/BotFather on Telegram
   * Create a new bot with `/newbot` command
   * Choose a name and username for your bot
   * Copy the HTTP API token provided
   * Set up bot commands with `/setcommands`
   * Save the token for later

2. **Todoist API Setup**
   * Create/log in to Todoist account
   * Go to Integrations → Developer
   * Create a new app and generate API token
   * Copy the API token
   * Save for later

3. **Google Drive API Setup**
   * Go to Google Cloud Console (https://console.cloud.google.com/)
   * Create a new project
   * Enable the Google Drive API
   * Configure OAuth consent screen
   * Create OAuth client ID credentials
   * Download credentials JSON file
   * Save for later

4. **LLM API Setup (OpenAI or similar)**
   * Create/log in to OpenAI account
   * Go to API keys section
   * Generate new API key
   * Copy the API key
   * Save for later

### 8.3. Flask Backend Setup

1. **Create Flask Project**
   * Use Replit Flask template (https://replit.com/@replit/Flask)
   * Alternatively, create locally:
     ```bash
     mkdir 10netzero-flrts
     cd 10netzero-flrts
     ```

2. **Set Up Python Environment**
   * If using local development:
     ```bash
     python -m venv venv
     # On Windows:
     venv\Scripts\activate
     # On macOS/Linux:
     source venv/bin/activate
     ```

3. **Install Dependencies**
   * Create/update requirements.txt with:
     ```
     flask==2.0.1
     python-telegram-bot==13.7
     python-dotenv==0.19.0
     requests==2.26.0
     gql==3.0.0
     google-api-python-client==2.24.0
     google-auth==2.3.0
     google-auth-oauthlib==0.4.6
     openai==0.27.0
     gunicorn==20.1.0
     ```
   * Install dependencies:
     ```bash
     pip install -r requirements.txt
     ```

4. **Create Project Structure**
   * Set up basic folder structure:
     ```bash
     mkdir -p app/{api,bot,nlp,services,utils}
     touch app/__init__.py
     touch app/api/__init__.py
     touch app/bot/__init__.py
     touch app/nlp/__init__.py
     touch app/services/__init__.py
     touch app/utils/__init__.py
     ```

5. **Create .env File**
   * Create .env file in project root:
     ```bash
     touch .env
     ```
   * Add all API keys and endpoints:
     ```
     # Noloco API
     NOLOCO_API_KEY=your_noloco_api_key
     NOLOCO_API_URL=your_noloco_graphql_endpoint

     # Telegram Bot
     TELEGRAM_BOT_TOKEN=your_telegram_bot_token

     # Todoist API
     TODOIST_API_KEY=your_todoist_api_key

     # LLM API (e.g., OpenAI)
     LLM_API_KEY=your_openai_api_key
     LLM_MODEL_NAME=gpt-4

     # Google Drive API
     GOOGLE_APPLICATION_CREDENTIALS=path_to_your_credentials_file
     ```

6. **Create Basic Flask App Structure**
   * Create app/__init__.py:
     ```python
     from flask import Flask

     def create_app():
         app = Flask(__name__)
         
         # Register blueprints here (to be created later)
         
         @app.route('/health')
         def health_check():
             return {"status": "healthy"}
             
         return app
     ```
   * Create main.py in root:
     ```python
     from app import create_app

     app = create_app()

     if __name__ == "__main__":
         app.run(debug=True)
     ```

### 8.4. Develop Flask Backend Modules

#### Module 1: Noloco Client

1. **Create Noloco Client Module**
   * Create file: app/api/noloco_client.py
   * Implement GraphQL client for Noloco:
     ```python
     import os
     import logging
     import requests
     import json
     from dotenv import load_dotenv

     load_dotenv()

     logger = logging.getLogger(__name__)

     NOLOCO_API_KEY = os.getenv("NOLOCO_API_KEY")
     NOLOCO_API_URL = os.getenv("NOLOCO_API_URL")

     def _make_graphql_request(query, variables=None):
         """Helper function to make GraphQL requests to Noloco API"""
         # Implementation here
     
     def get_sites(limit=10, offset=0, filters=None):
         """Get sites from Noloco with pagination and filtering"""
         # Implementation here
     
     # Add other CRUD functions for each collection
     ```

2. **Test Noloco Client**
   * Create a test script for the Noloco client:
     ```python
     from app.api.noloco_client import get_sites
     
     def test_noloco_client():
         sites = get_sites(limit=5)
         print(f"Retrieved {len(sites)} sites:")
         for site in sites:
             print(f"- {site['SiteName']}")
     
     if __name__ == "__main__":
         test_noloco_client()
     ```
   * Run the test script

#### Module 2: Telegram Bot Handler

1. **Create Telegram Bot Handler Module**
   * Create file: app/bot/telegram_bot_handler.py
   * Implement bot setup and message handling:
     ```python
     import os
     import logging
     from telegram import Update
     from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackContext
     from dotenv import load_dotenv
     
     load_dotenv()
     
     logger = logging.getLogger(__name__)
     
     TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
     
     def start_command(update: Update, context: CallbackContext):
         """Handle the /start command"""
         # Implementation here
     
     def help_command(update: Update, context: CallbackContext):
         """Handle the /help command"""
         # Implementation here
     
     def handle_message(update: Update, context: CallbackContext):
         """Handle text messages"""
         # Implementation here
     
     def setup_bot():
         """Set up the Telegram bot with handlers"""
         # Implementation here
     ```
   
2. **Integrate with Flask**
   * Create blueprint for Telegram webhook:
     ```python
     # app/bot/routes.py
     from flask import Blueprint, request, jsonify
     
     telegram_bp = Blueprint('telegram', __name__)
     
     @telegram_bp.route('/webhook', methods=['POST'])
     def telegram_webhook():
         # Implementation here
     ```
   * Register blueprint in app/__init__.py

3. **Test Telegram Bot**
   * Create a test script:
     ```python
     from app.bot.telegram_bot_handler import setup_bot
     
     def test_telegram_bot():
         bot = setup_bot()
         # Manual polling for testing
         bot.start_polling()
         print("Bot started polling...")
         bot.idle()
     
     if __name__ == "__main__":
         test_telegram_bot()
     ```
   * Run the test script

#### Module 3: Intent Classifier

1. **Create Intent Classifier Module**
   * Create file: app/nlp/intent_classifier.py
   * Implement basic intent classification:
     ```python
     import re
     import logging
     
     logger = logging.getLogger(__name__)
     
     # Intent types
     INTENT_TASK = "TASK"
     INTENT_FIELD_REPORT = "FIELD_REPORT"
     INTENT_LIST_UPDATE = "LIST_UPDATE"
     INTENT_QUERY = "QUERY"
     INTENT_UNKNOWN = "UNKNOWN"
     
     def classify_intent(text):
         """Classify the intent of a message"""
         # Implementation here
     ```

2. **Test Intent Classifier**
   * Create a test script:
     ```python
     from app.nlp.intent_classifier import classify_intent
     
     def test_intent_classifier():
         test_messages = [
             "Remind me to check Site Alpha tomorrow",
             "Field report for Site Bravo: All systems operational",
             "Add thermal paste to the Site Charlie shopping list",
             "What are my tasks for today?",
             "Hello, how are you?"
         ]
         
         for message in test_messages:
             intent = classify_intent(message)
             print(f"Message: '{message}'")
             print(f"Intent: {intent}")
             print("---")
     
     if __name__ == "__main__":
         test_intent_classifier()
     ```
   * Run the test script

#### Module 4: NLP Service (Todoist & General LLM)

1. **Create Todoist Integration Module**
   * Create file: app/services/todoist_integration.py
   * Implement Todoist API client:
     ```python
     import os
     import logging
     import requests
     from dotenv import load_dotenv
     
     load_dotenv()
     
     logger = logging.getLogger(__name__)
     
     TODOIST_API_KEY = os.getenv("TODOIST_API_KEY")
     
     def add_task_with_nlp(text):
         """Use Todoist Quick Add to parse and create a task"""
         # Implementation here
     
     def sync_task_to_noloco(todoist_task):
         """Sync a Todoist task to Noloco Tasks collection"""
         # Implementation here
     ```

2. **Create LLM Service Module**
   * Create file: app/services/llm_service.py
   * Implement LLM API client:
     ```python
     import os
     import logging
     import openai
     from dotenv import load_dotenv
     
     load_dotenv()
     
     logger = logging.getLogger(__name__)
     
     LLM_API_KEY = os.getenv("LLM_API_KEY")
     LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME")
     
     openai.api_key = LLM_API_KEY
     
     def parse_field_report(text):
         """Use LLM to parse a field report into structured data"""
         # Implementation here
     
     def parse_list_update(text):
         """Use LLM to parse a list update into structured data"""
         # Implementation here
     ```

3. **Create NLP Orchestration Module**
   * Create file: app/nlp/nlp_service.py
   * Implement orchestration between intent and NLP services:
     ```python
     import logging
     from app.nlp.intent_classifier import classify_intent, INTENT_TASK, INTENT_FIELD_REPORT, INTENT_LIST_UPDATE, INTENT_QUERY
     from app.services.todoist_integration import add_task_with_nlp, sync_task_to_noloco
     from app.services.llm_service import parse_field_report, parse_list_update
     
     logger = logging.getLogger(__name__)
     
     def process_natural_language(text):
         """Process natural language input based on intent"""
         # Implementation here
     ```

4. **Test NLP Service**
   * Create a test script:
     ```python
     from app.nlp.nlp_service import process_natural_language
     
     def test_nlp_service():
         test_messages = [
             "Remind me to check Site Alpha tomorrow at 9am",
             "Field report for Site Bravo: Generator running at 80% capacity, no issues detected",
             "Add thermal paste and screwdrivers to the Site Charlie shopping list"
         ]
         
         for message in test_messages:
             print(f"Processing: '{message}'")
             result = process_natural_language(message)
             print(f"Result: {result}")
             print("---")
     
     if __name__ == "__main__":
         test_nlp_service()
     ```
   * Run the test script

#### Module 5: Google Drive Integration

1. **Create Google Drive Integration Module**
   * Create file: app/services/google_drive_integration.py
   * Implement Google Drive API client:
     ```python
     import os
     import logging
     from google.oauth2 import service_account
     from googleapiclient.discovery import build
     from dotenv import load_dotenv
     
     load_dotenv()
     
     logger = logging.getLogger(__name__)
     
     CREDENTIALS_FILE = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
     
     def authenticate_drive():
         """Authenticate with Google Drive API"""
         # Implementation here
     
     def create_sop_document(site_name, site_id):
         """Create a new SOP document for a site"""
         # Implementation here
     
     def set_document_permissions(document_id, emails):
         """Set permissions for the SOP document"""
         # Implementation here
     ```

2. **Test Google Drive Integration**
   * Create a test script:
     ```python
     from app.services.google_drive_integration import create_sop_document, set_document_permissions
     
     def test_google_drive():
         site_name = "Test Site"
         site_id = "TST001"
         
         print(f"Creating SOP document for {site_name} ({site_id})...")
         doc_id, doc_url = create_sop_document(site_name, site_id)
         
         print(f"Document created with ID: {doc_id}")
         print(f"Document URL: {doc_url}")
         
         # Test setting permissions
         emails = ["test@example.com"]
         set_document_permissions(doc_id, emails)
         print(f"Set permissions for: {', '.join(emails)}")
     
     if __name__ == "__main__":
         test_google_drive()
     ```
   * Run the test script

#### Module 6: Site Setup Module

1. **Create Site Setup Module**
   * Create file: app/services/site_setup_module.py
   * Implement automated site setup:
     ```python
     import logging
     from app.api.noloco_client import get_site_by_id, update_site
     from app.services.google_drive_integration import create_sop_document, set_document_permissions
     
     logger = logging.getLogger(__name__)
     
     def create_default_lists(site_id):
         """Create default lists for a new site"""
         # Implementation here
     
     def setup_new_site(site_id):
         """Run the complete site setup process"""
         # Implementation here
     ```

2. **Test Site Setup Module**
   * Create a test script:
     ```python
     from app.services.site_setup_module import setup_new_site
     
     def test_site_setup():
         # Use a test site ID
         site_id = "TST001"
         
         print(f"Running setup for site ID: {site_id}...")
         result = setup_new_site(site_id)
         
         print(f"Setup completed with result: {result}")
     
     if __name__ == "__main__":
         test_site_setup()
     ```
   * Run the test script

### 8.5. Integration and Testing

1. **Connect Modules in Main Flask Application**
   * Update app/__init__.py to integrate all modules
   * Create necessary routes and webhooks
   * Implement error handling

2. **Implement End-to-End Testing**
   * Create comprehensive test cases
   * Test the complete workflow:
     * Telegram message → Intent classification → NLP processing → Noloco update
     * Site creation → Automated setup

3. **Logging and Monitoring**
   * Implement detailed logging
   * Create monitoring endpoints
   * Set up error alerts

### 8.6. Deployment

1. **Prepare for Production**
   * Configure WSGI server (Gunicorn)
   * Create Procfile (if using Heroku or similar):
     ```
     web: gunicorn main:app
     ```
   * Set up environment variables on hosting platform

2. **Deploy the Application**
   * Choose hosting platform (Heroku, PythonAnywhere, AWS, etc.)
   * Follow platform-specific deployment steps
   * Set up webhook URL with Telegram

3. **Post-Deployment Testing**
   * Verify all integrations work in production
   * Test with real users
   * Monitor for errors

### 8.7. Documentation and User Training

1. **Create User Documentation**
   * Document Telegram bot commands
   * Create user guides for Noloco interface

2. **Create Technical Documentation**
   * Document API endpoints
   * Describe system architecture
   * Detail deployment and maintenance procedures

3. **Train Users**
   * Conduct training sessions
   * Provide support for initial usage

### 8.8. Maintenance and Iteration

1. **Monitor System Performance**
   * Track usage metrics
   * Monitor error rates
   * Check integration health

2. **Iterate Based on Feedback**
   * Collect user feedback
   * Implement improvements
   * Update documentation


## 9. Future Features

* **Enhanced NLP & AI Capabilities:**
* **LLM Interaction with SOP Google Docs:** Enable users to query the content of SOP Google Docs using natural language (e.g., "What is the procedure for X at [SiteName]?"). Allow users to request updates or additions to SOP Google Docs via natural language commands, which an LLM would then translate into edits on the actual document (potentially with a confirmation step). This would require deeper Google Drive API integration, including parsing and modifying Google Doc content.
* **Contracts table row fill via OpenAI:** For the "Licenses & Agreements" table, implement functionality to upload an agreement document (e.g., PDF) and use an LLM (like OpenAI API) to parse its content and automatically suggest or pre-fill as many of the table fields as possible (e.g., AgreementName, CounterpartyName, EffectiveDate, ExpiryDate, KeyTerms_Summary). This would be a valuable addition to SDD Section 9: Future Features.

**(Appendix A section within this document would just be a placeholder, as the detailed Appendix A is being built as a separate artifact sdd_appendix_a)**
**Appendix A: Airtable Field Definitions**

*(Refer to the live document artifact with id="sdd_appendix_a" for the complete and detailed field definitions for all Airtable tables.)*

### 9.x LLM Integration & Prompting (Future Feature)
