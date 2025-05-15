# **Appendix A: Noloco Table Field Definitions**

This appendix provides detailed field definitions for all Noloco Collections (Tables) used by the 10NetZero-FLRTS system.

## **A.1. 10NetZero_Main_Datastore Base (Conceptual Grouping in Noloco)**

This group of collections serves as the Single Source of Truth (SSoT) for core business entities. In Noloco, these will be individual collections, potentially organized using Noloco's UI features if needed.

### **A.1.1. Sites Collection (Master)**

**Purpose:** Master list of all operational sites.
**SDD Reference:** Section 3.1.1
**Fields:**

1.  **SiteID_PK_Noloco** (Noloco ID)
    * **Description:** Unique system-generated identifier for the site, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **SiteID_Display** (Text)
    * **Description:** Human-readable unique identifier for the site (e.g., "S001"). This can be used for display and reference.
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow upon record creation to ensure uniqueness and formatting.
    * **Required:** Yes

3.  **SiteName** (Text)
    * **Description:** Common, human-readable name for the site. Must be unique.
    * **Field-Type Details:** Noloco Text field. Uniqueness can be enforced via Noloco Workflows or application logic in Flask.
    * **Required:** Yes

4.  **SiteAddress_Street** (Text)
    * **Description:** Street number and name for the site's physical address.
    * **Required:** No

5.  **SiteAddress_City** (Text)
    * **Description:** City for the site's physical address.
    * **Required:** No

6.  **SiteAddress_State** (Text)
    * **Description:** State or province for the site's physical address.
    * **Required:** No

7.  **SiteAddress_Zip** (Text)
    * **Description:** Postal code for the site's physical address.
    * **Required:** No

8.  **SiteLatitude** (Number)
    * **Description:** Latitude of the site in decimal degrees. For mapping and location services.
    * **Field-Type Details:** Noloco Number field, configured for decimal precision. Required for Noloco's Map display type.
    * **Required:** No

9.  **SiteLongitude** (Number)
    * **Description:** Longitude of the site in decimal degrees. For mapping and location services.
    * **Field-Type Details:** Noloco Number field, configured for decimal precision. Required for Noloco's Map display type.
    * **Required:** No

10. **SiteStatus** (Single Option Select)
    * **Description:** Current high-level operational status of the site.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Commissioning", "Running", "In Maintenance", "Contracted", "Planned", "Decommissioned".
    * **Required:** No

11. **Operator_Link** (Relationship)
    * **Description:** Links to the primary operator entity responsible for this site.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Operators` collection.
    * **Required:** No

12. **Site_Partner_Assignments_Link** (Relationship)
    * **Description:** Displays partners associated with this site via the Site_Partner_Assignments junction collection.
    * **Field-Type Details:** Noloco Relationship field, configured as "Has Many" through `Site_Partner_Assignments` collection.
    * **Required:** No

13. **Site_Vendor_Assignments_Link** (Relationship)
    * **Description:** Displays vendors assigned to this site via the Site_Vendor_Assignments junction collection.
    * **Field-Type Details:** Noloco Relationship field, configured as "Has Many" through `Site_Vendor_Assignments` collection.
    * **Required:** No

14. **Licenses_Agreements_Link** (Relationship)
    * **Description:** Links to contracts, permits, or agreements directly associated with this site.
    * **Field-Type Details:** Noloco Relationship field, allowing links to multiple records from the `Licenses & Agreements` collection (Many-to-Many).
    * **Required:** No

15. **Equipment_At_Site_Link** (Relationship)
    * **Description:** Links to records of general equipment (non-ASIC) physically located or primarily assigned to this site.
    * **Field-Type Details:** Noloco Relationship field, allowing linking to multiple `Equipment` records (One-to-Many, where one Site has many Equipment records).
    * **Required:** No

16. **ASICs_At_Site_Link** (Relationship)
    * **Description:** Links to records of ASIC mining hardware physically located or primarily assigned to this site.
    * **Field-Type Details:** Noloco Relationship field, allowing linking to multiple `ASICs` records (One-to-Many, where one Site has many ASIC records).
    * **Required:** No

17. **SOP_Document_Link** (URL)
    * **Description:** Direct link to this site's official Standard Operating Procedure (SOP) master document, stored in Google Drive. This document is automatically generated and linked by the system upon site creation.
    * **Field-Type Details:** Noloco URL field type.
    * **Required:** No

18. **IsActive** (Boolean)
    * **Description:** Indicates if the site record is currently considered active and should appear in regular operational listings and interfaces. Uncheck for temporarily inactive or archived sites.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value can be set to TRUE in Noloco.
    * **Required:** No

19. **Initial_Site_Setup_Completed_by_App** (Boolean)
    * **Description:** System field. Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists (e.g., Tools List, Master Task List, Shopping List) AND generating and linking the site's SOP Google Document (as detailed in SDD Section 8.1). This flag is crucial for the safety net automations to verify that all initial programmatic setup steps for a new site have been completed by the application.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value for new records is FALSE.
    * **Required:** No (System-managed)

### **A.1.2. Personnel Collection (Master)**

**Purpose:** Master list of all personnel (employees, contractors) involved with 10NetZero operations.
**SDD Reference:** Section 3.1.2
**Fields:**

1.  **PersonnelID_PK_Noloco** (Noloco ID)
    * **Description:** Unique system-generated identifier for the personnel record, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **PersonnelID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "P001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow.
    * **Required:** Yes

3.  **FirstName** (Text)
    * **Description:** First name of the individual.
    * **Required:** Yes

4.  **LastName** (Text)
    * **Description:** Last name of the individual.
    * **Required:** Yes

5.  **FullName** (Formula or Text - Noloco)
    * **Description:** Concatenated full name (`FirstName` + " " + `LastName`).
    * **Field-Type Details:** Noloco Formula field (if supported for simple concatenation) or a Text field populated by a Workflow/Flask app. Formula: `CONCATENATE({FirstName}, " ", {LastName})`.
    * **Required:** No (System-managed if formula)

6.  **Email** (Email)
    * **Description:** Primary email address. Must be unique.
    * **Field-Type Details:** Noloco Email field. Uniqueness can be enforced via Noloco Workflows or application logic if not a direct Noloco field constraint.
    * **Required:** Yes

7.  **PhoneNumber** (Phone Number)
    * **Description:** Primary phone number.
    * **Field-Type Details:** Noloco Phone Number field.
    * **Required:** No

8.  **JobTitle** (Text)
    * **Description:** Official job title or role.
    * **Required:** No

9.  **PersonnelType** (Single Option Select)
    * **Description:** Classification of the personnel.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Employee", "Contractor", "Intern", "Advisor".
    * **Required:** Yes

10. **PrimarySite_Link** (Relationship)
    * **Description:** The primary physical site this person is usually based at or responsible for.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

11. **User_Account_Link** (Relationship)
    * **Description:** Links to this person's corresponding record in the `Users` (FLRTS System Users) collection, if they are a system user.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection. This forms a one-to-one link.
    * **Required:** No

12. **IsActive** (Boolean)
    * **Description:** Indicates if the personnel record is currently active.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value can be set to TRUE.
    * **Required:** No

13. **EmergencyContactName** (Text)
    * **Description:** Name of the emergency contact for this person.
    * **Required:** No

14. **EmergencyContactPhone** (Phone Number)
    * **Description:** Phone number of the emergency contact.
    * **Field-Type Details:** Noloco Phone Number field.
    * **Required:** No

15. **ProfilePhoto** (File)
    * **Description:** Profile photo of the personnel.
    * **Field-Type Details:** Noloco File field.
    * **Required:** No

### **A.1.3. Partners Collection (Master)**

**Purpose:** Master list of all external partner organizations.
**SDD Reference:** Section 3.1.3
**Fields:**

1.  **PartnerID_PK_Noloco** (Noloco ID)
    * **Description:** Unique system-generated identifier for the partner, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **PartnerID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "PA001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow.
    * **Required:** Yes

3.  **PartnerName** (Text)
    * **Description:** Official name of the partner organization. Must be unique.
    * **Field-Type Details:** Noloco Text field. Uniqueness can be enforced via Noloco Workflows or application logic.
    * **Required:** Yes

4.  **PartnerType** (Single Option Select)
    * **Description:** Type or category of the partner.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Investor", "Service Provider", "Technology Provider", "Community", "Government", "Other".
    * **Required:** No

5.  **PrimaryContactName** (Text)
    * **Description:** Name of the main contact person at the partner organization.
    * **Required:** No

6.  **PrimaryContactEmail** (Email)
    * **Description:** Email of the main contact person.
    * **Field-Type Details:** Noloco Email field.
    * **Required:** No

7.  **PrimaryContactPhone** (Phone Number)
    * **Description:** Phone number of the main contact person.
    * **Field-Type Details:** Noloco Phone Number field.
    * **Required:** No

8.  **Website** (URL)
    * **Description:** Partner's official website.
    * **Field-Type Details:** Noloco URL field.
    * **Required:** No

9.  **Site_Partner_Assignments_Link** (Relationship)
    * **Description:** Displays sites this partner is associated with via the Site_Partner_Assignments junction collection.
    * **Field-Type Details:** Noloco Relationship field, configured as "Has Many" through `Site_Partner_Assignments` collection.
    * **Required:** No

10. **Licenses_Agreements_Link** (Relationship)
    * **Description:** Links to contracts or agreements involving this partner.
    * **Field-Type Details:** Noloco Relationship field, allowing links to multiple records from the `Licenses & Agreements` collection (Many-to-Many, if a partner can have multiple agreements and an agreement can involve multiple partners, or One-to-Many if an agreement is primarily with one partner).
    * **Required:** No

11. **IsActive** (Boolean)
    * **Description:** Indicates if the partner record is currently active.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value can be set to TRUE.
    * **Required:** No

### **A.1.4. Vendors Collection (Master)**

**Purpose:** Master list of all vendors.
**SDD Reference:** Section 3.1.4
**Fields:**

1.  **VendorID_PK_Noloco** (Noloco ID)
    * **Description:** Unique system-generated identifier for the vendor, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **VendorID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "V001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow.
    * **Required:** Yes

3.  **VendorName** (Text)
    * **Description:** Official name of the vendor company. Must be unique.
    * **Field-Type Details:** Noloco Text field. Uniqueness can be enforced via Noloco Workflows or application logic.
    * **Required:** Yes

4.  **VendorCategory** (Single Option Select)
    * **Description:** Category of products/services the vendor provides.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Hardware", "Software", "Consumables", "Services", "Logistics", "Other".
    * **Required:** No

5.  **PrimaryContactName** (Text)
    * **Description:** Name of the main contact person at the vendor.
    * **Required:** No

6.  **PrimaryContactEmail** (Email)
    * **Description:** Email of the main contact person.
    * **Field-Type Details:** Noloco Email field.
    * **Required:** No

7.  **PrimaryContactPhone** (Phone Number)
    * **Description:** Phone number of the main contact person.
    * **Field-Type Details:** Noloco Phone Number field.
    * **Required:** No

8.  **Website** (URL)
    * **Description:** Vendor's official website.
    * **Field-Type Details:** Noloco URL field.
    * **Required:** No

9.  **PreferredVendor** (Boolean)
    * **Description:** Indicates if this is a preferred vendor.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value FALSE.
    * **Required:** No

10. **Site_Vendor_Assignments_Link** (Relationship)
    * **Description:** Displays sites this vendor is assigned to via the Site_Vendor_Assignments junction collection.
    * **Field-Type Details:** Noloco Relationship field, configured as "Has Many" through `Site_Vendor_Assignments` collection.
    * **Required:** No

11. **Equipment_Link** (Relationship)
    * **Description:** Links to specific equipment items supplied by this vendor.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `Equipment` records (One-to-Many).
    * **Required:** No

12. **ASICs_Link** (Relationship)
    * **Description:** Links to specific ASICs supplied by this vendor.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `ASICs` records (One-to-Many).
    * **Required:** No

13. **Licenses_Agreements_Link** (Relationship)
    * **Description:** Links to contracts or agreements with this vendor.
    * **Field-Type Details:** Noloco Relationship field, allowing links to multiple records from the `Licenses & Agreements` collection.
    * **Required:** No

14. **IsActive** (Boolean)
    * **Description:** Indicates if the vendor record is currently active.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value can be set to TRUE.
    * **Required:** No

### **A.1.5. Operators Collection (Master)**

**Purpose:** Master list of operating entities (can be 10NetZero itself or a third-party).
**SDD Reference:** Section 3.1.5
**Fields:**

1.  **OperatorID_PK_Noloco** (Noloco ID)
    * **Description:** Unique system-generated identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **OperatorID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "OP001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow.
    * **Required:** Yes

3.  **OperatorName** (Text)
    * **Description:** Official name of the operating entity. Must be unique.
    * **Field-Type Details:** Noloco Text field. Uniqueness can be enforced via Noloco Workflows or application logic.
    * **Required:** Yes

4.  **OperatorType** (Single Option Select)
    * **Description:** Type of operator.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Internal (10NetZero)", "Third-Party".
    * **Required:** Yes

5.  **PrimaryContactName** (Text)
    * **Description:** Main contact at the operator.
    * **Required:** No

6.  **PrimaryContactEmail** (Email)
    * **Description:** Email for the main contact.
    * **Field-Type Details:** Noloco Email field.
    * **Required:** No

7.  **PrimaryContactPhone** (Phone Number)
    * **Description:** Phone for the main contact.
    * **Field-Type Details:** Noloco Phone Number field.
    * **Required:** No

8.  **Sites_Operated_Link** (Relationship)
    * **Description:** Links to all sites operated by this entity.
    * **Field-Type Details:** Noloco Relationship field (One-to-Many from Operators to Sites). This is the reverse of `Operator_Link` in the `Sites` collection.
    * **Required:** No

9.  **IsActive** (Boolean)
    * **Description:** Indicates if the operator record is active.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value TRUE.
    * **Required:** No

### **A.1.6. Site_Partner_Assignments Collection (Junction)**

**Purpose:** Junction table to manage the many-to-many relationship between Sites and Partners.
**SDD Reference:** Section 3.1.6
**Fields:**

1.  **AssignmentID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier for the assignment, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **AssignmentID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "SPA001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow. Consider if this display ID is truly necessary or if the combination of Site and Partner is sufficient identification.
    * **Required:** Yes

3.  **Site_Link** (Relationship)
    * **Description:** Links to the `Sites` collection.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** Yes

4.  **Partner_Link** (Relationship)
    * **Description:** Links to the `Partners` collection.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Partners` collection.
    * **Required:** Yes

5.  **Role_Of_Partner_At_Site** (Text)
    * **Description:** Describes the specific role or capacity of the partner at this particular site (e.g., "Lead Investor for Phase 1", "Local Community Liaison").
    * **Required:** No

6.  **Assignment_Active** (Boolean)
    * **Description:** Is this specific site-partner assignment currently active?
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value TRUE.
    * **Required:** No

7.  **Notes** (Long Text)
    * **Description:** Any additional notes about this specific site-partner relationship.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

### **A.1.7. Site_Vendor_Assignments Collection (Junction)**

**Purpose:** Junction table to manage the many-to-many relationship between Sites and Vendors.
**SDD Reference:** Section 3.1.7
**Fields:**

1.  **AssignmentID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier for the assignment, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **AssignmentID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "SVA001").
    * **Field-Type Details:** Noloco Text field. Populated by the Flask application or a Noloco Workflow. Consider if this display ID is truly necessary.
    * **Required:** Yes

3.  **Site_Link** (Relationship)
    * **Description:** Links to the `Sites` collection.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** Yes

4.  **Vendor_Link** (Relationship)
    * **Description:** Links to the `Vendors` collection.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Vendors` collection.
    * **Required:** Yes

5.  **Services_Products_Provided_At_Site** (Text)
    * **Description:** Specific services or products this vendor provides to this site (e.g., "ASIC Repair Services", "Network Cabling Installation").
    * **Required:** No

6.  **Assignment_Active** (Boolean)
    * **Description:** Is this specific site-vendor assignment currently active?
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default value TRUE.
    * **Required:** No

7.  **Notes** (Long Text)
    * **Description:** Any additional notes about this specific site-vendor relationship.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

### **A.1.8. Equipment Collection (Master)**

**Purpose:** Master list of all physical equipment (non-ASIC).
**SDD Reference:** Section 3.1.8
**Fields:**

1.  **EquipmentID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **EquipmentID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "EQ001"). Asset tag number.
    * **Field-Type Details:** Noloco Text field. Should be unique. Populated by Flask or Workflow.
    * **Required:** Yes

3.  **EquipmentName** (Text)
    * **Description:** Common name for the equipment.
    * **Required:** Yes

4.  **EquipmentType** (Single Option Select)
    * **Description:** Category of the equipment.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Networking", "Power Supply", "Cooling", "Security", "Tools", "Computing (Non-ASIC)", "Safety Gear", "Furniture", "Other".
    * **Required:** Yes

5.  **SiteLocation_Link** (Relationship)
    * **Description:** The primary site where this equipment is located or assigned.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

6.  **Vendor_Link** (Relationship)
    * **Description:** The vendor from whom this equipment was procured.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Vendors` collection.
    * **Required:** No

7.  **DatePurchased** (Date)
    * **Description:** Date the equipment was purchased.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

8.  **WarrantyExpiryDate** (Date)
    * **Description:** Date the warranty expires.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

9.  **SerialNumber** (Text)
    * **Description:** Manufacturer's serial number.
    * **Required:** No

10. **Status** (Single Option Select)
    * **Description:** Current status of the equipment.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Operational", "In Repair", "Awaiting Deployment", "Retired", "Missing".
    * **Required:** No

11. **LastMaintenanceDate** (Date)
    * **Description:** Date of last recorded maintenance.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

12. **NextMaintenanceDate** (Date)
    * **Description:** Scheduled date for next maintenance.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

13. **PurchasePrice** (Currency)
    * **Description:** Original purchase price.
    * **Field-Type Details:** Noloco Currency field. Specify currency symbol (e.g., USD).
    * **Required:** No

14. **Attachments** (File)
    * **Description:** Purchase orders, invoices, manuals, photos.
    * **Field-Type Details:** Noloco File field (allows multiple files).
    * **Required:** No

15. **Notes** (Long Text)
    * **Description:** Any other relevant notes.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

### **A.1.9. ASICs Collection (Master)**

**Purpose:** Master list of all ASIC mining hardware.
**SDD Reference:** Section 3.1.9
**Fields:**

1.  **ASIC_ID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **ASIC_ID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "ASIC001"). Asset tag number.
    * **Field-Type Details:** Noloco Text field. Should be unique. Populated by Flask or Workflow.
    * **Required:** Yes

3.  **ASIC_Name_Model** (Text)
    * **Description:** Model name/number of the ASIC (e.g., "Antminer S19 Pro").
    * **Required:** Yes

4.  **SiteLocation_Link** (Relationship)
    * **Description:** The primary site where this ASIC is located.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

5.  **Vendor_Link** (Relationship)
    * **Description:** The vendor from whom this ASIC was procured.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Vendors` collection.
    * **Required:** No

6.  **DatePurchased** (Date)
    * **Description:** Date the ASIC was purchased.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

7.  **WarrantyExpiryDate** (Date)
    * **Description:** Date the warranty expires.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

8.  **SerialNumber** (Text)
    * **Description:** Manufacturer's serial number.
    * **Required:** No

9.  **MAC_Address** (Text)
    * **Description:** MAC address of the ASIC.
    * **Required:** No

10. **IP_Address_Static** (Text)
    * **Description:** Statically assigned IP address (if applicable).
    * **Required:** No

11. **Status** (Single Option Select)
    * **Description:** Current status of the ASIC.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Operational/Mining", "Idle", "In Repair", "Awaiting Deployment", "Retired", "Missing".
    * **Required:** No

12. **NominalHashrate_TH** (Number)
    * **Description:** Manufacturer-specified hashrate in Terahashes per second (TH/s).
    * **Field-Type Details:** Noloco Number field (decimal).
    * **Required:** No

13. **PurchasePrice** (Currency)
    * **Description:** Original purchase price.
    * **Field-Type Details:** Noloco Currency field. Specify currency symbol.
    * **Required:** No

14. **FirmwareVersion** (Text)
    * **Description:** Current firmware version.
    * **Required:** No

15. **LastMaintenanceDate** (Date)
    * **Description:** Date of last recorded maintenance.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

16. **NextMaintenanceDate** (Date)
    * **Description:** Scheduled date for next maintenance.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

17. **Attachments** (File)
    * **Description:** Purchase orders, invoices, manuals, photos.
    * **Field-Type Details:** Noloco File field (allows multiple files).
    * **Required:** No

18. **Notes** (Long Text)
    * **Description:** Any other relevant notes (e.g., known issues, performance quirks).
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

### **A.1.10. Licenses & Agreements Collection (Master)**

**Purpose:** Master list of all licenses, permits, contracts, and other agreements.
**SDD Reference:** Section 3.1.10
**Fields:**

1.  **AgreementID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **AgreementID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "L001", "C001").
    * **Field-Type Details:** Noloco Text field. Populated by Flask or Workflow.
    * **Required:** Yes

3.  **AgreementName** (Text)
    * **Description:** Descriptive name of the agreement (e.g., "Site Alpha Lease Agreement", "Vendor X Service Contract").
    * **Required:** Yes

4.  **AgreementType** (Single Option Select)
    * **Description:** Type of agreement.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Lease", "Service Contract", "License", "Permit", "NDA", "Partnership Agreement", "Insurance Policy", "Other".
    * **Required:** Yes

5.  **Site_Link** (Relationship)
    * **Description:** Site(s) this agreement pertains to (if site-specific).
    * **Field-Type Details:** Noloco Relationship field, allowing links to multiple `Sites` records (Many-to-Many, as an agreement might cover multiple sites, and a site might have multiple agreements).
    * **Required:** No

6.  **Partner_Link** (Relationship)
    * **Description:** Partner(s) involved in this agreement.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `Partners` records.
    * **Required:** No

7.  **Vendor_Link** (Relationship)
    * **Description:** Vendor(s) involved in this agreement.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `Vendors` records.
    * **Required:** No

8.  **CounterpartyName** (Text)
    * **Description:** Name of the external party/parties to the agreement if not covered by Partner/Vendor links (e.g., landlord name, specific government agency).
    * **Required:** No

9.  **EffectiveDate** (Date)
    * **Description:** Date the agreement becomes effective.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

10. **ExpiryDate** (Date)
    * **Description:** Date the agreement expires.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

11. **RenewalDate** (Date)
    * **Description:** Date for next renewal review or action.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

12. **Status** (Single Option Select)
    * **Description:** Current status of the agreement.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Active", "Expired", "Terminated", "Pending Signature", "Under Review".
    * **Required:** No

13. **KeyTerms_Summary** (Long Text)
    * **Description:** Summary of key terms, obligations, and liabilities.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

14. **Document_Link_Internal** (File)
    * **Description:** Scanned copy of the signed agreement, stored directly in Noloco.
    * **Field-Type Details:** Noloco File field (allows multiple files).
    * **Required:** No

15. **Document_Link_External** (URL)
    * **Description:** Link to the document if stored externally (e.g., in a secure document management system).
    * **Field-Type Details:** Noloco URL field.
    * **Required:** No

16. **Responsible_Internal_User_Link** (Relationship)
    * **Description:** Internal user primarily responsible for managing this agreement.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No

17. **IsActive** (Boolean)
    * **Description:** Is this agreement record considered currently relevant/active for operational purposes? (Distinct from legal status).
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default TRUE.
    * **Required:** No

### **A.1.11. Users Collection (FLRTS System Users)**

**Purpose:** Manages user accounts for the FLRTS system, including Telegram IDs and permissions.
**SDD Reference:** Section 3.2.1 (Note: SDD references Airtable Users table, this is the Noloco equivalent)
**Fields:**

1.  **UserID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID. Note: Noloco has its own user management for app access. This collection might duplicate some Noloco user info or be used for users who don't log into Noloco directly but interact via other means (e.g., Telegram bot if that integration remains). For users accessing Noloco, the Noloco User object would be primary. This collection could store *additional* app-specific attributes.
    * **Required:** Yes (System-managed)

2.  **UserID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "U001").
    * **Field-Type Details:** Noloco Text field. Populated by Flask or Workflow.
    * **Required:** Yes

3.  **Personnel_Link** (Relationship)
    * **Description:** Links to the corresponding record in the `Personnel` master data collection. This establishes the connection between a system user and their personnel details.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Personnel` collection (One-to-One).
    * **Required:** Yes

4.  **TelegramID** (Text)
    * **Description:** User's unique Telegram ID. Crucial for Telegram bot interactions.
    * **Field-Type Details:** Noloco Text field.
    * **Required:** No (Required if user interacts via Telegram)

5.  **TelegramUsername** (Text)
    * **Description:** User's Telegram username (e.g., @username).
    * **Field-Type Details:** Noloco Text field.
    * **Required:** No

6.  **NolocoUserEmail** (Email)
    * **Description:** Email address used for Noloco authentication, if this user logs into the Noloco app directly.
    * **Field-Type Details:** Noloco Email field. This might be redundant if Noloco's built-in user data is sufficient.
    * **Required:** No (Required if user logs into Noloco)

7.  **UserRole_FLRTS** (Single Option Select or Multiple Option Select)
    * **Description:** Defines the user's role(s) within the FLRTS application, determining permissions and access levels.
    * **Field-Type Details:** Noloco Single or Multiple Option Select field.
    * **Options:** "Administrator", "Site Manager", "Field Technician", "View Only", "Data Analyst".
    * **Required:** Yes

8.  **LastLogin_FLRTS** (Date & Time)
    * **Description:** Timestamp of the user's last login to the FLRTS system (could be via Noloco or other interfaces).
    * **Field-Type Details:** Noloco Date & Time field. Updated by Flask app or Noloco Workflows.
    * **Required:** No (System-managed)

9.  **IsActive_FLRTS_User** (Boolean)
    * **Description:** Indicates if the FLRTS user account is active.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default TRUE.
    * **Required:** Yes

10. **Preferences_FLRTS** (JSON or Long Text)
    * **Description:** Stores user-specific preferences for the FLRTS application (e.g., notification settings, default views).
    * **Field-Type Details:** Noloco Long Text field (to store JSON string) or Noloco JSON field if available and suitable.
    * **Required:** No

## **A.2. 10NetZero_FLRTS_System_Operational Base (Conceptual Grouping in Noloco)**

This group of collections contains records related to the operational use of the FLRTS system itself.

### **A.2.1. Field_Reports Collection**

**Purpose:** Stores all submitted field reports.
**SDD Reference:** Section 3.3.1
**Fields:**

1.  **ReportID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **ReportID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "FR-S001-20231026-001").
    * **Field-Type Details:** Noloco Text field. Generated by Flask app upon creation, incorporating SiteID, Date, and a daily serial.
    * **Required:** Yes

3.  **Site_Link** (Relationship)
    * **Description:** The site to which this field report pertains.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** Yes

4.  **ReportDate** (Date)
    * **Description:** The date the reported activities or observations occurred.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** Yes

5.  **SubmittedBy_User_Link** (Relationship)
    * **Description:** The FLRTS system user who submitted the report.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** Yes

6.  **SubmissionTimestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when the report was created in the system.
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

7.  **ReportType** (Single Option Select)
    * **Description:** Type or category of the field report.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Daily Operational Summary", "Incident Report", "Maintenance Log", "Safety Observation", "Equipment Check", "Security Update", "Visitor Log", "Other".
    * **Required:** Yes

8.  **ReportTitle_Summary** (Text)
    * **Description:** A brief title or summary of the report's content.
    * **Required:** Yes

9.  **ReportContent_Full** (Long Text)
    * **Description:** The full detailed content of the field report. This is the primary narrative.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** Yes

10. **ReportStatus** (Single Option Select)
    * **Description:** Current status of the report.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Draft", "Submitted", "Under Review", "Actioned", "Archived", "Requires Follow-up".
    * **Default:** "Draft" or "Submitted".
    * **Required:** Yes

11. **Attachments_Files** (File)
    * **Description:** Any photos, videos, or documents attached to the report.
    * **Field-Type Details:** Noloco File field (allows multiple files).
    * **Required:** No

12. **Related_Tasks_Link** (Relationship)
    * **Description:** Links to any FLRTS Tasks that were generated from or are related to this report.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `Tasks` records.
    * **Required:** No

13. **Related_Equipment_Link** (Relationship)
    * **Description:** Links to specific equipment items mentioned or relevant to this report.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `Equipment` records.
    * **Required:** No

14. **Related_ASICs_Link** (Relationship)
    * **Description:** Links to specific ASICs mentioned or relevant to this report.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `ASICs` records.
    * **Required:** No

15. **Edit_History_Link** (Relationship)
    * **Description:** Links to `Field_Report_Edits` records that track changes to this report.
    * **Field-Type Details:** Noloco Relationship field (One-to-Many from Field_Reports to Field_Report_Edits).
    * **Required:** No (System-managed)

16. **LastModifiedTimestamp** (Date & Time - Noloco Last Modified Time)
    * **Description:** Timestamp of when the report was last modified.
    * **Field-Type Details:** Noloco "Last Modified Time" system field.
    * **Required:** Yes (System-managed)

### **A.2.2. Lists Collection**

**Purpose:** Stores various operational lists (Tools, Shopping, Master Tasks, etc.). This is a generic list container.
**SDD Reference:** Section 3.3.2
**Fields:**

1.  **ListID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **ListID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "LST-S001-TOOLS-001").
    * **Field-Type Details:** Noloco Text field. Generated by Flask app.
    * **Required:** Yes

3.  **ListName** (Text)
    * **Description:** Name of the list (e.g., "Site Alpha - Tools Inventory", "Q4 General Shopping List").
    * **Required:** Yes

4.  **ListType** (Single Option Select)
    * **Description:** The type or category of the list, defining its purpose and schema for List Items.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Tools Inventory", "Shopping List", "Master Task List (Template)", "Safety Checklist", "Maintenance Procedure", "Contact List", "Other".
    * **Required:** Yes

5.  **Site_Link** (Relationship)
    * **Description:** The site this list pertains to (if site-specific). Can be blank for global lists.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

6.  **Description** (Long Text)
    * **Description:** A more detailed description of the list's purpose or content.
    * **Field-Type Details:** Noloco Long Text field.
    * **Required:** No

7.  **Owner_User_Link** (Relationship)
    * **Description:** The user primarily responsible for maintaining this list.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No

8.  **Status** (Single Option Select)
    * **Description:** Current status of the list.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Active", "Archived", "Draft", "In Review".
    * **Required:** Yes

9.  **List_Items_Link** (Relationship)
    * **Description:** Links to all items contained within this list.
    * **Field-Type Details:** Noloco Relationship field, linking to multiple `List_Items` records.
    * **Required:** No

10. **IsMasterSOPList** (Boolean)
    * **Description:** Flag indicating if this list is one of the master lists (Tools, Shopping, Master Tasks) automatically generated for a site as part of its SOP.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field. Default FALSE.
    * **Required:** No

11. **CreatedTimestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when the list was created.
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

12. **LastModifiedTimestamp** (Date & Time - Noloco Last Modified Time)
    * **Description:** Timestamp of when the list was last modified.
    * **Field-Type Details:** Noloco "Last Modified Time" system field.
    * **Required:** Yes (System-managed)

### **A.2.3. List_Items Collection**

**Purpose:** Stores individual items within a List. The meaning of its fields depends on the parent List's `ListType`.
**SDD Reference:** Section 3.3.3
**Fields:**

1.  **ListItemID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **ListItemID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "LI-LST001-001").
    * **Field-Type Details:** Noloco Text field. Generated by Flask app.
    * **Required:** Yes

3.  **Parent_List_Link** (Relationship)
    * **Description:** Links to the parent `Lists` record this item belongs to.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Lists` collection.
    * **Required:** Yes

4.  **ItemName_PrimaryText** (Text)
    * **Description:** The main text for the list item (e.g., task description, item name, tool name).
    * **Required:** Yes

5.  **ItemDetail_1_Text** (Text)
    * **Description:** Generic field for additional item detail. Usage depends on ListType. (e.g., For Tools: "Brand/Model"; For Shopping: "Quantity"; For Tasks: "Assignee")
    * **Required:** No

6.  **ItemDetail_2_Text** (Text)
    * **Description:** Generic field. (e.g., For Tools: "Serial Number"; For Shopping: "Preferred Vendor"; For Tasks: "Due Date")
    * **Required:** No

7.  **ItemDetail_3_LongText** (Long Text)
    * **Description:** Generic field for longer text details or notes specific to the item. (e.g., For Tools: "Condition Notes"; For Shopping: "Justification"; For Tasks: "Detailed Description/Sub-steps")
    * **Field-Type Details:** Noloco Long Text field.
    * **Required:** No

8.  **ItemDetail_Boolean_1** (Boolean)
    * **Description:** Generic boolean field. (e.g., For Tasks: "Completed?"; For Shopping: "Purchased?")
    * **Field-Type Details:** Noloco Boolean (Checkbox) field.
    * **Required:** No

9.  **ItemDetail_Date_1** (Date)
    * **Description:** Generic date field. (e.g., For Tasks: "Due Date"; For Tools: "Last Checked")
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

10. **ItemDetail_User_Link_1** (Relationship)
    * **Description:** Generic link to a User. (e.g., For Tasks: "AssignedTo_User_Link")
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No

11. **ItemOrder** (Number)
    * **Description:** Number to define the order of items within a list.
    * **Field-Type Details:** Noloco Number field (integer).
    * **Required:** No

12. **IsComplete_Or_Checked** (Boolean)
    * **Description:** General purpose flag for item completion, checked status, etc.
    * **Field-Type Details:** Noloco Boolean (Checkbox) field.
    * **Required:** No

13. **Attachments** (File)
    * **Description:** Files related to this specific list item (e.g., photo of a tool, receipt for a shopped item).
    * **Field-Type Details:** Noloco File field.
    * **Required:** No

14. **CreatedTimestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when the list item was created.
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

15. **LastModifiedTimestamp** (Date & Time - Noloco Last Modified Time)
    * **Description:** Timestamp of when the list item was last modified.
    * **Field-Type Details:** Noloco "Last Modified Time" system field.
    * **Required:** Yes (System-managed)

*(Note: The generic `ItemDetail_` fields are a flexible approach. For specific `ListTypes` where more structured data is consistently needed, consider creating separate Noloco collections (e.g., `Tool_Items`, `Shopping_List_Items`) that link to a parent `List` record. This current approach maximizes flexibility but relies on application logic to interpret `ItemDetail_` fields based on `Parent_List_Link.ListType`.)*

### **A.2.4. Tasks Collection**

**Purpose:** Stores individual tasks, potentially linked to Todoist or managed natively.
**SDD Reference:** Section 3.3.4
**Fields:**

1.  **TaskID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **TaskID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "TSK-001").
    * **Field-Type Details:** Noloco Text field. Generated by Flask app.
    * **Required:** Yes

3.  **TaskTitle** (Text)
    * **Description:** The main title or description of the task.
    * **Required:** Yes

4.  **TaskDescription_Detailed** (Long Text)
    * **Description:** More detailed description of the task, steps involved, etc.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** No

5.  **AssignedTo_User_Link** (Relationship)
    * **Description:** The user this task is assigned to.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No

6.  **Site_Link** (Relationship)
    * **Description:** The site this task relates to (if any).
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

7.  **Related_Field_Report_Link** (Relationship)
    * **Description:** Links to a field report that generated or is related to this task.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Field_Reports` collection.
    * **Required:** No

8.  **DueDate** (Date)
    * **Description:** When the task is due.
    * **Field-Type Details:** Noloco Date field.
    * **Required:** No

9.  **Priority** (Single Option Select)
    * **Description:** Priority of the task.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "High", "Medium", "Low".
    * **Required:** No

10. **Status** (Single Option Select)
    * **Description:** Current status of the task.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "To Do", "In Progress", "Completed", "Blocked", "Cancelled".
    * **Default:** "To Do".
    * **Required:** Yes

11. **CompletionDate** (Date & Time)
    * **Description:** When the task was marked as completed.
    * **Field-Type Details:** Noloco Date & Time field.
    * **Required:** No

12. **TodoistTaskID** (Text)
    * **Description:** If this task is synced with Todoist, this stores the Todoist Task ID.
    * **Field-Type Details:** Noloco Text field.
    * **Required:** No (System-managed if using Todoist sync)

13. **Parent_Task_Link** (Relationship)
    * **Description:** If this is a subtask, this links to its parent task in this same `Tasks` collection.
    * **Field-Type Details:** Noloco Relationship field, linking to another record in the `Tasks` collection (Self-referencing One-to-Many).
    * **Required:** No

14. **SubTasks_Link** (Relationship)
    * **Description:** Links to any subtasks of this task.
    * **Field-Type Details:** Noloco Relationship field (reverse of Parent_Task_Link).
    * **Required:** No

15. **CreatedBy_User_Link** (Relationship)
    * **Description:** The user who created this task.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No (System-managed or User set)

16. **CreatedTimestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when the task was created.
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

17. **LastModifiedTimestamp** (Date & Time - Noloco Last Modified Time)
    * **Description:** Timestamp of when the task was last modified.
    * **Field-Type Details:** Noloco "Last Modified Time" system field.
    * **Required:** Yes (System-managed)

### **A.2.5. Reminders Collection**

**Purpose:** Stores reminders, potentially linked to Todoist or managed natively.
**SDD Reference:** Section 3.3.5
**Fields:**

1.  **ReminderID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **ReminderID_Display** (Text)
    * **Description:** Human-readable unique identifier (e.g., "REM-001").
    * **Field-Type Details:** Noloco Text field. Generated by Flask app.
    * **Required:** Yes

3.  **ReminderTitle** (Text)
    * **Description:** The main text/title of the reminder.
    * **Required:** Yes

4.  **ReminderDateTime** (Date & Time)
    * **Description:** The date and time the reminder is set for.
    * **Field-Type Details:** Noloco Date & Time field.
    * **Required:** Yes

5.  **UserToRemind_Link** (Relationship)
    * **Description:** The user this reminder is for.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** Yes

6.  **Related_Task_Link** (Relationship)
    * **Description:** If this reminder is associated with a specific task.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Tasks` collection.
    * **Required:** No

7.  **Related_Field_Report_Link** (Relationship)
    * **Description:** If this reminder is associated with a specific field report.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Field_Reports` collection.
    * **Required:** No

8.  **Related_Site_Link** (Relationship)
    * **Description:** If this reminder is associated with a specific site.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Sites` collection.
    * **Required:** No

9.  **Status** (Single Option Select)
    * **Description:** Current status of the reminder.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Scheduled", "Sent", "Dismissed", "Completed", "Error".
    * **Default:** "Scheduled".
    * **Required:** Yes

10. **NotificationChannel** (Multiple Option Select)
    * **Description:** How the user should be notified (e.g., Telegram, Email).
    * **Field-Type Details:** Noloco Multiple Option Select field.
    * **Options:** "Telegram", "Email", "In-App (Noloco)".
    * **Required:** No

11. **TodoistReminderID** (Text)
    * **Description:** If this reminder is synced with Todoist, this stores the Todoist Reminder ID.
    * **Field-Type Details:** Noloco Text field.
    * **Required:** No (System-managed if using Todoist sync)

12. **IsRecurring** (Boolean)
    * **Description:** Is this a recurring reminder?
    * **Field-Type Details:** Noloco Boolean (Checkbox) field.
    * **Required:** No

13. **RecurrenceRule** (Text)
    * **Description:** If recurring, specifies the rule (e.g., "RRULE:FREQ=WEEKLY;BYDAY=MO" - iCalendar format, or a simpler custom format). Interpretation and actioning of this rule would be handled by the Flask application.
    * **Required:** No (Only if IsRecurring is TRUE)

14. **CreatedBy_User_Link** (Relationship)
    * **Description:** The user who set up this reminder.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** No

15. **CreatedTimestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when the reminder was created.
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

### **A.2.6. Notifications_Log Collection**

**Purpose:** Logs all notifications sent by the FLRTS system.
**SDD Reference:** Section 3.3.6
**Fields:**

1.  **NotificationLogID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **TimestampSent** (Date & Time)
    * **Description:** When the notification was actually sent.
    * **Field-Type Details:** Noloco Date & Time field. Set by the application.
    * **Required:** Yes

3.  **Recipient_User_Link** (Relationship)
    * **Description:** The user who received (or was intended to receive) the notification.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** Yes

4.  **Channel** (Single Option Select)
    * **Description:** Channel through which the notification was sent.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Telegram", "Email", "In-App (Noloco)", "SMS", "Other".
    * **Required:** Yes

5.  **NotificationType** (Single Option Select)
    * **Description:** The type or trigger of the notification.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Task Reminder", "New Task Assigned", "Report Submitted", "Report Actioned", "System Alert", "Mention", "Scheduled Digest", "Other".
    * **Required:** Yes

6.  **Subject_Or_Title** (Text)
    * **Description:** Subject line (for email) or a short title for the notification.
    * **Required:** No

7.  **MessageContent** (Long Text)
    * **Description:** The full content of the notification sent.
    * **Field-Type Details:** Noloco Long Text field.
    * **Required:** Yes

8.  **Status** (Single Option Select)
    * **Description:** Delivery status of the notification.
    * **Field-Type Details:** Noloco Single Option Select field.
    * **Options:** "Sent", "Delivered", "Failed", "Read", "Acknowledged". (Note: "Delivered", "Read", "Acknowledged" statuses might require integration with the delivery channel, e.g., Telegram Bot API read receipts if available).
    * **Required:** Yes

9.  **Related_Record_Type** (Text)
    * **Description:** The type of record this notification pertains to (e.g., "Task", "FieldReport", "Site"). This helps in linking back to the source if needed, though direct links are preferred.
    * **Required:** No

10. **Related_Record_ID_Display** (Text)
    * **Description:** The display ID of the related record (e.g., "TSK-001", "FR-S001-20231026-001"). This is for human-readable reference; for programmatic links, use relationship fields.
    * **Required:** No

11. **Related_Task_Link** (Relationship)
    * **Description:** Direct link if the notification is about a specific Task.
    * **Field-Type Details:** Noloco Relationship field to `Tasks`.
    * **Required:** No

12. **Related_Field_Report_Link** (Relationship)
    * **Description:** Direct link if the notification is about a specific Field Report.
    * **Field-Type Details:** Noloco Relationship field to `Field_Reports`.
    * **Required:** No

### **A.2.7. Field_Report_Edits Collection (Audit Trail)**

**Purpose:** Tracks edits made to Field Reports for audit and version history.
**SDD Reference:** Section 3.3.7
**Fields:**

1.  **EditID_PK_Noloco** (Noloco ID)
    * **Description:** Unique identifier for the edit record, automatically created by Noloco.
    * **Field-Type Details:** This is Noloco's internal record ID.
    * **Required:** Yes (System-managed)

2.  **Parent_Field_Report_Link** (Relationship)
    * **Description:** Links to the `Field_Reports` record that was edited.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Field_Reports` collection.
    * **Required:** Yes

3.  **Author_User_Link** (Relationship)
    * **Description:** Links to the FLRTS user who made this specific edit.
    * **Field-Type Details:** Noloco Relationship field, linking to one record from the `Users` collection.
    * **Required:** Yes

4.  **Timestamp** (Date & Time - Noloco Created Time)
    * **Description:** Timestamp of when this edit record was created (i.e., when the edit was saved).
    * **Field-Type Details:** Noloco "Created Time" system field.
    * **Required:** Yes (System-managed)

5.  **EditText_Full_Version** (Long Text)
    * **Description:** The full content of the `ReportContent_Full` field of the parent Field Report *after* this edit. Storing the full text as of that version.
    * **Field-Type Details:** Noloco Long Text field (supports rich text).
    * **Required:** Yes

6.  **EditSummary_User_Provided** (Text)
    * **Description:** An optional, brief summary of the changes made in this edit, supplied by the user (e.g., "Corrected typos in section 2", "Added equipment readings").
    * **Required:** No

7.  **VersionNumber_Calculated** (Number)
    * **Description:** A sequential version number for the edits of a particular field report (e.g., 1, 2, 3...). This would require application logic (Flask or Noloco Workflow) to calculate and assign based on previous edits for the same parent report.
    * **Field-Type Details:** Noloco Number field (integer).
    * **Required:** No (System-managed)

---
This completes the conversion of Appendix A to Noloco Table definitions. I've focused on mapping field types, updating terminology for Noloco, and ensuring relationship details are compatible with Noloco's way of linking collections. Formula fields from Airtable are noted, with the expectation that their logic might be implemented via Noloco's formula capabilities if simple, or via the Flask backend or Noloco Workflows if more complex. Primary Keys are now Noloco's internal IDs, with `_Display` fields suggested for human-readable IDs where necessary.