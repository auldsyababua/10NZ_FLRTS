# 10NetZero-FLRTS: LLM Implementation Guide
**Version:** 0.1**Date:** May 9, 2025
**Purpose:** This document serves as a companion to the main System Design Document (SDD) for the 10NetZero-FLRTS project. It provides detailed notes, LLM "meta-prompts," code block structures, and integration instructions for developing the system components, with a strong emphasis on LLM-assisted code generation. Strict compliance with the main SDD (particularly Section 0: AI Collaboration Guide & Project Directives) is assumed.

# 1. Session Log with AI Collaborator

This log tracks key decisions, changes in philosophy, and significant design discussions by session to provide context for future development and AI collaboration.

### Session 7 (AI: Gemini) - may 15, 2025


**Project Handoff: 10NetZero-FLRTS System**

**Date:** May 15, 2025
**Current AI Collaborator:** Gemini (Session 7)
**Next AI Collaborator:** [LLM Name/Version]

**1. Project Overview:**
The 10NetZero-FLRTS system is designed for managing Field Reports, Lists, Reminders, Tasks, and Subtasks. The primary user interface was initially conceived as a Telegram Bot/MiniApp, supported by a Flask backend. Original plans involved Airtable for data storage, and integrations with a General Purpose LLM (for NLP), Todoist (for task/reminder management), and Google Drive (for SOP documents).
**Significant architectural shifts towards using Noloco as the primary UI platform and its internal database ("Noloco Tables") have been decided (see Section 2).**

**2. Current Status & Key Architectural Decisions (as of end of Session 7):**

* **UI Platform:** **Noloco** has been selected as the primary platform for building web-based UIs and dashboards for various user roles.
* **Data Backend:** The project will use **Noloco's internal database ("Noloco Tables")** instead of Airtable.
    * The user is comfortable relying on Noloco's "Data Explorer" / "Data Table 2.0" for administrative data management tasks, foregoing Airtable's direct UI for this purpose.
* **Todoist Integration:** Will be **kept for the MVP phase**, utilized minimally for its specific strengths in NLP for date parsing and its robust reminder engine. A post-MVP evaluation will determine if it can be fully replaced by Noloco's capabilities or custom solutions.
* **Flask Backend Role:** Remains a critical component for:
    * Handling API interactions for the Telegram Bot/MiniApp.
    * Interacting with Noloco's GraphQL API to perform CRUD operations on Noloco Tables.
    * Executing complex programmatic server-side logic (e.g., intricate Google Drive SOP generation steps if Noloco's native integration is insufficient, advanced data transformations).
    * Mediating the Todoist integration (syncing task data with Noloco Tables via its API).
    * Serving as a potential API endpoint for any custom Raycast extensions.
* **Raycast & Raycast AI:** Considered a valuable *complementary* tool for macOS users (including the project lead) to enhance productivity, assist in development (code generation/explanation for extensions, Flask, Noloco API interactions, documentation), and potentially serve as an alternative quick-access interface to the FLRTS system via custom Raycast extensions. It is **not** a replacement for the core Noloco UI, Flask backend, Noloco Tables, or cross-platform interfaces like the Telegram bot.
* **LLM Integration (SDD Section 6):** The SDD section detailing "LLM Integration & Prompting" (original Section 6) has been deferred to "Future Features" by the user. The General Purpose LLM for parsing natural language input (e.g., from Telegram or Raycast) before hitting Flask/Todoist/Noloco is still a component.
* **MVP Roles & Permissions Simplification:** The earlier decision for a single "FLRTS Operator" role for Telegram Bot/MiniApp users (with admin functions out-of-band) still stands but will now be implemented within Noloco's permission system for web UIs. Granular permission flags in the conceptual `Users` table (to be a Noloco Collection) are for future scalability.

**3. Key Documents & Their Status:**

* **`system_design_doc.md` (SDD):**
    * Current Version: 1.5
    * Date: May 14, 2025
    * **Status:** The document header reflects v1.5. However, its content **requires significant updates** to align with the Noloco-centric architecture. Key sections for revision include:
        * Section 2 (System Architecture): Replace Airtable with Noloco Tables, update data flows.
        * Section 3 (Data Model): Rewrite to describe schema implementation in Noloco Collections, revise data synchronization for Noloco & Todoist.
        * Section 4 (User Roles, Permissions, and Access Control): Adapt admin functions considering Noloco's UI and permission model.
        * Section 8 (Other Key Functionalities): Revise programmatic list/SOP creation for Noloco backend, re-think safety nets.
* **`appendix_a.md` (Conceptual Schema Definitions):**
    * Status: The fundamental field definitions are largely intact. However, "Field Type Details" and notes need systematic updating to map Airtable types to Noloco's internal database field types and functionalities. The correction of field 18 in A.1.1 to `Initial_Site_Setup_Completed_by_App` is noted as approved.
* **`implementation_guide.md`:**
    * Current Version: 0.2
    * Date: May 14, 2025
    * Status: Updated with the latest version, date, and Session 6 log. Session 7 details should be added by the next collaborator.
* **`AI_Collaboration_Guide.md`:**
    * Status: Current; no changes made in Session 7. To be strictly adhered to.
* **User-Provided Research & Documentation:**
    * `UI platform deep research GPT-o4-mini-high.md` (Received May 14, 2025)
    * `UI platform deep research GPT4o.md` (Received May 14, 2025)
    * `dataset_website-content-crawler_2025-05-14_22-47-14-154.json` (Noloco documentation dump, received May 14, 2025) - This is now the primary source for Noloco feature capabilities.

**4. Key Outcomes from This Session (Session 7 with Gemini):**

* **Confirmed architectural shift:** Noloco as the UI platform, using Noloco's internal "Collections" (Noloco Tables) as the primary datastore, replacing Airtable.
* **Todoist Role:** Retained for MVP for NLP and reminder engine, with integration into the Noloco/Flask stack.
* **Flask Backend:** Role reaffirmed for API intermediation (Telegram, Noloco, Todoist, GDrive), complex logic.
* **Raycast:** Role defined as a complementary tool for macOS users and development aid, not a core platform replacement.
* **Documentation Review:** Addressed Noloco's internal database capabilities against the project's schema requirements, using user-provided Noloco documentation and research.
* **Handoff Preparation:** Current document generated.

**5. Next Steps / Areas for Immediate Focus (for the Next AI Collaborator):**

* **SDD Revisions (High Priority):**
    * Begin systematically updating the `system_design_doc.md` to reflect the Noloco-centric architecture, starting with:
        * **Section 3 (Data Model):** Detail how the schema in `appendix_a.md` will be implemented in Noloco Tables. This involves mapping field types, relationship handling (junction tables as collections, linked record fields), and how computed fields (formulas, lookups, rollups) will translate to Noloco's capabilities. Update the Data Synchronization Strategy (Flask to Noloco API, Todoist to Noloco via Flask).
        * **Section 2 (System Architecture):** Redraw diagrams and update component descriptions.
        * Subsequently update Sections 4 (Permissions using Noloco's model) and 8 (Key Functionalities like SOP generation, re-evaluating safety nets in Noloco).
* **`appendix_a.md` Detailed Update:**
    * Go through each table and field in `appendix_a.md` and update the "Field Type Details" to accurately reflect Noloco's internal database field types, relationship mechanisms, and how features like unique constraints or custom PKs will be handled (often via Noloco workflows).
* **SDD Section 5 (UI/UX Design):**
    * Based on the selection of Noloco, begin drafting the conceptual UI/UX for the "dream scenario" dashboards and interfaces for different user roles (FLRTS Operator, Site Manager, Admin/Executive). This will involve defining pages, key components on those pages, and user interaction flows within the Noloco environment.
* **Task Management Deep Dive (Post-MVP Planning):**
    * Further detail the plan for potentially phasing out Todoist post-MVP. This includes:
        * Analyzing specific NLP requirements for date/time/recurrence and evaluating if/how they can be met by a general LLM + Flask logic or evolving Noloco features.
        * Designing the reminder/notification system using Noloco's internal workflows (email, in-app, PWA push) and/or Flask.
        * Defining how recurring tasks would be managed within Noloco collections and workflows.
* **`implementation_guide.md` Update:**
    * Add a log entry for this current session (Session 7 with Gemini).

**6. Key Reminders for LLM Collaborator:**

* **Adhere Strictly to `AI_Collaboration_Guide.md`:** Pay close attention to the user interaction protocol (stepwise communication, direct advice), documentation standards (painful detail, layman's terms), code commenting (extreme verbosity, embedded LLM explainer prompts), and the LLM-assisted development philosophy.
* **Modularity & Maintainability:** Prioritize these, even over raw performance for MVP.
* **Stepwise Communication:** Present one main step, question, or topic at a time and await user confirmation/input before proceeding.
* **Latest Source of Truth:** Always treat newly uploaded or modified documents by the user as the latest source. The Noloco documentation JSON is now a key reference.

### Session 6 (AI: Gemini) - May 14, 2025

* Finalized the simplified MVP roles/permissions model (single "FLRTS Operator" for bot, admin functions out-of-band).
* Confirmed keeping granular permission fields in the Users table schema (Appendix A) for future-proofing, while the MVP application logic (SDD Section 4) remains simple.
* Reviewed and confirmed updates to SDD Section 4 (User Roles, Permissions, and Access Control) and Appendix A.2.3 (Users Table) to reflect these decisions.
* Identified minor consistency checks needed across documents, including the field name correction for `Initial_Site_Setup_Completed_by_App` in Appendix A.1.1 and versioning updates.

### Session 5 (AI: Gemini) - may 12, 2025

Yes, we've made significant progress on Appendix A, which details the Airtable field definitions.
Here's a quick summary of where we are:
**1** **System Design Document (SDD) v1.4 (sdd_v1_4)**: This is the main design document currently open in the canvas. I've updated it to reflect our recent decisions regarding SOPs (Google Drive integration), the refined role of SiteGPT for MVP, and other clarifications to ensure consistency with Appendix A.
**2** **Appendix A (sdd_appendix_a)**: This is the live document where we are building the detailed field definitions. So far, we have defined the following tables from the 10NetZero_Main_Datastore base:
	* Sites
	* Personnel
	* Partners
	* Site_Partner_Assignments (Junction Table)
	* Vendors
	* Site_Vendor_Assignments (Junction Table)
	* Equipment (General Assets)
	* ASICs (Mining Hardware)

⠀**Our immediate next step is to define the fields for the Employee_Equipment_Log Table (Junction Table)**, which is Section 3.1.9 in the SDD. I have your previous answers to my questions about this table.
Before I add it to Appendix A, let's finalize the options for the condition fields:
* For ConditionIssued (Single Select), what options should we use? (e.g., "New", "Good", "Fair", "Minor Wear", "Damaged")
* For ConditionReturned (Single Select), should we use the same options, or slightly different ones? (e.g., "Same as Issued", "Good", "Fair", "Minor Wear", "Damaged", "Needs Repair", "Lost/Stolen")

⠀Once we have these, I'll update Appendix A (sdd_appendix_a) with the complete definition for the Employee_Equipment_Log table.


### Session 4 (AI: Gemini) - May 9, 2025
**Key Outcomes & Directives Established:**
* **Refined AI Collaboration Protocol (Now SDD Section 0):**
  * The User (Colin) mandated a shift to a direct, consultant-client interaction model. The AI is to act as an expert consultant, providing frank advice and direct recommendations with clear reasoning.
  * Overly agreeable or obsequious tones are to be avoided.
  * The AI should feel empowered to flag potential issues with User decisions, explaining the rationale and possible negative consequences.
  * Placeholder formatting in documentation standardized to ___USER_INPUT_VALUE_HERE___.
* **Formalized Project Philosophies (Now SDD Section 0):**
  * **Documentation:** Must be of "painful detail," targeting a highly non-technical audience.
  * **Code Commenting:** Mandated extreme verbosity and clarity ("comment the fuck out of this"), using layman's terms. Complex code sections must include embedded LLM "explainer prompts" to help non-SMEs understand or set up the code.
  * **LLM-Assisted Development:** This is a core mandate. The system should be designed with modularity to fit LLM context windows. Performance is secondary to simplicity and LLM-developability. Proactive identification of LLM-generatable components and pre-writing of "meta-prompts" is a key activity.
  * **Logging:** The system must have vigorous, intuitive, layman-friendly logs. The idea of in-terminal LLM log assistance was deferred post-MVP in favor of making native logs exceptionally clear.
* **Creation of this Document:** This 10NetZero-FLRTS_LLM_Implementation_Guide.md was conceptualized and created during this session to house meta-prompts and detailed implementation notes for LLM-driven development.
* **SDD Reorganization:**
  * A new "Section 0: AI COLLABORATION GUIDE & PROJECT DIRECTIVES" was added to the main SDD to capture the above protocols and philosophies.
  * The main SDD and this LLM Implementation Guide are now considered the primary sources for handoff and session continuity, reducing the need for separate handoff documents.
* **Todoist Integration Details (SDD Section 7):**
  * Confirmed system-wide Todoist account (authenticated via a single API token) for MVP.
  * Detailed API endpoints, data mapping, and user authentication flow.
  * Specified webhook setup, including signature validation (X-Todoist-Hmac-SHA256 with ___TODOIST_CLIENT_SECRET___) and an idempotency strategy using the X-Todoist-Delivery-ID header and a store of processed IDs.
* **Next Steps Defined:** Proceed with detailing Appendices (Airtable field lists), then Section 6 (LLM Prompting), then Section 5 (UI/UX). The idea of drafting meta-prompts proactively (starting with the Todoist webhook handler) was strongly endorsed.

⠀
# 2. Component: Todoist Webhook Handler
**Relevant SDD Sections:**
* Main SDD: Section 7.4: Webhook Setup for Updates from Todoist
* Main SDD: Section 7.3: Todoist User Authentication/Token Management (for API token and client secret context)
* Main SDD: Section 0.5: System Logging Philosophy (for logging style within the generated code)
* Main SDD: Section 0.3: Code Commenting Standards

⠀**Environment Variables Required by this Component:**
* ___FLASK_APP_SECRET_KEY___
* ___TODOIST_CLIENT_SECRET___
* ___LOG_LEVEL___
* ___REDIS_HOST___, ___REDIS_PORT___, ___REDIS_PASSWORD___, ___REDIS_DB_WEBHOOK_IDS___ (for post-MVP)
* ___MAX_DELIVERY_ID_CACHE_SIZE_MVP___
* ___DELIVERY_ID_TTL_SECONDS_POST_MVP___

⠀**Libraries/Frameworks:**
* Python 3.x
* Flask
* hmac, hashlib, base64, json, collections.deque
* (Optional post-MVP): redis

⠀
**LLM Meta-Prompt: Generating the Todoist Webhook Handler Flask Endpoint**
Prompt omitted here for brevity. Refer to the original document for the full meta-prompt used to generate the code.

**Code Block Structure (to be generated by LLM based on above prompt):**
Full Python code is written in todoist_webhook_handler.py with detailed comments, logging, and placeholders for downstream processing. This code follows all project guidelines including extreme layman-friendly commenting, modular design, and high verbosity logging.

**Integration Instructions:**
* Import and register the Blueprint todoist_webhook_bp in the main Flask app.
* Load environment variables using python-dotenv or OS config.
* Register the public HTTPS webhook URL in the Todoist App Console.
* Ensure current_app.logger is properly initialized.

⠀
**Testing Notes:**
* **Signature Validation:** Send POST requests with valid, invalid, and missing HMAC headers.
* **Idempotency:** Send duplicate and missing delivery ID headers.
* **Payload Parsing:** Handle valid, invalid, and unsupported event types.
* **Logging:** Review logs for clarity, level appropriateness, and presence of contextual IDs.

⠀
*(More components and their LLM meta-prompts would be added to this document over time as we detail them in the SDD)*

