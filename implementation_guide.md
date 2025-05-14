# 10NetZero-FLRTS: LLM Implementation Guide
**Version:** 0.1**Date:** May 9, 2025
**Purpose:** This document serves as a companion to the main System Design Document (SDD) for the 10NetZero-FLRTS project. It provides detailed notes, LLM "meta-prompts," code block structures, and integration instructions for developing the system components, with a strong emphasis on LLM-assisted code generation. Strict compliance with the main SDD (particularly Section 0: AI Collaboration Guide & Project Directives) is assumed.

# 1. Session Log with AI Collaborator

This log tracks key decisions, changes in philosophy, and significant design discussions by session to provide context for future development and AI collaboration.

### Session 6 (AI: Gemini) - may 14, 2025

* Finalized the simplified MVP roles/permissions model (single "FLRTS Operator" for bot, admin functions out-of-band).
* Confirmed keeping granular permission fields in the Users table schema (Appendix A) for future-proofing, while the MVP application logic (SDD Section 4) remains simple.
* Reviewed and confirmed updates to SDD Section 4 and Appendix A.2.3.
* Identified minor consistency checks for the documents.

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

