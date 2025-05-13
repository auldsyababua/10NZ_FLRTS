# # 10NetZero-FLRTS: System Design Document 

# 10NetZero-FLRTS: System Design Document

****Version:**** 1.1 (Updated Section 3.1)
****Date:**** May 8, 2025

## 1. Introduction

### 1.1. Purpose of the Document
This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model, user interaction flows, third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements.

### 1.2. System Overview (10NetZero-FLRTS)
The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows for users, particularly those in field operations, by leveraging natural language processing, a robust data backend, and seamless integration with tools like Telegram and Todoist. The system will feature a Telegram bot and MiniApp as the primary user interfaces, supported by a Flask backend, Airtable databases, and AI capabilities for parsing and specialized knowledge retrieval. This system integrates and expands upon concepts from the user's "10NetZero Integrated Platform Design (TgBot + SiteGPT)" document.

### 1.3. Core Goals
* ****Centralized Data Management:**** Establish a single source of truth for core business entities and FLRTS items.
* ****Intuitive User Experience:**** Prioritize natural language input and conversational interfaces for ease of use, especially on mobile devices.
* ****Efficient Workflow Automation:**** Streamline the creation, assignment, and tracking of FLRTS items.
* ****Seamless Integration:**** Leverage existing tools like Todoist for their strengths in task management and reminders, and integrate specialized AI (SiteGPT) for document-based knowledge work.
* ****Scalability and Maintainability:**** Design a modular architecture that can adapt to future needs and growth.

## 2. System Architecture

### 2.1. Key Components
The 10NetZero-FLRTS system comprises the following key components:

1. ****Telegram Bot & MiniApp (Primary User Interface):****
   * Built using the Telegram Bot API.
   * MiniApp for richer UI interactions within Telegram (e.g., displaying lists, review/confirmation screens).
   * Handles user input (natural language, button interactions) and displays system responses.

2. ****Flask Backend (Application Server):****
   * Python-based web server using the Flask framework.
   * Hosts the API endpoints for the Telegram bot/MiniApp.
   * Orchestrates interactions between other components (LLM, Todoist, Airtable).
   * Manages business logic, user authentication (for web admin UI), and permissions.

3. ****General Purpose LLM (e.g., OpenAI API):****
   * Used for parsing natural language input from users to create structured FLRTS data.
   * Identifies item types, extracts entities (titles, descriptions, sites, assignees, dates), and prepares text for Todoist.

4. ****Todoist (Task Management & Reminders):****
   * Integrated via its API.
   * Handles detailed NLP for dates, times, and recurring patterns for tasks and reminders.
   * Manages the lifecycle of tasks (creation, completion) and the delivery of reminders.
   * Serves as the source of truth for due dates and completion status of tasks managed within it.

5. ****Airtable (Data Storage):****
   * ****`10NetZero_Main_Datastore` Base:**** The central repository for master data (Sites, Personnel, Partners, Vendors, etc.).
   * ****`10NetZero-FLRTS` Base:**** Stores operational data specific to the FLRTS application, including `FLRTS_Items` and synced master data.

6. ****SiteGPT (Specialized RAG LLM - via TypingMind):****
   * As described in the user's "10NetZero Integrated Platform Design" PDF (page 2) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf].
   * A custom RAG-powered LLM backend trained on engineering documents.
   * Used for answering queries, drafting reports, and suggesting actions based on these specialized documents, distinct from the general FLRTS NLP.

7. ****Admin Web UI (Conceptual for MVP):****
   * A separate web interface for administrators to manage users, permissions, system settings, and potentially view/manage FLRTS items in bulk.

### 2.2. High-Level Data Flow for FLRTS Creation (Natural Language via Telegram)
1. ****User Input:**** User sends a natural language command to the Telegram bot/MiniApp.
2. ****Flask Backend:**** Receives the input.
3. ****General LLM Processing:**** Backend sends raw text to the General LLM (e.g., OpenAI) with a structured prompt (including "bumpers" like lists of sites/personnel). LLM returns a JSON object with parsed entities and a formatted string for Todoist.
4. ****Review & Correction (MiniApp):**** The parsed information is presented to the user for confirmation or conversational correction. This loop continues until the user confirms.
5. ****Todoist Integration:**** If the item is a Task or Reminder, the relevant text is sent to Todoist for task creation and detailed date/time parsing. Todoist returns its task ID and confirmed due date.
6. ****Airtable Update:****
   * If a new master entity (e.g., Site) was identified and confirmed for creation, the Flask backend first writes it to the `10NetZero_Main_Datastore` via API.
   * The FLRTS item is then created in the `10NetZero-FLRTS` base, linking to the Todoist Task ID (if applicable) and any master data (Sites, Personnel).
7. ****User Confirmation:**** Bot/MiniApp confirms item creation to the user.

## 3. Data Model (Airtable)

The system will utilize two primary Airtable bases:

### 3.1. `10NetZero_Main_Datastore` Base
This base serves as the Single Source of Truth (SSoT) for core business entities. It is designed as a single Airtable base containing multiple interlinked tables.

#### 3.1.1. `Sites` Table (Master)
* ****Purpose:**** Master list of all operational sites.
* ****Key Fields (See Appendix A for full list):****
  * `SiteID_PK` (Primary Key - e.g., Autonumber, Unique ID like "S001")
  * `SiteName` (Single Line Text, Required)
  * `SiteAddress_Street` (Single Line Text)
  * `SiteAddress_City` (Single Line Text)
  * `SiteAddress_State` (Single Line Text)
  * `SiteAddress_Zip` (Single Line Text)
  * `GPS_Coordinates` (Text or dedicated Lat/Long fields)
  * `SiteStatus` (Single Select: e.g., "Operational", "Under Construction", "Planned", "Decommissioned")
  * `Operator_Link` (Link to `Operators` table - one operator per site)
  * `Site_Partner_Assignments_Link` (Link to `Site_Partner_Assignments` table - shows all partner links for this site)
  * `Site_Vendor_Assignments_Link` (Link to `Site_Vendor_Assignments` table - shows all vendor assignments for this site)
  * `Licenses_Agreements_Link` (Link to `Licenses & Agreements` table - shows all contracts/permits associated with this site)
  * `Equipment_At_Site_Link` (Link to `Equipment` table - shows all general equipment at this site)
  * `ASICs_At_Site_Link` (Link to `ASICs` table - shows all ASICs at this site)
  * `SOP_Notes` (Long Text)
  * `IsActive` (Checkbox)

#### 3.1.2. `Personnel` Table (Master)
* ****Purpose:**** Master list of all employees/users who might interact with or be referenced in the system.
* ****Key Fields (See Appendix A for full list):****
  * `PersonnelID_PK` (Primary Key - e.g., Autonumber, Employee ID)
  * `FullName` (Single Line Text, Required)
  * `WorkEmail` (Email, Unique)
  * `TelegramUserID` (Text or Number, Unique, for bot interaction)
  * `TelegramHandle` (Text, Optional)
  * `RoleTitle` (Single Line Text, e.g., "Field Technician", "Ops Manager")
  * `Assigned_Equipment_Log_Link` (Link to `Employee_Equipment_Log` table - shows equipment assigned to this person)
  * `IsActive` (Checkbox)

#### 3.1.3. `Partners` Table (Master)
* ****Purpose:**** Master list of partner organizations/individuals.
* ****Key Fields (See Appendix A for full list):****
  * `PartnerID_PK` (Primary Key - Autonumber or unique identifier)
  * `PartnerName` (Single Line Text, Required)
  * `PartnerType` (Single Select: e.g., "Investor", "Strategic Partner")
  * `ContactPerson` (Text)
  * `Email` (Email)
  * `Phone` (Phone)
  * `Address` (Long Text)
  * `Site_Assignments_Link` (Link to `Site_Partner_Assignments` table - shows all site assignments for this partner)
  * `Notes` (Long Text)

#### 3.1.4. `Site_Partner_Assignments` Table (Junction Table)
* ****Purpose:**** Links `Sites` and `Partners` to define specific partnership details for each site.
* ****Key Fields (See Appendix A for full list):****
  * `AssignmentID_PK` (Primary Key - Autonumber or unique ID)
  * `LinkedSite` (Link to `Sites` table - one site per assignment)
  * `LinkedPartner` (Link to `Partners` table - one partner per assignment)
  * `PartnershipStartDate` (Date)
  * `PartnerRoleInSite` (Single Select or Text, e.g., "Lead Investor," "Technical Advisor")
  * `OwnershipPercentage` (Percent)
  * `PartnerResponsibilities` (Long Text)
  * `10NZ_Responsibilities` (Long Text)
  * `PartnershipContract_Link` (Link to `Licenses & Agreements` table - if contract is stored there, or Attachment field here)
  * `Notes` (Long Text)

#### 3.1.5. `Vendors` Table (Master)
* ****Purpose:**** Master list of vendor organizations/individuals.
* ****Key Fields (See Appendix A for full list):****
  * `VendorID_PK` (Primary Key - Autonumber or unique identifier)
  * `VendorName` (Single Line Text, Required)
  * `ServiceType` (Single Select or Text, e.g., "Electrical Contractor," "Logistics," "Security")
  * `ContactPerson` (Text)
  * `Email` (Email)
  * `Phone` (Phone)
  * `Address` (Long Text)
  * `Site_Assignments_Link` (Link to `Site_Vendor_Assignments` table - shows all site assignments for this vendor)
  * `Notes` (Long Text)

#### 3.1.6. `Site_Vendor_Assignments` Table (Junction Table)
* ****Purpose:**** Links `Sites` and `Vendors` to define specific service or supply details for each site.
* ****Key Fields (See Appendix A for full list):****
  * `VendorAssignmentID_PK` (Primary Key - Autonumber or unique ID)
  * `LinkedSite` (Link to `Sites` table - one site per assignment)
  * `LinkedVendor` (Link to `Vendors` table - one vendor per assignment)
  * `ServiceStartDate` (Date)
  * `ServiceEndDate` (Date, optional)
  * `ServiceDescription_SiteSpecific` (Long Text)
  * `SiteSpecific_Pricing_Notes` (Long Text)
  * `VendorContract_Link` (Link to `Licenses & Agreements` table - if contract stored there, or Attachment field here)
  * `Notes` (Long Text)

#### 3.1.7. `Equipment` Table (Master - General Assets)
* ****Purpose:**** Master list of general physical assets (non-ASIC).
* ****Key Fields (See Appendix A for full list):****
  * `AssetTagID_PK` (Primary Key - Text, Unique, e.g., "10NZ-GEN-001")
  * `EquipmentName` (Text, e.g., "Honda GX390 Generator")
  * `EquipmentType` (Single Select: e.g., "Generator", "Pump", "Vehicle", "Heavy Equipment", "Power Tool", "IT Hardware - Laptop", "Safety Gear")
  * `Make` (Text)
  * `Model` (Text)
  * `SerialNumber` (Text, Unique if possible)
  * `SiteLocation_Link` (Link to `Sites` table - multiple links disallowed)
  * `Specifications` (Long Text)
  * `PurchaseDate` (Date)
  * `PurchasePrice` (Currency)
  * `PurchaseReceipt` (Attachment)
  * `CurrentStatus` (Single Select: e.g., "Operational", "Needs Maintenance", "Out of Service", "In Storage")
  * `Eq_Manual` (Attachment)
  * `EquipmentPictures` (Attachment)
  * `Employee_Log_Link` (Link to `Employee_Equipment_Log` table - shows assignment history)
  * `Notes` (Long Text)

#### 3.1.8. `ASICs` Table (Master - Mining Hardware)
* ****Purpose:**** Dedicated master list for Bitcoin mining hardware.
* ****Key Fields (See Appendix A for full list):****
  * `ASIC_ID_PK` (Primary Key - Text, e.g., Serial Number or unique Asset Tag)
  * `ASIC_ModelName` (Text, or Link to a potential future `ASIC_Models_Data` table)
  * `SerialNumber` (Text, Unique)
  * `SiteLocation_Link` (Link to `Sites` table)
  * `RackLocation_In_Site` (Text, e.g., "Container A, Rack 3, Shelf B, Unit 1")
  * `PurchaseDate` (Date)
  * `PurchasePrice` (Currency)
  * `CurrentStatus` (Single Select: "Mining", "Idle", "NeedsRepair", "Error", "Offline", "Decommissioned")
  * `HashRate_Actual_THs` (Number)
  * `PowerConsumption_Actual_W` (Number)
  * `PoolAccount_Link` (Link to `Mining_Pool_Accounts` table)
  * `FirmwareVersion` (Text)
  * `IP_Address` (Text)
  * `MAC_Address` (Text)
  * `LastMaintenanceDate` (Date)
  * `WarrantyExpiryDate` (Date)
  * `Notes` (Long Text)

#### 3.1.9. `Employee_Equipment_Log` Table (Junction Table)
* ****Purpose:**** Tracks equipment/tools lent to employees.
* ****Key Fields (See Appendix A for full list):****
  * `LogID_PK` (Primary Key - Autonumber)
  * `LinkedEmployee` (Link to `Personnel` table)
  * `LinkedEquipment` (Link to `Equipment` table)
  * `DateIssued` (Date)
  * `DateReturned` (Date, null if currently issued)
  * `ConditionIssued` (Single Select or Text)
  * `ConditionReturned` (Single Select or Text)
  * `Notes` (Long Text)

#### 3.1.10. `Operators` Table (Master)
* ****Purpose:**** Master list of entities operating the wells/sites.
* ****Key Fields (See Appendix A for full list):****
  * `OperatorID_PK` (Primary Key - Autonumber or unique identifier)
  * `OperatorName` (Text, Required)
  * `ContactPerson` (Text)
  * `Email` (Email)
  * `Phone` (Phone)
  * `Address` (Long Text)
  * `OperatedSites_Link` (Link to `Sites` table - shows all sites this entity operates)
  * `Notes` (Long Text)

#### 3.1.11. `Licenses & Agreements` Table (Master)
* ****Purpose:**** Consolidated repository for contracts, permits, licenses, and other agreements.
* ****Key Fields (See Appendix A for full list):****
  * `AgreementID_PK` (Primary Key - Autonumber or unique identifier)
  * `AgreementName` (Text, Required, e.g., "Site Bravo Gas Purchase FY2025")
  * `AgreementType` (Single Select: "Gas Purchase Agreement", "Permit", "License", "Service Agreement", "Lease Agreement", "Partner Agreement", "Vendor Agreement", "NDA")
  * `Status` (Single Select: "Active", "Expired", "Pending", "Terminated", "Under Review")
  * `CounterpartyName` (Text - name of the other party)
  * `Counterparty_Link_Partner` (Link to `Partners` table, optional)
  * `Counterparty_Link_Vendor` (Link to `Vendors` table, optional)
  * `Counterparty_Link_Operator` (Link to `Operators` table, optional)
  * `Site_Link` (Link to `Sites` table - can allow multiple if agreement covers multiple sites)
  * `EffectiveDate` (Date)
  * `ExpiryDate` (Date)
  * `RenewalReminderDate` (Date)
  * `Document` (Attachment - for the scanned agreement/permit)
  * `KeyTerms_Summary` (Long Text)
  * `Notes` (Long Text)

#### 3.1.12. `Mining_Pool_Accounts` Table (Master)
* ****Purpose:**** Information about accounts with Bitcoin mining pools.
* ****Key Fields (See Appendix A for full list):****
  * `PoolAccountID_PK` (Primary Key - Autonumber or unique identifier)
  * `PoolName` (Text, Required)
  * `PoolWebsite` (URL)
  * `AccountUsername` (Text)
  * `DefaultWorkerNameBase` (Text)
  * `StratumURL_Primary` (Text)
  * `StratumURL_Backup` (Text, optional)
  * `ExpectedFeePercentage` (Percent)
  * `PayoutWalletAddress` (Text - consider security implications if storing actual private keys, which is not recommended here)
  * `API_Key_ForStats` (Text - store securely)
  * `ASICs_Using_Pool_Link` (Link to `ASICs` table - shows ASICs configured for this pool account)
  * `Notes` (Long Text)

### 3.2. `10NetZero-FLRTS` Base
This base holds operational data for the FLRTS application and synced data from the Main Datastore.

#### 3.2.1. `Synced_Sites` Table
* ****Source:**** One-way sync from `Sites` table in `10NetZero_Main_Datastore`.
* ****Purpose:**** Provides a read-only local reference to sites for linking within the FLRTS base.
* ****Fields:**** Mirrors the `Sites` table from the Main Datastore.

#### 3.2.2. `Synced_Personnel` Table
* ****Source:**** One-way sync from `Personnel` table in `10NetZero_Main_Datastore`.
* ****Purpose:**** Provides a read-only local reference to personnel for linking.
* ****Fields:**** Mirrors the `Personnel` table from the Main Datastore.

#### 3.2.3. `Users` Table (FLRTS App Specific)
* ****Purpose:**** Manages FLRTS application-specific user settings, roles, and permissions. Links to the master personnel record.
* ****Key Fields (See Appendix A for full list):****
  * `UserID_PK` (Primary Key - Autonumber)
  * `Personnel_Link` (Link to `Synced_Personnel` table, Required, Unique)
  * `FLRTS_Role` (Single Select: "admin", "user" - as per PDF page 3-4 [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf])
  * `PasswordHash` (Text - conceptual, actual storage/auth handled by Flask backend's auth system)
  * Permission Flags (Checkboxes - as per PDF pages 3, 6, 7 [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]): `Can_Create_Site`, `Can_Configure_Integrations`, etc. (detailed in Appendix A).
  * `DateAdded` (Created Time)


#### **3.2.4.** FLRTS_Items **Table**
* **Purpose:** Core table for all FLRTS items.
* **Key Fields (See Appendix A for full list):**
  * ItemID_PK (Primary Key - Autonumber or UUID)
  * ItemType (Single Select: "Field Report", "List", "Reminder", "Task", "Subtask")
  * Title (Single Line Text, Required - content varies by ItemType, LLM sets to null for new Field Reports)
  * Description (Long Text - main content for Field Reports)
  * Status (Single Select: "Open", "In Progress", "Completed", "Pending", "Archived")
  * Priority (Single Select: "Low", "Medium", "High")
  * DueDate (Date, with time option - authoritative source is Todoist if linked)
  * ReminderTime (Date, with time option - for items where Todoist reminder is not primary)
  * CreatedDate (Created Time)
  * CreatedBy_UserLink (Link to Users table)
  * LastModifiedDate (Last Modified Time)
  * AssignedTo_UserLink (Link to Users table, allow multiple)
  * Site_Link (Link to Synced_Sites table)
  * Scope (Single Select: "site", "general")
  * Visibility (Single Select: "public", "private")
  * ParentItem_Link (Link to another FLRTS_Items record - for subtasks or items in a list)
  * TodoistTaskID (Text, Unique - if synced with Todoist)
  * RawTelegramInput (Long Text)
  * ParsedLLM_JSON (Long Text, AI-enabled in Airtable optional - stores JSON from General LLM)
  * Source (Single Select: "Telegram", "MiniApp", "AdminUI", "SiteGPT Suggestion", "Todoist Sync")
  * IsSystemGenerated **(Checkbox, Default: FALSE)** - Added (TRUE for lists programmatically created by the system, e.g., default site lists)
  * SystemListCategory **(Single Select, Optional)** - Added (e.g., "Site_Tools", "Site_Tasks_Master", "Site_Shopping"; null for user-created items)
  * IsArchived (Checkbox)
  * ArchivedBy_UserLink (Link to Users table)
  * ArchivedAt_Timestamp (Date, with time option)
  * DoneAt_Timestamp (Date, with time option)


#### 3.2.5. `Field_Report_Edits` Table
* **Purpose:** Stores append-only edits for Field Reports, ensuring history is maintained (as per PDF page 8 [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]).
* **Key Fields (See Appendix A for full list):**
  * `EditID_PK` (Primary Key - Autonumber)
  * `ParentFieldReport_Link` (Link to `FLRTS_Items` where `ItemType`="Field Report", Required)
  * `Author_UserLink` (Link to `Users` table, Required)
  * `Timestamp` (Created Time)
  * `EditText` (Long Text, Required)

### 3.3. Data Synchronization Strategy

#### 3.3.1. Main Datastore to FLRTS Base (Airtable Sync)
* `Sites` and `Personnel` tables from `10NetZero_Main_Datastore` will be one-way synced to `Synced_Sites` and `Synced_Personnel` in the `10NetZero-FLRTS` base using Airtable's native sync feature.
* This provides read-access to master data within the FLRTS application context.

#### 3.3.2. FLRTS App Writing to Main Datastore (API)
* If a new Site or Personnel needs to be created via the FLRTS app (e.g., user specifies a new site during task creation):
  1. The Flask backend will first make an API call to the `10NetZero_Main_Datastore` to create the new record (e.g., in the master `Sites` table).
  2. The backend will use the `Record ID` returned from this API call to immediately link the new FLRTS item in the `10NetZero-FLRTS` base.
  3. This ensures data integrity and correct linking, even before Airtable's native sync updates the corresponding `Synced_Sites` or `Synced_Personnel` table.

#### 3.3.3. Todoist and Airtable Synchronization
* **Source of Truth:**
  * Airtable is the SSoT for the complete FLRTS item record and its 10NetZero-specific metadata.
  * Todoist is the SSoT for due dates, completion status, and reminder delivery for items it manages.
* **Initial Creation:** `TodoistTaskID` from Todoist is stored in the Airtable `FLRTS_Items` record. The `DueDate` in Airtable is populated from Todoist's parsed date.
* **Updates (Todoist to Airtable):**
  * Primarily via Todoist Webhooks: When a task is completed, due date changed, etc., in Todoist, a webhook notifies the Flask backend.
  * The Flask backend updates the corresponding `FLRTS_Items` record in Airtable (identified by `TodoistTaskID`).
  * Polling Todoist for changes can be an MVP alternative if webhooks are complex initially.
* **Updates (Airtable to Todoist - Minimized for MVP):** Changes to core task properties (status, due date) in Airtable should ideally be initiated via actions that first update Todoist, with changes flowing back. Direct edits in Airtable to these fields might not sync to Todoist in MVP unless explicitly built.

## 4. User Roles, Permissions, and Access Control
Based on the user's "10NetZero Integrated Platform Design" PDF (pages 3-4, 6-7) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf].

### 4.1. User Roles (in `Users` table, `FLRTS_Role` field)
* **`admin`**: Full access to all features, users, logs, system configuration, and all FLRTS items. Can manage permissions, sites, and other master data via appropriate interfaces. Has override capabilities for most operations.
* **`user`**: Limited access based on assigned permission flags. Can create/manage their own FLRTS items, items assigned to them, and view other items based on scope/visibility settings and their specific permissions.

### 4.2. Permission Flags (Checkbox fields in the `Users` table)
These flags provide granular control over a user's capabilities, supplementing their base role. These are derived from the user's PDF (pages 3, 6, 7) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf].

* **`Can_Manage_Own_General_FLRTS`**: (Default for 'user' role) Allows creation and management of FLRTS items where `Scope` is "general" and the user is the creator or assignee.
* **`Can_Manage_Own_Site_FLRTS`**: (Default for 'user' role) Allows creation and management of FLRTS items where `Scope` is "site" (for sites they have access to, if site-level access control is implemented) and the user is the creator or assignee.
* **`Can_View_Public_General_FLRTS`**: Allows viewing of "general" FLRTS items marked as "public".
* **`Can_View_Public_Site_FLRTS`**: Allows viewing of "site-specific" FLRTS items marked as "public" (for sites they have access to).
* **`Can_Assign_FLRTS`**: Allows the user to assign FLRTS items to other personnel.
* **`Can_Create_Sites_In_Main_Datastore`**: Allows user (likely through FLRTS app interface) to trigger creation of new sites in the `10NetZero_Main_Datastore`. (Corresponds to `can_create_site` from PDF).
* **`Can_Request_FLRTS_Rename`**: Allows submission of rename requests for public/shared FLRTS items (as per `can_request_LRT_rename` from PDF, broadened to FLRTS).
* **`Can_Append_To_Field_Reports`**: Allows any user to append notes to existing Field Reports (as per PDF page 6 "Append-only edits from any user") [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]. The ability to *create* field reports falls under general FLRTS management permissions.
* **Admin-Level Permission Flags (Typically only for 'admin' role, or delegated with caution):**
  * `Can_Manage_All_FLRTS` (Implied for 'admin', overrides ownership/assignment checks)
  * `Can_Manage_Users_And_Permissions` (Corresponds to `can_manage_users` from PDF)
  * `Can_Configure_Integrations` (e.g., Todoist, Webhooks - from PDF)
  * `Can_View_Audit_Log` (from PDF)
  * `Can_Access_DB_Tools` (from PDF, relates to admin dashboard database tools)
  * `Can_Access_System_Settings` (Corresponds to `can_access_system` from PDF)
  * `Can_Delete_Field_Reports` (Admin only, as per PDF page 6) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]
  * `Can_Archive_Field_Reports` (Admin only, as per PDF page 7) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]

### 4.3. FLRT Item Scope and Visibility Rules
These attributes on each `FLRTS_Items` record are crucial for access control, as defined in the PDF (page 3-4) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]:

* **`Scope`**:
  * **`general`**: Item is not tied to a specific site.
  * **`site`**: Item is linked to a specific record in the `Synced_Sites` table.
* **`Visibility`**:
  * **`private`**: Only viewable by the creator, assignees, and administrators (or users with explicit override permissions).
  * **`public`**: Viewable more broadly, depending on scope:
    * General-Public: Potentially viewable by all authenticated users within the organization (if they have `Can_View_Public_General_FLRTS`).
    * Site-Public: Potentially viewable by all users who have access to that specific site and the `Can_View_Public_Site_FLRTS` permission.

### 4.4. Access Control Enforcement
* Permissions will be enforced primarily in the **Flask backend**. Before any action is performed (e.g., creating, viewing, editing, deleting an FLRTS item, accessing admin functions), the backend will check the authenticated user's `FLRTS_Role` and relevant permission flags against the item's properties (creator, assignee, scope, visibility, site linkage).
* The Telegram Bot/MiniApp and Admin Web UI will dynamically render options and display data based on these enforced permissions (elements hidden if not permitted, as per PDF page 6 "UI is permission-aware") [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]. For example, an "edit" button for an FLRTS item will only appear if the current user has the rights to edit that specific item.

## 5. User Interface (UI) and User Experience (UX) Design

### 5.1. Primary Interface: Telegram Bot & MiniApp

#### 5.1.1. Guiding Principles
* **Natural Language First:** User interaction for creating and modifying FLRTS items will prioritize natural language input via the Telegram chat interface or a prominent input field in the MiniApp.
* **Conversational Correction:** Instead of immediately falling back to forms upon NLP ambiguity, the system will present its interpretation to the user and allow for conversational, natural language corrections.
* **Mobile-First & Field-Usability:** Interactions will be designed for quick and easy use on mobile devices, often with one hand, by users in field environments.
* **Context-Aware:** The MiniApp will strive to present relevant information and actions based on the user's current context (e.g., selected item, current view).

#### 5.1.2. FLRTS Item Creation Flow (via Telegram/MiniApp NLP)
As detailed in Section 2.2, this involves:
1. User's natural language input.
2. Backend sends text to General LLM with "bumpers" (valid sites, personnel, etc.).
3. LLM returns structured JSON.
4. MiniApp displays parsed information for user review.
5. User confirms or provides natural language corrections (iterative loop with LLM via backend).
6. Upon confirmation, data is sent to Todoist (if applicable) and Airtable.
7. Final confirmation to user.

#### 5.1.3. Telegram MiniApp - MVP Views and Actions
* **Main View:**
  * Prominent natural language input field: "What needs to be done?" or similar.
  * Optional quick-select buttons for `ItemType` (e.g., `[+Task]`, `[+List]`) to provide hints to the LLM if desired by the user.
  * Tabs/Sections for viewing FLRTS items:
    * "My Open Tasks" (Tasks assigned to user or created by user, not completed/archived)
    * "My Reminders" (Reminder `ItemType` or Tasks with upcoming `ReminderTime`)
    * "My Lists"
    * "My Field Reports"
    * (Future: "All Site Tasks for [Site X]" if a site context is active)
* **Item List View (for each tab):**
  * Concise display: Title, DueDate (if any), Priority, Site (if any).
  * Tap to open Detail View.
* **Item Detail View:**
  * Displays all relevant fields for the selected item.
  * **Actions (permission-dependent):**
    * "Mark Complete" (for Tasks/Reminders - updates Todoist/Airtable).
    * "Archive Item"
    * "Edit Item" (initiates a conversational correction flow with the LLM, or for V2, a focused field editor).
    * "Assign"
    * For Lists: "View Items in List", "Add Item to This List".
    * For Field Reports: "View Content", "Append Note" (using `Field_Report_Edits` table).
* **Review & Confirmation Screen:** (As part of the creation/correction flow) Displays the LLM's interpretation of the user's natural language input before committing changes.

#### 5.1.4. Forms as Fallback/Alternative
* While NLP is primary, the MiniApp might offer an "Advanced Entry" or "Manual Form" option for each FLRTS type if users prefer or if NLP struggles exceptionally (though conversational correction is the preferred first approach to NLP errors).
* These forms would be simple, mobile-friendly, and pre-fill from any prior NLP attempt.

### 5.2. Admin Web UI (Conceptual for MVP)
* **Purpose:** For administrators to perform actions not easily suited to the bot/MiniApp interface.
* **Potential MVP Features:**
  * User Management: View users, assign `FLRTS_Role`, manage permission flags (editing records in the `Users` table).
  * Master Data Management: Interface to view/edit `Sites`, `Personnel`, `Partners`, `Vendors` in the `10NetZero_Main_Datastore` (if direct Airtable access is not preferred for admins).
  * FLRTS Item Overview: A tabular view of all `FLRTS_Items`, with filtering and searching. Potentially bulk actions.
  * System Logs/Audit Trail Viewer (if implemented).
  * Configuration for Integrations (e.g., Todoist API keys, Webhook URLs).
  * Access to SiteGPT console (as per PDF page 3) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf].

## 6. LLM Integration & Prompting

### 6.1. General Purpose LLM (e.g., OpenAI API) for FLRTS Creation

#### 6.1.1. Role
* To parse raw natural language input from users via the Telegram bot/MiniApp.
* To identify user intent (FLRTS item type) and extract key entities (title, description, site, assignee, priority, due date phrases, etc.).
* To provide a structured JSON output for backend processing and user review.
* To formulate a concise string suitable for Todoist's NLP.
* To support the conversational correction loop by re-processing input based on user feedback and prior context.

#### **6.1.2. Initial Prompt Design (Key Elements)**
This prompt is for the General Purpose LLM (e.g., OpenAI API) to parse initial user input for FLRTS creation.
**(Prompt Excerpt - showing revised instructions for Entity Extraction and updated Examples)**
... (Previous parts of the prompt: Role setting, User Input placeholder, Contextual Information/Bumpers placeholder) ...
**Instructions (for the LLM):**
**1** **Identify Item Type:** Determine if the user wants to create a "Field Report", "List", "Reminder", "Task", or "Subtask". If it's a "Subtask", also identify the ParentItem_Link if mentioned or implied.
**2** **Extract Entities:** Extract the following information if present. If not present, use null for the value.
	* ItemType: (As identified above)
	* Title:
		* For **Task, Subtask, Reminder**: Capture the main subject/action of the item here. This will be the primary text from the user for these types.
		* For **List**: Capture the name/title of the list here.
		* For **Field Report**: Set this to null. The backend system will programmatically generate the title for Field Reports.
	* Description:
		* For **Task, Subtask, Reminder**: If the user provides distinct additional details or a longer explanation beyond the main action/subject, capture them here. Often, this may be null if the input is concise and fully captured in Title.
		* For **List**: Capture any additional descriptive text for the list if provided by the user. May be null.
		* For **Field Report**: Capture the full content or body of the field report here. This is the primary input from the user for a field report.
	* Site_Link: The SiteID_PK if a valid site is mentioned. Match against [LIST_OF_SITES_JSON_ARRAY].
	* AssignedTo_UserLink: An array of PersonnelID_PKs if valid personnel are mentioned as assignees. Match against [LIST_OF_PERSONNEL_JSON_ARRAY].
	* Priority: ("Low", "Medium", "High").
	* DueDate_Phrase: Any phrase related to due date, e.g., "tomorrow", "next Friday".
	* ReminderTime_Phrase: Any phrase related to a specific reminder time.
	* Scope: ("site", "general"). Default to "general" unless a Site_Link is identified, then default to "site".
	* Visibility: ("public", "private"). Default to "private".
	* ParentItem_Link: The ItemID_PK of the parent item if this is a subtask or an item being added to an existing list. Match against [LIST_OF_EXISTING_FLRTS_LISTS_JSON_ARRAY] if adding to a list.
**3** **Handle Ambiguity & Site Clarification for Field Reports:**
	* If any part of the input is ambiguous or unclear, or if you have to make a significant assumption, detail this in the parsing_notes field.
	* If ItemType is "Field Report" and no site is specified by the user, set Site_Link to null and note in parsing_notes that "No site specified for Field Report." The backend will handle prompting the user for clarification.
**4** **Formulate Todoist Text:** Create a concise string in text_for_todoist. This string should ideally include the title (or main action for tasks/reminders), due date phrase, priority, and assignee names (not IDs) if applicable. E.g., "Fix leaking faucet at Main Office tomorrow p1 @AliceWonderland". For Field Reports, this can be null.
**5** **Output Format:** Return a single JSON object with the structure previously defined (ItemType, Title, Description, Site_Link, etc., including RawTelegramInput, parsing_notes, text_for_todoist).

⠀**Example User Input (Task):** "Need to schedule quarterly maintenance for the primary generator at North Facility for next Wednesday, assign to Bob The Builder, high priority."

**Example Output (Illustrative for Task):**
```json
{
  "ItemType": "Task",
  "Title": "Schedule quarterly maintenance for the primary generator at North Facility",
  "Description": null,
  "Site_Link": "S002", // Assuming North Facility is S002
  "AssignedTo_UserLink": ["P002"], // Assuming Bob The Builder is P002
  "Priority": "High",
  "DueDate_Phrase": "next Wednesday",
  "ReminderTime_Phrase": null,
  "Scope": "site",
  "Visibility": "private",
  "ParentItem_Link": null,
  "RawTelegramInput": "Need to schedule quarterly maintenance for the primary generator at North Facility for next Wednesday, assign to Bob The Builder, high priority.",
  "parsing_notes": null,
  "text_for_todoist": "Schedule quarterly maintenance for the primary generator at North Facility next Wednesday p1 @BobTheBuilder"
}
```

**Example User Input (Field Report):** 
"Field report from today: West perimeter fence check completed. Section near gate 3 needs repair."

**Example Output (Illustrative for Field Report):**
```json
{
  "ItemType": "Field Report",
  "Title": null, // Backend will generate this
  "Description": "West perimeter fence check completed. Section near gate 3 needs repair.",
  "Site_Link": null, // Assuming no site was mentioned in this specific input
  "AssignedTo_UserLink": [],
  "Priority": null,
  "DueDate_Phrase": null,
  "ReminderTime_Phrase": null,
  "Scope": "general", // Default, or could be "site" if a site was implied by user context not in this text
  "Visibility": "private",
  "ParentItem_Link": null,
  "RawTelegramInput": "Field report from today: West perimeter fence check completed. Section near gate 3 needs repair.",
  "parsing_notes": "No site specified for Field Report. Backend to clarify with user.",
  "text_for_todoist": null
}
```

#### 6.1.3. Prompt for Conversational Corrections
* This prompt will be used when the user indicates changes are needed after the initial LLM interpretation.
* **Inputs to this prompt:**
  * The user's corrective natural language phrase (e.g., "Change the site to Site B and the assignee to Sarah").
  * The *previous JSON output* from the LLM (the one the user wants to correct).
  * The original lists of "bumpers" (sites, personnel, etc.) for validation.
* **Instructions to LLM:**
  * "The user wants to modify the previously understood FLRTS item. Here is the previous interpretation (JSON): `[PREVIOUS_LLM_JSON]`."
  * "Here is the user's correction: `[USER_CORRECTION_TEXT]`."
  * "Update the previous JSON based on the user's correction. Ensure all fields remain valid according to the provided lists of sites, personnel, etc. Pay close attention to the specific changes requested."
  * "Return the complete, updated JSON object in the same format as before."
  * Update `parsing_notes` if the correction introduces new ambiguities or resolves old ones.

### 6.2. SiteGPT (Specialized RAG LLM via TypingMind)

#### 6.2.1. Role
* As defined in the user's "10NetZero Integrated Platform Design" PDF (page 2) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]: answer queries, draft reports, and suggest actions based on uploaded engineering documents.
* This LLM is **not** used for the primary parsing of user commands to create FLRTS items from Telegram.

#### 6.2.2. Integration Points (Conceptual)
* **Admin Web UI:** May have a "GPT Console" or "Ask SiteGPT" section for admins/users to query the document knowledge base.
* **FLRTS Item Enrichment (Future):** SiteGPT could potentially analyze the content of `FLRTS_Items` (e.g., Field Reports) and suggest related documents or insights.
* **Task/Report Generation from Notes (Future):** A user might provide unstructured notes (perhaps related to a site or piece of equipment documented in SiteGPT's knowledge base), and SiteGPT could help structure these into a draft Field Report or suggest relevant Tasks. This output would then feed into the standard FLRTS creation flow.

## 7. Todoist Integration Details
*(To be elaborated: API endpoints used, data mapping, Todoist user authentication/token management, webhook setup for updates.)*

## 8. Other Key Functionalities / Features
*(To be elaborated: Detailed logic for Field Rep

## 9. Future Features
## Potential Future Features to Consider (from Project Documentation & Discussion)

This list includes features mentioned in the user's original "10NetZero Integrated Platform Design" document (PDF Pg 14) and other ideas that have come up, which could be considered for V2+ or further enhancements beyond the initial MVP.

* **Reporting & Analytics:**
  * Report to PDF export (PDF Pg 14)
  * API usage analytics (PDF Pg 14)
  * Enhanced analytics dashboard for FLRTS items and user activity.
  * **ASIC Performance & Viability Analytics:** Logging and analysis of detailed time-series data from ASICs (potentially via API from farm management software) for operational insights, purchasing decisions, and long-term model viability studies. (Related to a potential `ASIC_Performance_Log` table).

* **Extended Integrations & Input Methods:**
  * Webhook alerts to third-party systems (PDF Pg 14)
  * Auto-create FLRTS items from emails (via Gmail API, using GPT for conversion - PDF Pg 14)
  * Google Workspace Integration (Calendar, Drive for more than just SiteGPT docs - PDF Pg 22, 25)
  * Slack or other messaging platform integration.
  * **Automated List Updates from Receipts:** Monitor receipt inputs (e.g., into Airtable or via an expense system) and automatically update relevant FLRTS lists (e.g., shopping lists, project expenses).

* **Enhanced NLP & AI Capabilities:**
  * LLM Middleware for Bot Input (more advanced NLP to structured commands, intent parsing - PDF Pg 14)
  * Confidence scores from the General LLM for `ItemType` classification to trigger clarification flows.
  * Deeper SiteGPT integration for FLRTS item enrichment (e.g., SiteGPT analyzes a Field Report and suggests related documents or insights from its knowledge base).
  * AI-Powered Assistance via vector DB (as mentioned in PDF Pg 24, likely related to SiteGPT or a similar RAG setup for broader data).
  * **LLM Validation for User Inputs:** (e.g., Forcing an "articulable reason" for due date changes by having the LLM evaluate the provided comment).
  * **Advanced RAG for Technical Documents:** (e.g., Linking equipment manuals stored as PDFs to chunked versions for SiteGPT/RAG LLM querying via systems like anythingLLM).

* **User Interface & Experience (UI/UX) Enhancements:**
  * Interactive FLRTS Menus in Telegram/MiniApp (inline action buttons for edit, archive, complete - PDF Pg 14)
  * User Admin Dashboard (limited access UI for non-admin users to manage their settings/preferences - PDF Pg 14)
  * Advanced MiniApp form interactions (V2): Focused field editors like site selectors, user pickers, mini-calendars as an alternative to pure NLP correction for complex edits.
  * Native Mobile App or Progressive Web App (PWA) for a richer mobile experience, potentially with offline capabilities.
  * Multi-language support for the bot and MiniApp.

* **Advanced FLRTS Functionality:**
  * More sophisticated "subtask" management and visualization.
  * Advanced recurring task options beyond what Todoist might offer through its standard parsing, if needed.
  * Offline mode/caching for the MiniApp.
  * **Custom Personal Lists:** Allow users to create their own private lists (viewable by self, admins, and "owners") for personal reminders, tasks, etc., within the FLRTS system.
  * **Task Reassignment with Notes:** Enable users to reassign tasks to other personnel, including an optional note explaining the reassignment.
  * **Due Date Changes with Mandatory Comment:** Require users to provide a mandatory, articulable reason (validated by LLM) when changing task due dates.

* **Operational Enhancements:**
  * Improved API rate-limit handling (PDF Pg 25).
  * More comprehensive automated testing (unit, integration, E2E - PDF Pg 25).
  * Enhanced bot uptime/status monitoring (PDF Pg 25).
  * Expanded audit logs for compliance (PDF Pg 25).