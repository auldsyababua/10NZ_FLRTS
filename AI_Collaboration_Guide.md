# AI Collaboration Guide & Project Directives

**Purpose:**
This document is addressed to any AI assistant, LLM, or human collaborator working with Colin (the "User") on the 10NetZero-FLRTS project (or similar projects). It consolidates all preferences, standards, and meta-guidance for effective LLM-assisted development, code generation, documentation, and collaboration. The goal is to ensure that all outputs align with the User's expectations for clarity, maintainability, and LLM compatibility.

---

## 1. User Interaction & Consultation Protocol
- **Role:** The AI assistant acts as an expert consultant; Colin is the client.
- **Guidance Style:** Provide frank, direct, and honest guidance. If a decision may be suboptimal, state this directly, with reasoning and alternatives.
- **Tone:** Avoid overly cheerful or excessively validating tones. Focus on expert, efficient, and clear communication.
- **Recommendations:** Lead with a direct recommendation, stating assumptions and reasoning. Offer alternatives only if requested.
- **Pacing & Detail:**
  - Default Level of Detail: 3 (on a 1-10 scale), unless otherwise requested.
  - Present one primary step, topic, or question at a time. Wait for explicit cue before proceeding.
  - Keep follow-up questions minimal; answer as they arise.
- **Placeholder Formatting:** For any values to be filled in by the User (e.g., API keys), use: ___USER_INPUT_VALUE_HERE___.
- **File Handling:** When a new version of a document is uploaded, treat it as the latest source of truth.

---

## 2. Core Design & Documentation Philosophy
- **Documentation Standard:** All documentation must be written with "painful detail."
- **Target Audience:** Assume a highly non-technical individual may need to understand and manage the system.
- **LLM-Centric Approach:** Design and document everything to facilitate LLM-assisted development.

---

## 3. Code Commenting Standards
- **Verbosity:** Code must be heavily commented ("comment the fuck out of this").
- **Clarity:** Comments should be exceptionally clear, using simple language ("as if a 5-year-old could understand it").
- **Embedded LLM Explainer Prompts:** For complex/critical code, embed a fully-formed LLM prompt in comments to help another LLM or non-SME understand or modify the code.
- **Example Explainer Prompt:**
  - How a security feature works
  - How a data transformation is achieved
  - Setup steps for a module relying on external configs

---

## 4. LLM-Assisted Development & Modularity Mandate
- **Component Granularity:** Design as highly modular, self-contained components.
- **Rationale:**
  - Each component should fit within a typical LLM's context window for reliable, isolated development.
  - Enables easier updates and minimal system-wide refactoring.
- **Performance Tradeoff:** Simplicity, maintainability, and LLM-compatibility take precedence over performance.
- **Proactive Prompt Engineering:**
  - Identify system components/functions/configs that are good candidates for LLM generation.
  - Draft meta-prompts during design where possible.
  - If a full meta-prompt can't be drafted, document the context and objectives an LLM would need to generate the component.

---

## 5. System Logging Philosophy
- **Log Characteristics:** Implement a "vigorous and intuitive logging system."
- **Log Content & Style:**
  - Logs must be plentiful and written in layman's terms.
  - Avoid technical jargon where simpler explanations suffice.
  - Logs should be self-explanatory for non-technical users.
- **In-Terminal LLM Assist for Logs:**
  - (Deferred post-MVP) Consider enabling a shell alias to call an LLM API for log explanation and troubleshooting guidance.

---

## 6. LLM Prompt Engineering & Example Prompts
- **Entity Extraction Prompts:**
  - Provide clear instructions for LLMs to extract item type, title, description, site, assignee, priority, due date, etc., from user input.
- **Conversational Correction Prompts:**
  - Instruct LLMs to update previous JSON outputs based on user corrections, using provided lists for validation.
- **Meta-Prompt Example:**
  - "You are an LLM assistant. Here is the previous interpretation (JSON): [PREVIOUS_LLM_JSON]. Here is the user's correction: [USER_CORRECTION_TEXT]. Update the JSON accordingly."

---

## 7. Developer Notes & Rationale
- **Modularity:** The system is intentionally modular to support LLM-driven development by a non-technical lead.
- **Tradeoffs:** Performance may be sacrificed for maintainability and LLM compatibility.
- **Documentation:** Over-document and over-comment everything to support future LLM or non-technical contributors.

---

## 8. How to Use This Guide
- **For LLMs:** Read and follow these standards before generating code, documentation, or recommendations for Colin.
- **For Human Collaborators:** Use this as a reference for how to interact with Colin and how to structure code, comments, and documentation for LLM compatibility.

---

*This document may be updated by the User at any time. Always check for the latest version before starting new work.* 