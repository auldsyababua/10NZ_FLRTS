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
- **Transparency in Certainty:**
    - If uncertain about a piece of information, a design implication, or if clarification is needed to provide an accurate response, this uncertainty must be explicitly stated.
    - Avoid projecting confidence when not fully certain, as the User relies on the accuracy of the information provided. It is preferable to ask for clarification or state an assumption than to provide potentially misleading information.
    - Use confident language when warranted by knowledge of provided documents or established design principles, but qualify statements appropriately when venturing into areas with less certainty.

---

## 2. Documentation & Design Philosophy

- **Painful Detail:** Write all documentation and comments with exhaustive clarity.
- **Audience:** Assume a non-technical user may need to understand, manage, or modify the system. All explanations, especially in code comments, should be understandable by someone with basic business logic understanding but no specific programming expertise.
- **No Code Comments Philosophy:** All code comments must be written in plain English, as if explaining the logic to a non-technical manager. Avoid programming jargon. Explain *why* something is done, not just *what* is done.
- **Modularity:** Design components to be as modular and self-contained as possible.
- **Verbosity in Logging:** Implement highly verbose logging with clear, human-readable messages, including contextual IDs (User IDs, Site IDs, Task IDs, etc.) wherever possible.

---

## 3. Supabase PostgreSQL Implementation Standards

The database implementation must follow these standards:

- **Naming Conventions:**
  - Use snake_case for all database objects (tables, columns, functions)
  - Table names should be plural (e.g., sites, partners, vendor_invoices)
  - Primary keys should be named 'id' and use UUID type
  - Display identifiers should be named entity_id_display (e.g., site_id_display)
  - Foreign keys should be named referenced_table_name_id (singular, e.g., site_id, partner_id)
  - Include created_at and updated_at TIMESTAMPTZ fields on all tables

- **Data Types:**
  - Use appropriate PostgreSQL types (VARCHAR, TEXT, DECIMAL, UUID, etc.)
  - For monetary values, use DECIMAL(12,2) for consistent precision
  - For percentages, use DECIMAL(5,2) 
  - For coordinates, use DECIMAL(10,7)
  - For timestamps, use TIMESTAMPTZ to handle time zones

- **Database Logic:**
  - Implement business logic in PostgreSQL functions where possible
  - Use triggers for automatic calculations and audit logging
  - Create views for common query patterns
  - Add appropriate indexes for performance optimization

- **Security:**
  - Implement Row-Level Security policies for data access control
  - Create appropriate roles for different user types
  - Use schema-level organization for security boundaries

---

## 4. Protocol for Document Revisions and Content Generation

When providing textual content intended for direct inclusion or replacement within project documents (e.g., System Design Document, Implementation Guide), and when discussing project details, the following standards must be observed:

* **Clean Content Blocks:** Text blocks provided for copy-pasting must contain *only* the final content intended for the document. Exclude any meta-instructions, editor's notes, parenthetical comments to the User, or instructions on where to place the text (these should be in the surrounding chat, not the content block itself).
* **Contextual Awareness & Authority (for Existing Docs):** When discussing or revising existing project documents that have been provided or previously generated in the session, demonstrate full awareness of that document's content. Avoid speculative phrasing about existing content; instead, make direct statements, comparisons, and revisions based on established facts within the provided documentation, qualified with appropriate certainty levels as per Section 1.
* **Accurate Sectioning and Numbering:** When proposing new sections, subsections, or modifying existing numbered elements, ensure all numbering is accurate, sequential, and consistent with the target document's established structure. Use specific numbers (e.g., "Section 5.4") rather than placeholders (e.g., "Section 5.x").
* **Holistic Revisions:** When significant changes are made to one part of a document, proactively review and update other related or dependent sections to ensure overall document consistency and coherence. The goal is to provide an updated document or section that is internally consistent, minimizing the User's need to manually identify and fix knock-on effects.
* **Clarity on Scope of Revisions & Delivery Method:**
    * Clearly communicate whether a provided text block is a complete replacement for an existing section, an addition, or if it requires the User to integrate it with existing text.
    * **Default Delivery Method for Revisions:** Provide revised sections in standalone code blocks. Multiple sequential revised sections can be in a single code block. If there are breaks (unchanged sections) between revised sections, use a new code block for the next set of revisions. This method is preferred to save tokens, reduce cognitive load on the AI, and ensure the User maintains close control over document integration.
    * **Full Document Rewrites:** Only provide a full rewrite of an entire document if explicitly requested by the User.
* **Prefacing Revisions:** Do not preface content blocks with lengthy explanations of what is about to be provided if the context is already clear from the preceding conversation. Directly provide the revised content block or the concise list of changes as requested.

---

## 5. Database Audit Standards

When conducting database schema audits, follow these standards:

- **Completeness Checks:**
  - Verify all required tables exist
  - Confirm all columns are present with correct data types
  - Validate all relationships and constraints

- **Logical Verification:**
  - Check that business logic functions operate correctly
  - Test triggers fire appropriately
  - Validate calculations are accurate

- **Performance Assessment:**
  - Review index coverage for common query patterns
  - Analyze query execution plans
  - Identify potential bottlenecks

- **Security Evaluation:**
  - Verify Row-Level Security policies
  - Check role-based access controls
  - Assess authentication integration

- **Documentation Alignment:**
  - Compare implementation with specifications
  - Note and justify any deviations from requirements
  - Provide recommendations for improvements

---

*This document may be updated by the User at any time. Always check for the latest version before starting new work.*