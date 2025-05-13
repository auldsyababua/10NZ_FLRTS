# 10NetZero-FLRTS: System Design Document
Version: 1.4 (Incorporated AI Collaboration Guide, Project Directives, and Appendix A refinements)
Date: May 12, 2025
# 0. AI COLLABORATION GUIDE & PROJECT DIRECTIVES
**Purpose of This Section:** These directives are for any AI assistant collaborating with Colin (the "User") on the 10NetZero-FLRTS project. Adherence to these guidelines is paramount for effective collaboration and achieving project goals. This section may be updated by the User throughout the project.
## 0.1. User Interaction & Consultation Protocol (Working with Colin)
* **Role:** The AI assistant shall act as an expert consultant, and Colin as the client.
* **Guidance Style:** Provide frank, direct, and honest guidance. If the User proposes a decision the AI believes may be suboptimal or lead to issues, the AI must state this directly, providing clear reasoning and potential negative consequences (e.g., "I will note that decision. However, you might encounter issues such as [X, Y, Z] down the line because of [reason]. An alternative to consider is [alternative] because [reason for alternative].").
* **Tone:** Avoid overly cheerful, excessively validating, or obsequious tones. The focus is on expert, efficient, and clear communication. Do not feign agreement or disagreement; base all advisory input on expertise relevant to the project's success.
* **Recommendations:** When choices exist, lean towards providing a direct recommendation first, clearly stating the assumptions and reasoning behind it. The User will request alternatives or clarifications if needed.
* **Pacing & Detail:**
* Default Level of Detail for responses: 3 (on a 1-10 scale), unless explicitly requested otherwise by the User for specific topics.
* Present one primary step, topic, or question at a time. Wait for the User's explicit cue (e.g., "Next," "Done," "Okay") before proceeding to the next item.
* Keep follow-up questions minimal; answer questions as they arise.
* **Placeholder Formatting:** For any values the User or a developer needs to input (e.g., API keys, URLs, configuration parameters), use the format: ___USER_INPUT_VALUE_HERE___. The entire string, including the ___ prefixes and suffixes, is to be replaced by the actual value. Literal characters (like quotes) required around the final value will be placed *outside* this placeholder construct.
* **File Handling:** When the User uploads a new version of the SDD or any other document, assume it is the latest source of truth for subsequent discussion and updates.

⠀0.2. Core Design & Documentation Philosophy (User Mandate)
* **Documentation Standard:** All documentation (this SDD, in-repository READMEs, code comments, supplemental guides) must be written with "painful detail."
* **Target Audience:** Assume a highly non-technical individual needs to be able to understand system operations, manage the system, and potentially guide simple modifications using the documentation. Language should be clear, explicit, and avoid unexplained jargon where possible.
* **LLM-Centric Approach:** The entire system design and documentation process should facilitate LLM-assisted development, as the lead developer (User) is non-technical and will rely on LLMs for code generation.

⠀0.3. Code Commenting Standards (User Mandate)
* **Verbosity:** Code must be heavily commented ("comment the fuck out of this"). Comments should be exceptionally clear, using simple language ("as if a 5-year-old could understand it"). Strive for an "overboard" level of commenting.
* **Embedded LLM Explainer Prompts:** For complex or critical sections of code, embed a fully-formed LLM prompt directly within the code comments (e.g., in a multi-line comment block). This prompt should provide sufficient context for another LLM to explain that specific code section or guide a non-SME through its setup/functionality.
* Example explainer prompt context: How a specific security feature works, how a complex data transformation is achieved, setup steps for a particular module relying on external configurations.

⠀0.4. LLM-Assisted Development & Modularity Mandate (User Mandate)
* **Component Granularity:** Design the system as a collection of highly modular, self-contained components.
* **Rationale for Modularity:**
* To align with LLM-based code generation, each component should ideally be simple enough and require context that fits within a typical LLM's single context window for reliable and isolated development/generation.
* To enable easier updates and modifications with minimal system-wide refactoring.
* **Performance Tradeoff:** Performance is a secondary concern to simplicity, maintainability, and LLM-compatibility for development. Sacrifices in performance are acceptable if they improve these primary goals.
* **Proactive Prompt Engineering:**
* Throughout the SDD process, actively identify system components, functions, or configuration files that are good candidates for generation by an LLM using a "meta-prompt."
* Where possible, draft these meta-prompts during the design phase itself.
* If a full meta-prompt cannot be drafted immediately, document the specific information, context, and objectives an LLM would need to generate the component. The aim is to create documentation that is "95% of the way" to enabling successful code generation with minimal additional prompting by the User.

⠀0.5. System Logging Philosophy (User Mandate for System Design)
* **Log Characteristics:** The system must implement a "vigorous and intuitive logging system."
* **Log Content & Style:**
* Logs must be plentiful ("all over the place").
* Logs must be written in clear, layman's terms, as if a non-technical person will be reading them for troubleshooting.
* Avoid overly technical jargon where simpler explanations suffice.
* Focus on logs being self-explanatory to the greatest extent possible for MVP, reducing the need for external tools to interpret them.
* **In-Terminal LLM Assist for Logs:** This concept is deferred post-MVP. Focus for MVP is on making the native application logs exceptionally clear.

⠀*(The rest of the SDD, starting with Section 1. Introduction, would follow)*
# 1. Introduction### 1.1. Purpose of the Document
This document outlines the design specifications for the 10NetZero-FLRTS (Field Reports, Lists, Reminders, Tasks, and Subtasks) system. It details the system architecture, data model, user interaction flows, third-party integrations, and core functionalities. This document serves as a foundational guide for the development and implementation of the MVP (Minimum Viable Product) and provides a roadmap for future enhancements.
## 1.2. System Overview (10NetZero-FLRTS)
The 10NetZero-FLRTS system is designed to be a comprehensive platform for managing operational items such as field reports, lists, reminders, and tasks. It aims to streamline workflows for users, particularly those in field operations, by leveraging natural language processing, a robust data backend, and seamless integration with tools like Telegram and Todoist. The system will feature a Telegram bot and MiniApp as the primary user interfaces, supported by a Flask backend, Airtable databases, and AI capabilities for parsing. Integration of specialized AI for document-based knowledge work (like SiteGPT concepts) is deferred post-MVP. This system integrates and expands upon concepts from the user's "10NetZero Integrated Platform Design (TgBot + SiteGPT)" document.
## 1.3. Core Goals
* **Centralized Data Management:** Establish a single source of truth for core business entities and FLRTS items.
* **Intuitive User Experience:** Prioritize natural language input and conversational interfaces for ease of use, especially on mobile devices.
* **Efficient Workflow Automation:** Streamline the creation, assignment, and tracking of FLRTS items.
* **Seamless Integration:** Leverage existing tools like Todoist for their strengths in task management and reminders.
* **Scalability and Maintainability:** Design a modular architecture that can adapt to future needs and growth.

⠀2. System Architecture### 2.1. Key Components
The 10NetZero-FLRTS system comprises the following key components:
**1** **Telegram Bot & MiniApp (Primary User Interface):**
* Built using the Telegram Bot API.
* MiniApp for richer UI interactions within Telegram (e.g., displaying lists, review/confirmation screens).
* Handles user input (natural language, button interactions) and displays system responses.
**2** **Flask Backend (Application Server):**
* Python-based web server using the Flask framework.
* Hosts the API endpoints for the Telegram bot/MiniApp.
* Orchestrates interactions between other components (LLM, Todoist, Airtable, Google Drive for SOPs).
* Manages business logic, user authentication (for web admin UI), and permissions.
**3** **General Purpose LLM (e.g., OpenAI API):**
* Used for parsing natural language input from users to create structured FLRTS data.
* Identifies item types, extracts entities (titles, descriptions, sites, assignees, dates), and prepares text for Todoist.
**4** **Todoist (Task Management & Reminders):**
* Integrated via its API.
* Handles detailed NLP for dates, times, and recurring patterns for tasks and reminders.
* Manages the lifecycle of tasks (creation, completion) and the delivery of reminders.
* Serves as the source of truth for due dates and completion status of tasks managed within it.
**5** **Airtable (Data Storage):**
* **10NetZero_Main_Datastore Base:** The central repository for master data (Sites, Personnel, Partners, Vendors, etc.).
* **10NetZero-FLRTS Base:** Stores operational data specific to the FLRTS application, including FLRTS_Items and synced master data.
**6** **SiteGPT (Specialized RAG LLM - via TypingMind) - Post-MVP Consideration:**
* As described in the user's "10NetZero Integrated Platform Design" PDF (page 2) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf].
* A custom RAG-powered LLM backend trained on engineering documents.
* Used for answering queries, drafting reports, and suggesting actions based on these specialized documents, distinct from the general FLRTS NLP.
* **Note:** Full integration of SiteGPT is deferred post-MVP. Initial focus is on core FLRTS and master data management.
**7** **Admin Web UI (Conceptual for MVP):**
* A separate web interface for administrators to manage users, permissions, system settings, and potentially view/manage FLRTS items in bulk.
**8** **Google Drive (SOP Document Storage):**
* Integrated via its API.
* Used to automatically create, store, and manage Standard Operating Procedure (SOP) documents for each site.
* Links to these documents are stored in the Sites table in Airtable.

⠀2.2. High-Level Data Flow for FLRTS Creation (Natural Language via Telegram)
**1** **User Input:** User sends a natural language command to the Telegram bot/MiniApp.
**2** **Flask Backend:** Receives the input.
**3** **General LLM Processing:** Backend sends raw text to the General LLM (e.g., OpenAI) with a structured prompt (including "bumpers" like lists of sites/personnel). LLM returns a JSON object with parsed entities and a formatted string for Todoist.
**4** **Review & Correction (MiniApp):** The parsed information is presented to the user for confirmation or conversational correction. This loop continues until the user confirms.
**5** **Todoist Integration:** If the item is a Task or Reminder, the relevant text is sent to Todoist for task creation and detailed date/time parsing. Todoist returns its task ID and confirmed due date.
**6** **Airtable Update:**
* If a new master entity (e.g., Site) was identified and confirmed for creation, the Flask backend first writes it to the 10NetZero_Main_Datastore via API (this includes creating the SOP Google Doc for new sites).
* The FLRTS item is then created in the 10NetZero-FLRTS base, linking to the Todoist Task ID (if applicable) and any master data (Sites, Personnel).
**7** **User Confirmation:** Bot/MiniApp confirms item creation to the user.

⠀3. Data Model (Airtable)The system will utilize two primary Airtable bases:
## 3.1. 10NetZero_Main_Datastore Base
This base serves as the Single Source of Truth (SSoT) for core business entities. It is designed as a single Airtable base containing multiple interlinked tables.
### 3.1.1. Sites Table (Master)
* **Purpose:** Master list of all operational sites, including designated warehouse locations.
* **Key Fields (See Appendix A for full list):**
* SiteID_PK (Primary Key)
* SiteName (Single Line Text, Required)
* SiteAddress_Street (Single Line Text)
* SiteAddress_City (Single Line Text)
* SiteAddress_State (Single Line Text)
* SiteAddress_Zip (Single Line Text)
* SiteLatitude (Number, Decimal)
* SiteLongitude (Number, Decimal)
* SiteStatus (Single Select: e.g., "Commissioning", "Running", "In Maintenance", "Contracted", "Planned", "Decommissioned")
* Operator_Link (Link to Operators table)
* Site_Partner_Assignments_Link (Link to Site_Partner_Assignments table)
* Site_Vendor_Assignments_Link (Link to Site_Vendor_Assignments table)
* Licenses_Agreements_Link (Link to Licenses & Agreements table)
* Equipment_At_Site_Link (Link to Equipment table)
* ASICs_At_Site_Link (Link to ASICs table)
* SOP_Document_Link (URL - Link to Google Doc)
* IsActive (Checkbox)
* Initial_Site_Setup_Completed_by_App (Checkbox, Default: FALSE - System field: Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists and SOP Google Document. Used by safety net automations.)

⠀3.1.2. Personnel Table (Master)
* **Purpose:** Master list of all employees/users who might interact with or be referenced in the system.
* **Key Fields (See Appendix A for full list):**
* PersonnelID_PK (Primary Key)
* FullName (Single Line Text, Required)
* WorkEmail (Email, Unique)
* PhoneNumber (Phone Number)
* TelegramUserID (Number, Unique - for bot interaction)
* TelegramHandle (Single Line Text, Optional)
* EmployeePosition (Single Line Text, e.g., "Field Technician", "Ops Manager")
* StartDate (Date)
* EmploymentContract_Link (Link to Licenses & Agreements table, Optional)
* Assigned_Equipment_Log_Link (Link to Employee_Equipment_Log table)
* IsActive (Checkbox, Default: TRUE)
* Default_Employee_Lists_Created (Checkbox, Default: FALSE - System field: Set to TRUE by the Flask application after successfully creating the employee's default "Onboarding" list. Used by safety net automations.)

⠀3.1.3. Partners Table (Master)
* **Purpose:** Master list of partner organizations or individuals, primarily those with an investment, lending, or funding relationship concerning 10NetZero projects/sites.
* **Key Fields (See Appendix A for full list):**
* PartnerID_PK (Primary Key)
* PartnerName (Single Line Text, Required)
* PartnerType (Single Select: e.g., "Co-Investor", "Site JV Partner", "Lender")
* Logo (Attachment)
* ContactPerson_FirstName (Single Line Text)
* ContactPerson_LastName (Single Line Text)
* Email (Email)
* Phone (Phone Number)
* Address_Street1 (Single Line Text)
* Address_Street2 (Single Line Text)
* Address_City (Single Line Text)
* Address_State (Single Line Text)
* Address_Zip (Single Line Text)
* FullAddress (Formula)
* Website (URL)
* RelevantAgreements_Link (Link to Licenses & Agreements table)
* Site_Assignments_Link (Link to Site_Partner_Assignments table)
* Notes (Long Text)
* IsActive (Checkbox, Default: TRUE)

⠀3.1.4. Site_Partner_Assignments Table (Junction Table)
* **Purpose:** Links Sites and Partners to define specific partnership details for each site.
* **Key Fields (See Appendix A for full list):**
* AssignmentID_PK (Primary Key)
* LinkedSite (Link to Sites table, Required)
* LinkedPartner (Link to Partners table, Required)
* PartnershipStartDate (Date)
* OwnershipPercentage (Percent)
* PartnerResponsibilities (Long Text, Rich Text)
* 10NZ_Responsibilities (Long Text, Rich Text)
* PartnershipContract_Link (Link to Licenses & Agreements table)
* Notes (Long Text)

⠀3.1.5. Vendors Table (Master)
* **Purpose:** Master list of vendor organizations/individuals.
* **Key Fields (See Appendix A for full list):**
* VendorID_PK (Primary Key)
* VendorName (Single Line Text, Required, Unique)
* ServiceType (Multiple Select: e.g., "Electrical Services," "Legal Services")
* ContactPerson_FirstName (Single Line Text)
* ContactPerson_LastName (Single Line Text)
* Email (Email)
* Phone (Phone Number)
* Address_Street1 (Single Line Text)
* Address_Street2 (Single Line Text)
* Address_City (Single Line Text)
* Address_State (Single Line Text)
* Address_Zip (Single Line Text)
* FullAddress (Formula)
* Website (URL)
* RelevantAgreements_Link (Link to Licenses & Agreements table)
* Vendor_General_Attachments (Attachment)
* Site_Assignments_Link (Link to Site_Vendor_Assignments table)
* Notes (Long Text)
* IsActive (Checkbox, Default: TRUE)

⠀3.1.6. Site_Vendor_Assignments Table (Junction Table)
* **Purpose:** Links Sites and Vendors to define specific service or supply details for each site.
* **Key Fields (See Appendix A for full list):**
* VendorAssignmentID_PK (Primary Key)
* LinkedSite (Link to Sites table, Required)
* LinkedVendor (Link to Vendors table, Required)
* ServiceDescription_SiteSpecific (Long Text, Rich Text)
* VendorContract_Link (Link to Licenses & Agreements table)
* Notes (Long Text)

⠀3.1.7. Equipment Table (Master - General Assets)
* **Purpose:** Master list of general physical assets (non-ASIC). A "Warehouse" can be a designated Site record for location tracking.
* **Key Fields (See Appendix A for full list):**
* AssetTagID_PK (Primary Key)
* EquipmentName (Single Line Text, Required)
* Make (Single Line Text)
* Model (Single Line Text)
* EquipmentType (Single Select: e.g., "Generator", "Pump", "Vehicle", "Heavy Equipment", "Power Tool", "IT Hardware - Laptop", "Safety Gear")
* SerialNumber (Single Line Text, Unique if possible)
* SiteLocation_Link (Link to Sites table - can be an operational site or a "Warehouse" site)
* Specifications (Long Text, Rich Text)
* PurchaseDate (Date)
* PurchasePrice (Currency)
* PurchaseReceipt (Attachment)
* CurrentStatus (Single Select: e.g., "Operational", "Needs Maintenance", "Out of Service", "In Storage", "Irreparable/Disposed")
* WarrantyExpiryDate (Date)
* LastMaintenanceDate (Date)
* NextScheduledMaintenanceDate (Date)
* Eq_Manual (Attachment)
* EquipmentPictures (Attachment)
* Employee_Log_Link (Link to Employee_Equipment_Log table)
* Notes (Long Text)

⠀3.1.8. ASICs Table (Master - Mining Hardware)
* **Purpose:** Dedicated master list for Bitcoin mining hardware. A "Warehouse" can be a designated Site record for location tracking.
* **Key Fields (See Appendix A for full list):**
* ASIC_ID_PK (Primary Key - Autonumber, or SerialNumber if reliably unique)
* SerialNumber (Single Line Text, Required, Unique)
* ASIC_Make (Single Select - e.g., "Bitmain," "MicroBT," "Canaan")
* ASIC_Model (Single Select - e.g., "S21 XP," "M60S," "A1366")
* SiteLocation_Link (Link to Sites table - can be an operational site or a "Warehouse" site)
* RackLocation_In_Site (Single Line Text)
* PurchaseDate (Date)
* PurchasePrice (Currency)
* CurrentStatus (Single Select: "Mining", "Idle", "Needs Maintenance", "Error", "Offline", "Decommissioned")
* NominalHashRate_THs (Number, Decimal)
* NominalPowerConsumption_W (Number, Integer)
* HashRate_Actual_THs (Number, Decimal)
* PowerConsumption_Actual_W (Number, Integer)
* PoolAccount_Link (Link to Mining_Pool_Accounts table)
* FirmwareVersion (Single Line Text)
* IP_Address (Single Line Text)
* MAC_Address (Single Line Text)
* LastMaintenanceDate (Date)
* WarrantyExpiryDate (Date)
* ASIC_Manual (Attachment)
* Notes (Long Text)

⠀3.1.9. Employee_Equipment_Log Table (Junction Table)
* **Purpose:** Tracks equipment/tools lent to employees.
* **Key Fields (See Appendix A for full list):**
* LogID_PK (Primary Key)
* LinkedEmployee (Link to Personnel table, Required)
* LinkedEquipment (Link to Equipment table, Required)
* DateIssued (Date, Required)
* DateReturned (Date, null if currently issued)
* ConditionIssued (Single Select: e.g., "New", "Good", "Fair")
* ConditionReturned (Single Select: e.g., "Good", "Fair", "Damaged")
* IsCurrentlyAssigned (Checkbox or Formula based on DateReturned)
* Notes (Long Text, Rich Text)

⠀3.1.10. Operators Table (Master)
* **Purpose:** Master list of entities operating the wells/sites.
* **Key Fields (See Appendix A for full list):**
* OperatorID_PK (Primary Key)
* OperatorName (Text, Required)
* ContactPerson (Text)
* Email (Email)
* Phone (Phone)
* Address (Long Text)
* OperatedSites_Link (Link to Sites table)
* Notes (Long Text)

⠀3.1.11. Licenses & Agreements Table (Master)
* **Purpose:** Consolidated repository for contracts, permits, licenses, and other agreements.
* **Key Fields (See Appendix A for full list):**
* AgreementID_PK (Primary Key)
* AgreementName (Text, Required)
* AgreementType (Single Select: "Gas Purchase Agreement", "Permit", "License", "Service Agreement", "Lease Agreement", "Partner Agreement", "Vendor Agreement", "NDA", "Employment Agreement", "SOW", "PO")
* Status (Single Select: "Active", "Expired", "Pending", "Terminated", "Under Review")
* CounterpartyName (Text)
* Counterparty_Link_Partner (Link to Partners table, optional)
* Counterparty_Link_Vendor (Link to Vendors table, optional)
* Counterparty_Link_Operator (Link to Operators table, optional)
* Counterparty_Link_Personnel (Link to Personnel table, optional - for employment agreements)
* Site_Link (Link to Sites table - can allow multiple)
* EffectiveDate (Date)
* ExpiryDate (Date)
* RenewalReminderDate (Date)
* Document (Attachment)
* KeyTerms_Summary (Long Text, Rich Text)
* Notes (Long Text)

⠀3.1.12. Mining_Pool_Accounts Table (Master)
* **Purpose:** Information about accounts with Bitcoin mining pools.
* **Key Fields (See Appendix A for full list):**
* PoolAccountID_PK (Primary Key)
* PoolName (Text, Required)
* PoolWebsite (URL)
* AccountUsername (Text)
* DefaultWorkerNameBase (Text)
* StratumURL_Primary (Text)
* StratumURL_Backup (Text, optional)
* ExpectedFeePercentage (Percent)
* CurrentTotalHashRate (Number - Intended for periodic update via external process/API)
* PayoutWalletAddress (Text)
* API_Key_ForStats (Text - store securely)
* ASICs_Using_Pool_Link (Link to ASICs table)
* Notes (Long Text)

⠀3.2. 10NetZero-FLRTS Base This base holds operational data for the FLRTS application and synced data from the Main Datastore.
### 3.2.1. Synced_Sites Table
* **Source:** One-way sync from Sites table in 10NetZero_Main_Datastore.
* **Purpose:** Provides a read-only local reference to sites for linking within the FLRTS base.
* **Fields:** Mirrors the Sites table from the Main Datastore.

⠀3.2.2. Synced_Personnel Table
* **Source:** One-way sync from Personnel table in 10NetZero_Main_Datastore.
* **Purpose:** Provides a read-only local reference to personnel for linking.
* **Fields:** Mirrors the Personnel table from the Main Datastore.

⠀3.2.3. Users Table (FLRTS App Specific)
* **Purpose:** Manages FLRTS application-specific user settings, roles, and permissions. Links to the master personnel record (Synced_Personnel).
* **Key Fields (See Appendix A for full list):**
* UserID_PK (Primary Key)
* Personnel_Link (Link to Synced_Personnel table, Required, Unique)
* FLRTS_Role (Single Select: "admin", "manager", "user" - Defines application permissions)
* PasswordHash (Text - conceptual, actual storage/auth handled by Flask backend's auth system)
* Permission Flags (Checkboxes - as per PDF pages 3, 6, 7 [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]): Can_Create_Site, Can_Configure_Integrations, etc. (detailed in Appendix A).
* DateAdded (Created Time)

⠀3.2.4. FLRTS_Items Table * Purpose: Core table for all FLRTS items.
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

⠀3.2.5. Field_Report_Edits Table * Purpose: Stores append-only edits for Field Reports, ensuring history is maintained (as per PDF page 8 [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]).
* **Key Fields (See Appendix A for full list):**
* EditID_PK (Primary Key - Autonumber)
* ParentFieldReport_Link (Link to FLRTS_Items where ItemType="Field Report", Required)
* Author_UserLink (Link to Users table, Required)
* Timestamp (Created Time)
* EditText (Long Text, Required)

⠀3.3. Data Synchronization Strategy #### 3.3.1. Main Datastore to FLRTS Base (Airtable Sync)
* Sites and Personnel tables from 10NetZero_Main_Datastore will be one-way synced to Synced_Sites and Synced_Personnel in the 10NetZero-FLRTS base using Airtable's native sync feature.
* This provides read-access to master data within the FLRTS application context.

⠀3.3.2. FLRTS App Writing to Main Datastore (API)
* If a new Site or Personnel needs to be created via the FLRTS app (e.g., user specifies a new site during task creation):
1 The Flask backend will first make an API call to the 10NetZero_Main_Datastore to create the new record (e.g., in the master Sites table, including triggering SOP Google Doc creation for sites).
2 The backend will use the Record ID returned from this API call to immediately link the new FLRTS item in the 10NetZero-FLRTS base.
3 This ensures data integrity and correct linking, even before Airtable's native sync updates the corresponding Synced_Sites or Synced_Personnel table.

⠀3.3.3. Todoist and Airtable Synchronization
* **Source of Truth:**
* Airtable is the SSoT for the complete FLRTS item record and its 10NetZero-specific metadata.
* Todoist is the SSoT for due dates, completion status, and reminder delivery for items it manages.
* **Initial Creation:** TodoistTaskID from Todoist is stored in the Airtable FLRTS_Items record. The DueDate in Airtable is populated from Todoist's parsed date.
* **Updates (Todoist to Airtable):**
* Primarily via Todoist Webhooks: When a task is completed, due date changed, etc., in Todoist, a webhook notifies the Flask backend.
* The Flask backend updates the corresponding FLRTS_Items record in Airtable (identified by TodoistTaskID).
* Polling Todoist for changes can be an MVP alternative if webhooks are complex initially.
* **Updates (Airtable to Todoist - Minimized for MVP):** Changes to core task properties (status, due date) in Airtable should ideally be initiated via actions that first update Todoist, with changes flowing back. Direct edits in Airtable to these fields might not sync to Todoist in MVP unless explicitly built.

⠀4. User Roles, Permissions, and Access Control*(No changes anticipated in this section based on recent Appendix A updates, but should be reviewed for consistency with field name changes like EmployeePosition vs RoleTitle if they impact role descriptions.)*
... (rest of section 4 as is) ...
# 5. User Interface (UI) and User Experience (UX) Design...
## 5.2. Admin Web UI (Conceptual for MVP)
* **Purpose:** For administrators to perform actions not easily suited to the bot/MiniApp interface.
* **Potential MVP Features:**
* User Management: View users, assign FLRTS_Role, manage permission flags (editing records in the Users table).
* Master Data Management: Interface to view/edit Sites, Personnel, Partners, Vendors in the 10NetZero_Main_Datastore (if direct Airtable access is not preferred for admins). This includes managing the SOP_Document_Link for sites.
* FLRTS Item Overview: A tabular view of all FLRTS_Items, with filtering and searching. Potentially bulk actions.
* System Logs/Audit Trail Viewer (if implemented).
* Configuration for Integrations (e.g., Todoist API keys, Webhook URLs, Google Drive API credentials).
* Access to SiteGPT console (as per PDF page 3) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf] - (Deferred post-MVP).... (rest of section 5 as is) ...

⠀6. LLM Integration & Prompting...
## 6.2. SiteGPT (Specialized RAG LLM via TypingMind) - Post-MVP Consideration
### 6.2.1. Role
* **Note:** Full integration of SiteGPT capabilities as described below is deferred post-MVP.
* As defined in the user's "10NetZero Integrated Platform Design" PDF (page 2) [source: FULL%2010NZ%20Custom%20GPT%20w-%20Telegram%20Bot%20Design%20Doc.pdf.pdf]: answer queries, draft reports, and suggest actions based on uploaded engineering documents.
* This LLM is **not** used for the primary parsing of user commands to create FLRTS items from Telegram in the MVP.

⠀6.2.2. Integration Points (Conceptual for Future)
* **Admin Web UI:** May have a "GPT Console" or "Ask SiteGPT" section for admins/users to query the document knowledge base.
* **FLRTS Item Enrichment (Future):** SiteGPT could potentially analyze the content of FLRTS_Items (e.g., Field Reports) and suggest related documents or insights.
* **Task/Report Generation from Notes (Future):** A user might provide unstructured notes (perhaps related to a site or piece of equipment documented in SiteGPT's knowledge base), and SiteGPT could help structure these into a draft Field Report or suggest relevant Tasks. This output would then feed into the standard FLRTS creation flow.
* SOP Document Interaction (Future): Integrate with SiteGPT to allow users to "talk to" the SOP Google Docs, query their content, and potentially suggest updates via natural language.... (rest of section 6 as is) ...

⠀7. Todoist Integration Details*(No changes anticipated in this section based on recent Appendix A updates.)*
... (rest of section 7 as is) ...
# 8. Other Key Functionalities / Features (MVP)This section details other core operational logic and system behaviors essential for the MVP.
## 8.1. Programmatic Site List & SOP Document Creation
* **Trigger:** Automatically initiated by the Flask backend immediately after a new Site record is successfully created in the 10NetZero_Main_Datastore (typically by a Manager or Admin via the Admin Web UI or an authorized application interface).
* The Flask application will:
1 Create the default FLRTS lists for the site (Tools, Master Task, Shopping).
2 Connect to Google Drive, create a new SOP Google Document (e.g., from a template, titled "[SiteName] - SOP"), and retrieve its shareable link.
3 Store this link in the SOP_Document_Link field of the new Site record.
* Upon successful creation of the site's lists and SOP document, the Flask application will set the Initial_Site_Setup_Completed_by_App flag (Checkbox field) on the Sites record to TRUE. (This replaces the previous Default_Lists_Created_by_App flag to be more comprehensive).
* **Default Lists Created (per new Site):** The following FLRTS_Items of ItemType="List" will be created:
**1** **Site Tools List:**
* Title: "[SiteName] - Tools List"
* Description: "List of tools and general equipment available or needed at [SiteName]."
* SystemListCategory: "Site_Tools_List"
* Scope: "site" (linked to the new Site)
* Visibility: "public" (globally readable by all roles)
* IsSystemGenerated: TRUE
* CreatedBy_UserLink: "System" user.
* AssignedTo_UserLink: Null/Empty.
* Pre-populated items: None by default for MVP.
**2** **Site Master Task List:**
* Title: "[SiteName] - Master Task List"
* Description: "Master list of standard operational tasks and checklists for [SiteName]."
* SystemListCategory: "Site_Master_Task_List"
* Scope: "site"
* Visibility: "public"
* IsSystemGenerated: TRUE
* CreatedBy_UserLink: "System" user.
* AssignedTo_UserLink: Null/Empty.
* Pre-populated items: None by default for MVP (can be added later as standard tasks).
**3** **Site Shopping List:**
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

⠀8.2. Programmatic Employee "Onboarding" List Creation
*(This section remains largely the same as the SOP creation logic is specific to Sites. The safety net here still relies on Default_Employee_Lists_Created.)*
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

⠀... (rest of section 8 as is, with minor wording adjustments if needed for consistency) ...
# 9. Development Phases(No changes anticipated in this section based on recent Appendix A updates.)
... (rest of section 9 as is) ...
# 10. Future Features...
* **Enhanced NLP & AI Capabilities:**
* ...
* **LLM Interaction with SOP Google Docs:** Enable users to query the content of SOP Google Docs using natural language (e.g., "What is the procedure for X at [SiteName]?"). Allow users to request updates or additions to SOP Google Docs via natural language commands, which an LLM would then translate into edits on the actual document (potentially with a confirmation step). This would require deeper Google Drive API integration, including parsing and modifying Google Doc content.
* ...... (rest of section 10 as is) ...

⠀**(Appendix A section within this document would just be a placeholder, as the detailed Appendix A is being built as a separate artifact sdd_appendix_a)**
**Appendix A: Airtable Field Definitions**

*(Refer to the live document artifact with id="sdd_appendix_a" for the complete and detailed field definitions for all Airtable tables.)*
