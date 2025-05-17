# 10NetZero-FLRTS: LLM Implementation Guide

**Version:** 1.0 (Aligning with SDD v2.1)
**Date:** May 15, 2025

**Purpose:** This document serves as a companion to the System Design Document (SDD v2.1) for the 10NetZero-FLRTS project. It provides detailed LLM "meta-prompts," code structure guidance, integration instructions, and testing considerations for developing the system components, with a strong emphasis on LLM-assisted code generation for the Flask backend and other programmatic elements. Strict compliance with the SDD v2.1 and the `AI_Collaboration_Guide.md` is assumed.

---

## 1. Project Overview (Reflecting SDD v2.1)

The 10NetZero-FLRTS system is designed for managing Field Reports, Lists, Reminders, Tasks, and Subtasks (FLRTS). The architecture has been finalized to use:
* **Noloco Tables as the Single Source of Truth (SSoT)** for all data.
* **Noloco Web Application as the primary comprehensive UI** for administrators, office personnel, and for detailed data management or form-based input by any user.
* **A Telegram Bot as a key interaction channel for field technicians**, enabling low-friction FLRTS Create, Read, Update, Delete (CRUD) operations via typed natural language commands (for MVP).
* **A Python Flask backend** acting as the central hub for:
    * Powering the Telegram bot.
    * Performing initial **intent classification** on natural language input from Telegram.
    * Orchestrating **Natural Language Processing (NLP)**:
        * Calling the **Todoist API** directly for its NLP capabilities on task/reminder strings (parsing dates, times, etc.) and for creating tasks in Todoist, which are then synced to Noloco Tables.
        * Calling a **General Purpose LLM API** (e.g., OpenAI) for parsing other natural language inputs like field reports and list updates.
    * Interacting with the **Noloco GraphQL API** for all CRUD operations on Noloco Tables.
    * Managing integrations with **Google Drive API** (for SOP documents) and other services as needed.
    * Handling automated site setup processes (SOP generation, default list creation in Noloco).

This Implementation Guide will detail the meta-prompts, code structures, and integration instructions necessary to build the Flask backend modules and configure the integrations as per the System Design Document v2.1.

---

## 2. Flask Backend Modules: LLM Meta-Prompts

This section provides detailed LLM meta-prompts for generating the Python code for key modules in the Flask backend application. These modules will interact with Noloco, third-party APIs, and handle the core logic of the FLRTS system as defined in the System Design Document (SDD v2.1).

All generated code must adhere to the standards set in the `AI_Collaboration_Guide.md`, including:
* Python 3.x.
* Clear, "No Code Comments" style commenting (explaining the *why* for a non-technical audience).
* Highly verbose logging with contextual IDs.
* Modular design.
* Robust error handling.
* Use of environment variables for all secrets and configurations.

### 2.1. `noloco_client.py` - Noloco GraphQL API Interaction

**Purpose:** This module will encapsulate all interactions with the Noloco GraphQL API. It will handle authentication, constructing GraphQL queries and mutations, sending requests to the Noloco API endpoint, and processing the responses (including error handling). It will provide a simplified interface for other backend modules to perform CRUD operations on Noloco Tables (Collections).

**Key Considerations for LLM:**
* The Noloco API is a GraphQL API.
* Authentication is typically via a Bearer token (API key). This key must be loaded from an environment variable.
* The Noloco API endpoint URL must be loaded from an environment variable.
* All API calls should include robust error handling (network issues, GraphQL errors, Noloco-specific errors in the response).
* Logging should be verbose, indicating the operation being performed, the collection involved, any relevant IDs, and the outcome.
* The module should be designed to be easily extensible for new collections and operations. Consider a generic function for making API calls, which can then be used by more specific functions.
* Refer to "Appendix A: Noloco Table Field Definitions" for collection names and field names when constructing example queries/mutations. Field names in GraphQL queries are typically case-sensitive and match the Noloco field names.

**LLM Meta-Prompt: Generating `noloco_client.py` - Core Structure and Generic API Call Function**

```text
Generate a Python module named `noloco_client.py` for interacting with the Noloco GraphQL API.

The module should:
1.  Import necessary libraries (e.g., `requests`, `json`, `os`, `logging`).
2.  Initialize a logger instance (e.g., `logger = logging.getLogger(__name__)`).
3.  Load Noloco API Key and Noloco API Endpoint URL from environment variables (`NOLOCO_API_KEY`, `NOLOCO_API_URL`). If these are not set, the module should log a critical error and potentially raise an exception or be unusable.
4.  Define a reusable private helper function, `_make_graphql_request(query: str, variables: dict = None) -> dict | None:`, that:
    * Accepts a GraphQL query string and an optional dictionary of variables.
    * Constructs the HTTP headers, including the Authorization header with the Bearer token (API Key) and `Content-Type: application/json`.
    * Constructs the JSON payload with the `query` and `variables`.
    * Makes a POST request to the Noloco API endpoint using the `requests` library.
    * Includes a timeout for the request.
    * Performs robust error handling for the HTTP request (e.g., connection errors, timeouts, non-200 status codes). Logs errors extensively.
    * If the request is successful (status code 200), it parses the JSON response.
    * Checks the parsed JSON response for GraphQL errors (e.g., an `errors` key in the response body). If GraphQL errors are present, logs them and potentially raises a custom exception or returns an error indicator.
    * If no HTTP or GraphQL errors, returns the `data` part of the JSON response.
    * If any error occurs, it should return `None` or raise a specific exception after logging the error.
5.  Include "No Code Comments" style comments explaining the purpose of the module, the environment variables it expects, and the logic of the `_make_graphql_request` function for a non-technical audience.
6.  Ensure all logging messages are highly verbose, human-readable, and include context where possible.
````

**LLM Meta-Prompt: Generating a Function to Fetch Records from a Noloco Collection (Example: Fetching Sites)**

```text
Based on the `noloco_client.py` module structure generated previously (with the `_make_graphql_request` helper function), add a new public function `get_sites(limit: int = 10, offset: int = 0, filters: dict = None) -> list | None:`.

This function should:
1.  Accept optional parameters for `limit` (number of records to return), `offset` (for pagination), and `filters` (a dictionary representing filter conditions, e.g., `{"SiteName_contains": "Alpha"}`). The exact structure of filters will depend on Noloco's GraphQL filter syntax.
2.  Construct a GraphQL query string to fetch records from the "Sites" collection.
    * The query should select key fields from the `Sites` collection as defined in "Appendix A: Noloco Table Field Definitions" (e.g., `SiteID_Display`, `SiteName`, `SiteStatus`, `IsActive`). Ensure field names in the query match Noloco field names.
    * The query should incorporate arguments for pagination (e.g., `first` for limit, `skip` for offset, or equivalent Noloco syntax).
    * Dynamically build the `where` clause for filtering if `filters` are provided, according to Noloco's GraphQL filter syntax.
3.  Prepare the `variables` dictionary for the GraphQL query.
4.  Call the `_make_graphql_request` function with the query and variables.
5.  If the request is successful and data is returned, extract the list of site records from the response (the exact path depends on Noloco's GraphQL schema structure for collections). Each record in the list should be a dictionary.
6.  Return the list of site records.
7.  If the request fails or no data is found, log the situation and return `None` or an empty list as appropriate.
8.  Include "No Code Comments" explaining the function's purpose, parameters, return value, and any assumptions made about Noloco's GraphQL structure.
9.  Ensure verbose logging.
```

**LLM Meta-Prompt: Generating a Function to Create a Record in a Noloco Collection (Example: Creating a Site)**

```text
Based on the `noloco_client.py` module structure, add a new public function `create_site(site_data: dict) -> dict | None:`.

This function should:
1.  Accept a dictionary `site_data` containing the field names and values for the new site. Field names in `site_data` should correspond to Noloco field names in the "Sites" collection.
2.  Construct a GraphQL mutation string to create a new record in the "Sites" collection.
    * The mutation should take input variables corresponding to the fields of the `Sites` collection.
    * The mutation should specify which fields of the newly created site record to return upon success (e.g., `SiteID_PK_Noloco`, `SiteID_Display`, `SiteName`, `CreatedAt`).
3.  Prepare the `variables` dictionary for the GraphQL mutation.
4.  Call the `_make_graphql_request` function with the mutation string and variables.
5.  If the request is successful and data for the created site is returned (depending on Noloco's mutation response structure), return the dictionary representing the newly created site.
6.  If the request fails or the creation is unsuccessful, log the error (including any validation errors returned by Noloco if possible) and return `None`.
7.  Include "No Code Comments" explaining the function's purpose, parameters (especially `site_data` structure), return value, and any assumptions.
8.  Ensure verbose logging.
```

*(Further functions for `update_record`, `delete_record`, and specific CRUD operations for other collections like `Tasks`, `Field_Reports`, `List_Items`, etc., would follow this pattern.)*

### 2.2. `telegram_bot_handler.py` - Telegram Bot Interaction & Initial Intent Classification

*(Meta-prompts to be developed)*

### 2.3. `intent_classifier.py` - Natural Language Intent Classification

*(Meta-prompts to be developed, or logic may be part of `telegram_bot_handler.py`)*

### 2.4. `nlp_service.py` - NLP Orchestration (Todoist & General LLM)

*(Meta-prompts to be developed)*

### 2.5. `site_setup_module.py` - Automated Site Setup

*(Meta-prompts to be developed)*

-----

## 3\. Integration Instructions

This section will detail the setup and configuration required for integrating the Flask backend with external services.

### 3.1. Noloco GraphQL API

*(Instructions on obtaining API keys, endpoint URL, authentication, environment variables: `NOLOCO_API_KEY`, `NOLOCO_API_URL`)*

### 3.2. Telegram Bot API

*(Instructions on creating a bot, obtaining a token, environment variable: `TELEGRAM_BOT_TOKEN`)*

### 3.3. Todoist API

*(Instructions on obtaining an API key, relevant endpoints for Quick Add, environment variable: `TODOIST_API_KEY`)*

### 3.4. General Purpose LLM API (e.g., OpenAI)

*(Instructions on obtaining an API key, relevant endpoints, environment variable: `LLM_API_KEY`, `LLM_MODEL_NAME`)*

### 3.5. Google Drive API

*(Instructions on setting up a service account or OAuth, obtaining credentials, necessary scopes, environment variable for credentials file path: `GOOGLE_APPLICATION_CREDENTIALS`)*

-----

## 4\. Testing Notes

This section will outline testing strategies and specific test cases for different components of the Flask backend.

### 4.1. `noloco_client.py` Tests

*(Test cases for successful/failed CRUD operations, error handling, response parsing)*

### 4.2. Telegram Bot Interaction Tests

*(Test cases for message handling, command parsing, intent classification triggers)*

### 4.3. NLP Service Tests

*(Test cases for Todoist NLP (date parsing), General LLM parsing accuracy for field reports/list items, error handling with NLP services)*

### 4.4. End-to-End Flow Tests

*(Test cases for complete user scenarios, e.g., Telegram input -\> Flask processing -\> Noloco update -\> Telegram feedback)*

