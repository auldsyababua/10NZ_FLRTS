# AI Collaboration Guide & Project Directives

**Summary for LLMs:**
This document provides explicit, actionable standards and preferences for any AI assistant, LLM, or human collaborator working with Colin (the "User") on the 10NetZero-FLRTS project. Follow these instructions exactly to ensure all outputs meet the User's requirements for clarity, maintainability, and LLM compatibility.

---

## 1. User Interaction Protocol
- **Role:** Act as an expert consultant; Colin is the client.
- **Guidance:** Always provide direct, honest advice. If a decision is suboptimal, state this clearly and explain why.
- **Tone:** Use clear, professional, and efficient language. Avoid excessive validation or cheerfulness.
- **Recommendations:** Lead with a direct recommendation and reasoning. Offer alternatives only if requested.
- **Detail Level:** Default to level 3 (on a 1-10 scale) unless otherwise specified.
- **Stepwise Communication:** Present one main step or topic at a time. Wait for explicit user cue before proceeding.
- **Follow-up:** Minimize follow-up questions; answer as they arise.
- **Placeholder Format:** For user-supplied values (e.g., API keys), use: ___USER_INPUT_VALUE_HERE___.
- **File Handling:** Treat any newly uploaded document as the latest source of truth.

---

## 2. Documentation & Design Philosophy
- **Painful Detail:** Write all documentation and comments with exhaustive clarity.
- **Audience:** Assume a non-technical user may need to understand, manage, or modify the system.
- **LLM-First:** Structure all documentation and code for easy LLM-assisted development.

---

## 3. Code Commenting Standards
- **Heavy Commenting:** Comment all code thoroughly. Use simple, direct language.
- **LLM Explainer Prompts:** For complex code, embed a clear, self-contained LLM prompt in comments to explain the logic or setup.
- **Examples:**
  - How a security feature works
  - How a data transformation is achieved
  - Setup steps for a module with external configs

---

## 4. Modularity & LLM-Assisted Development
- **Component Granularity:** Design as small, self-contained modules.
- **LLM Context:** Each module should fit within a typical LLM context window.
- **Maintainability:** Favor simplicity and maintainability over performance.
- **Prompt Engineering:**
  - Identify components suitable for LLM generation.
  - Draft meta-prompts or document the context/objectives for LLMs.

---

## 5. Logging Standards
- **Vigorous Logging:** Log extensively and in plain language.
- **Clarity:** Avoid technical jargon; make logs self-explanatory for non-technical users.
- **LLM Log Assist:** (Post-MVP) Consider enabling a shell alias to call an LLM for log explanations.

---

## 6. LLM Prompt Engineering
- **Entity Extraction:** Provide clear, structured prompts for extracting item type, title, description, site, assignee, priority, due date, etc.
- **Conversational Correction:** Instruct LLMs to update previous outputs based on user corrections, using provided lists for validation.
- **Meta-Prompt Example:**
  - "You are an LLM assistant. Here is the previous interpretation (JSON): [PREVIOUS_LLM_JSON]. Here is the user's correction: [USER_CORRECTION_TEXT]. Update the JSON accordingly."

---

## 7. Developer Notes
- **Modularity:** The system is modular to support LLM-driven development by a non-technical lead.
- **Tradeoffs:** Performance may be sacrificed for maintainability and LLM compatibility.
- **Over-Documentation:** Always over-document and over-comment for future LLM or non-technical contributors.

---

## 8. Usage Instructions
- **For LLMs:** Read and follow these standards before generating any code, documentation, or recommendations.
- **For Human Collaborators:** Use this as the reference for interacting with Colin and structuring all outputs for LLM compatibility.

---

## Field Definition Formatting Standards

To ensure clarity, consistency, and ease of use for both humans and AI agents, all field definitions in this project must follow these conventions:

### 1. Description
- **Purpose:** Explains the business meaning and intent of the field.
- **Content:** Clearly state what the field is for and why it exists.
- **Example:**  
  > **Description:** System field. Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists (e.g., Tools List, Master Task List, Shopping List) AND generating and linking the site's SOP Google Document (as detailed in SDD Section 8.1). This flag is crucial for the safety net automations to verify that all initial programmatic setup steps for a new site have been completed by the application.

### 2. Field Type Details
- **Purpose:** Provides specific guidance or important considerations on how to configure this field within Airtable.
- **Content:** Focus on technical setup, such as field type, default values, formulas, or special Airtable features.
- **Example:**  
  > **Field Type Details:** Default value for new records is FALSE.  
  > (Other examples: "Autonumber preferred for simplicity," "Enable rich text formatting," "Formula: ...", "Precision should be at least 6 decimal places.")

### 3. Notes (Optional)
- **Purpose:** For any additional context, usage tips, or clarifications that do not fit in the above.
- **Content:** Use only when needed for extra information about the field's design, usage, or relationships.
- **Example:**  
  > **Notes:** This field is set by automation and should not be edited manually.

### 4. Required
- **Purpose:** Indicates whether the field is required, optional, or system-managed.
- **Content:**  
  > **Required:** Yes  
  > **Required:** No  
  > **Required:** No (System-managed)

---

**Formatting Rules:**
- Always use bolded labels (**Description:**, **Field Type Details:**, **Notes:**, **Required:**).
- Always use the order: Description, Field Type Details, Notes (if present), Required.
- Indent sub-bullets under each field for readability.
- Omit the "Notes" sub-bullet if not needed.
- Do not use italics for these labels.

**Example Field Definition:**

```markdown
18. **Initial_Site_Setup_Completed_by_App** (Checkbox, Default: FALSE)
    * **Description:** System field. Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists (e.g., Tools List, Master Task List, Shopping List) AND generating and linking the site's SOP Google Document (as detailed in SDD Section 8.1). This flag is crucial for the safety net automations to verify that all initial programmatic setup steps for a new site have been completed by the application.
    * **Field Type Details:** Default value for new records is FALSE.
    * **Required:** No (System-managed)
```

---

All contributors and AI agents must follow these conventions for every field definition and review for consistency before submitting changes.

---

*This document may be updated by the User at any time. Always check for the latest version before starting new work.* 