# **Appendix A: Airtable Field Definitions**

This appendix provides detailed field definitions for all tables within the Airtable bases used by the 10NetZero-FLRTS system.

## **A.1. 10NetZero_Main_Datastore Base**

This base serves as the Single Source of Truth (SSoT) for core business entities.

### **A.1.1. Sites Table (Master)**

**Purpose:** Master list of all operational sites.  
**SDD Reference:** Section 3.1.1  
**Fields:**

1. **SiteID_PK** (Primary Key – Airtable Autonumber or Formula generating a unique ID like "S001")
  * *Description:* Unique system-generated identifier for the site.
  * *Field-Type Details:* Autonumber preferred for simplicity.
  * *Required:* Yes
2. **SiteName** (Single Line Text, Required)
  * *Description:* Common, human-readable name for the site. Must be unique.
  * *Required:* Yes
3. **SiteAddress_Street** (Single Line Text)
  * *Description:* Street number and name for the site's physical address.
  * *Required:* No
4. **SiteAddress_City** (Single Line Text)
  * *Description:* City for the site's physical address.
  * *Required:* No
5. **SiteAddress_State** (Single Line Text)
  * *Description:* State or province for the site's physical address.
  * *Required:* No
6. **SiteAddress_Zip** (Single Line Text)
  * *Description:* Postal code for the site's physical address.
  * *Required:* No
7. **SiteLatitude** (Number, Decimal)
  * *Description:* Latitude of the site in decimal degrees. For mapping and location services.
  * *Field-Type Details:* Precision should be at least 6 decimal places.
  * *Required:* No
8. **SiteLongitude** (Number, Decimal)
  * *Description:* Longitude of the site in decimal degrees. For mapping and location services.
  * *Field-Type Details:* Precision should be at least 6 decimal places.
  * *Required:* No
9. **SiteStatus** (Single Select)
  * *Description:* Current high-level operational status of the site.
  * *Options:* "Commissioning", "Running", "In Maintenance", "Contracted", "Planned", "Decommissioned".
  * *Required:* No
10. **Operator_Link** (Link to Operators table)
  * *Description:* Links to the primary operator entity responsible for this site. (Allows linking to one record from the Operators table).
  * *Required:* No
11. **Site_Partner_Assignments_Link** (Lookup or Rollup via Site_Partner_Assignments table – TBD, or direct Link field)
  * *Description:* Displays partners associated with this site via the Site_Partner_Assignments junction table.
  * *Additional Details:* SDD states "Link to Site_Partner_Assignments table". This creates a link *from* Sites *to* the junction. Typically, you link *from* the junction *to* Sites. We'll refine this when defining junction tables. For now, the intent is clear: to see related partners.
  * *Required:* No
12. **Site_Vendor_Assignments_Link** (Lookup or Rollup via Site_Vendor_Assignments table – TBD, or direct Link field)
  * *Description:* Displays vendors assigned to this site via the Site_Vendor_Assignments junction table.
  * *Additional Details:* Same as above regarding link direction.
  * *Required:* No
13. **Licenses_Agreements_Link** (Link to Licenses & Agreements table)
  * *Description:* Links to contracts, permits, or agreements directly associated with this site. (Allows linking to multiple records).
  * *Required:* No
14. **Equipment_At_Site_Link** (Link to Equipment table, multiple)
  * *Description:* Links to records of general equipment (non-ASIC) physically located or primarily assigned to this site. (This field on the Sites table would be a "Linked Record" field type allowing multiple Equipment records. The corresponding link would be on the Equipment table, likely as SiteLocation_Link).
  * *Required:* No
15. **ASICs_At_Site_Link** (Link to ASICs table, multiple)
  * *Description:* Links to records of ASIC mining hardware physically located or primarily assigned to this site. (Similar to Equipment_At_Site_Link).
  * *Required:* No
16. **SOP_Document_Link** (URL)
  * *Description:* Direct link to this site's official Standard Operating Procedure (SOP) master document, stored in Google Drive. This document is automatically generated and linked by the system upon site creation.
  * *Required:* No
17. **IsActive** (Checkbox, Default: TRUE)
  * *Description:* Indicates if the site record is currently considered active and should appear in regular operational listings and interfaces. Uncheck for temporarily inactive or archived sites.
  * *Required:* No
18. **Initial_Site_Setup_Completed_by_App** (Checkbox, Default: FALSE)
    * **Description:** System field. Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists (e.g., Tools List, Master Task List, Shopping List) AND generating and linking the site's SOP Google Document (as detailed in SDD Section 8.1). This flag is crucial for the safety net automations to verify that all initial programmatic setup steps for a new site have been completed by the application.
    * **Field Type Details:** Default value for new records is FALSE.
    * **Required:** No (System-managed)

### **A.1.2. Personnel Table (Master)**

* **Purpose:** Master list of all employees and individuals who might interact with or be referenced in the system. This includes users of the FLRTS application.  
* **SDD Reference:** Section 3.1.2  
* **Fields:**  
  1. PersonnelID\_PK (Primary Key \- Airtable Autonumber or Formula generating "P001" style ID)  
     * *Description:* Unique system-generated identifier for the personnel record.  
     * *Field-Type Details:* Autonumber preferred for simplicity.  
     * *Required:* Yes
  2. FullName (Single Line Text, Required)  
     * *Description:* Full legal name of the individual.  
     * *Field-Type Details:* Required field.  
     * *Required:* Yes
  3. WorkEmail (Email, Unique)  
     * *Description:* Primary work email address. Must be unique across all personnel records. Used for system notifications if not via Telegram and for initial user account linking if applicable.  
     * *Field-Type Details:* Airtable Email type. Constraint: Unique.  
     * *Required:* Yes
  4. PhoneNumber (Phone Number)  
     * *Description:* Primary contact phone number for the individual (e.g., work mobile).  
     * *Field-Type Details:* Airtable Phone Number type.  
     * *Required:* No
  5. TelegramUserID (Number, Unique)  
     * *Description:* The unique, permanent numeric User ID assigned by Telegram to the user's account. This is crucial for bot interaction, FLRTS user account identification, and system security.  
     * *Field-Type Details:* Airtable Number type (Integer). Constraint: Unique. This field is essential if the personnel will use the Telegram bot.  
     * *Required:* No
  6. TelegramHandle (Single Line Text, Optional)  
     * *Description:* The user's Telegram @username (e.g., @colinaulds). Used for display, user-friendly mentions, and as a convenience. Not used as a primary identifier by the system as it can be changed by the user.  
     * *Field-Type Details:* Optional field.  
     * *Required:* No
  7. EmployeePosition (Single Line Text)  
     * *Description:* The individual's official job title or formal position within the organization (e.g., "Field Technician," "Operations Manager," "Director of Operations").  
     * *Required:* No
  8. StartDate (Date)  
     * *Description:* The individual's official start date with the company or engagement.  
     * *Field-Type Details:* Airtable Date type (no time component needed).  
     * *Required:* No
  9. EmploymentContract\_Link (Link to Licenses & Agreements table, Optional)  
     * *Description:* Links to the individual's employment contract or other relevant legal agreements stored in the Licenses & Agreements table.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Licenses & Agreements table.  
     * *Required:* No
  10. Assigned\_Equipment\_Log\_Link (Link to Employee\_Equipment\_Log table)  
      * *Description:* Shows equipment currently or previously assigned to this person via the Employee\_Equipment\_Log junction table.  
      * *Field-Type Details:* This will be an Airtable Linked Record field that allows linking to multiple records from the Employee\_Equipment\_Log table. The primary links are made *from* the Employee\_Equipment\_Log table *to* Personnel and Equipment.  
     * *Required:* No
  11. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if the personnel record is currently active (e.g., current employee). Uncheck for former employees or inactive records. Controls visibility in some system lookups.  
      * *Field-Type Details:* Default value for new records is TRUE.  
     * *Required:* No
  12. Default\_Employee\_Lists\_Created (Checkbox, Default: FALSE)  
      * *Description:* System field. Set to TRUE by the Flask application after successfully creating the employee's default "Onboarding" FLRTS list. Used by safety net automations to ensure this list is programmatically generated.  
      * *Field-Type Details:* Default value for new records is FALSE.  
     * *Required:* No

### **A.1.3. Partners Table (Master)**

* **Purpose:** Master list of partner organizations or individuals, primarily those with an investment, lending, or funding relationship concerning 10NetZero projects/sites.  
* **SDD Reference:** Section 3.1.3  
* **Fields:**  
  1. PartnerID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the partner.  
     * *Field-Type Details:* Autonumber preferred.  
     * *Required:* Yes
  2. PartnerName (Single Line Text, Required)  
     * *Description:* Official name of the partner organization or full name of the individual partner. Must be unique.  
     * *Field-Type Details:* Required field.  
     * *Required:* Yes
  3. PartnerType (Single Select)  
     * *Description:* Classifies the nature of the partnership.  
     * *Options:* "Co-Investor", "Site JV Partner", "Lender", "Fundraiser/Placement Agent", "Other Financial Partner".  
     * *Required:* No
  4. Logo (Multiple Attachments, Optional)  
     * *Description:* Partner's company logo or relevant branding images.  
     * *Field-Type Details:* Airtable Attachment type, allows multiple files.  
     * *Required:* No
  5. ContactPerson\_FirstName (Single Line Text, Optional)  
     * *Description:* First name of the primary contact person at the partner organization.  
     * *Required:* No
  6. ContactPerson\_LastName (Single Line Text, Optional)  
     * *Description:* Last name of the primary contact person at the partner organization.  
     * *Required:* No
  7. Email (Email, Optional)  
     * *Description:* Primary contact email address for the partner or the main contact person.  
     * *Field-Type Details:* Airtable Email type.  
     * *Required:* No
  8. Phone (Phone Number, Optional)  
     * *Description:* Primary contact phone number for the partner or the main contact person.  
     * *Field-Type Details:* Airtable Phone Number type.  
     * *Required:* No
  9. Address\_Street1 (Single Line Text, Optional)  
     * *Description:* Street address line 1 for the partner.  
     * *Required:* No
  10. Address\_Street2 (Single Line Text, Optional)  
      * *Description:* Street address line 2 for the partner (e.g., suite, floor, P.O. Box).  
     * *Required:* No
  11. Address\_City (Single Line Text, Optional)  
      * *Description:* City for the partner's address.  
     * *Required:* No
  12. Address\_State (Single Line Text, Optional)  
      * *Description:* State or province for the partner's address.  
     * *Required:* No
  13. Address\_Zip (Single Line Text, Optional)  
      * *Description:* Postal code for the partner's address.  
     * *Required:* No
  14. FullAddress (Formula)  
      * *Description:* A calculated field that combines the individual address components into a single, formatted string for easy viewing or copying.  
      * *Field-Type Details:* Formula field. Example formula: IF({Address\_Street1}, {Address\_Street1} & "\\n", "") & IF({Address\_Street2}, {Address\_Street2} & "\\n", "") & IF({Address\_City}, {Address\_City} & ", ", "") & IF({Address\_State}, {Address\_State} & " ", "") & IF({Address\_Zip}, {Address\_Zip}, "") (Adjust field names in formula as per actual Airtable field names).  
     * *Required:* No
  15. Website (URL, Optional)  
      * *Description:* Official website of the partner organization.  
      * *Field-Type Details:* Airtable URL type.  
     * *Required:* No
  16. RelevantAgreements\_Link (Link to Licenses & Agreements table, multiple, Optional)  
      * *Description:* Links to key *general* contracts, master partnership agreements, or other relevant legal documents with this partner stored in the Licenses & Agreements table. Site-specific agreements are linked via the Site\_Partner\_Assignments table.  
      * *Field-Type Details:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
     * *Required:* No
  17. Site\_Assignments\_Link (Link to Site\_Partner\_Assignments table)  
      * *Description:* Shows site-specific assignments, roles, and agreement links for this partner via the Site\_Partner\_Assignments junction table.  
      * *Field-Type Details:* This will be an Airtable Linked Record field that allows linking to multiple records from Site\_Partner\_Assignments. The primary links are made *from* the Site\_Partner\_Assignments table *to* Partners and Sites.  
     * *Required:* No
  18. Notes (Long Text, Optional)  
      * *Description:* General notes about the partner, relationship history, key terms not captured elsewhere, or high-level financial arrangement summaries.  
      * *Field-Type Details:* Use Airtable's Long Text with rich text enabled.  
     * *Required:* No
  19. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if this is a current, active partnership. Uncheck for dissolved or inactive partnerships.  
      * *Field-Type Details:* Default value for new records is TRUE.  
     * *Required:* No

### **A.1.4. Site\_Partner\_Assignments Table (Junction Table)**

* **Purpose:** Links Sites and Partners to define specific partnership details for each site. Each record represents a unique relationship between one partner and one site.  
* **SDD Reference:** Section 3.1.4  
* **Fields:**  
  1. AssignmentID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for this specific site-partner assignment.  
     * *Field-Type Details:* Autonumber preferred.  
     * *Required:* Yes
  2. LinkedSite (Link to Sites table, Required)  
     * *Description:* Specifies the site involved in this assignment.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Sites table. Must link to one site record. Required field.  
     * *Required:* Yes
  3. LinkedPartner (Link to Partners table, Required)  
     * *Description:* Specifies the partner involved in this assignment.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Partners table. Must link to one partner record. Required field.  
     * *Required:* Yes
  4. PartnershipStartDate (Date, Optional)  
     * *Description:* The date this specific partnership assignment at this site commenced.  
     * *Field-Type Details:* Airtable Date type.  
     * *Required:* No
  5. OwnershipPercentage (Percent, Optional)  
     * *Description:* The partner's ownership percentage specifically related to this site assignment, if applicable.  
     * *Field-Type Details:* Airtable Percent type, precision set to 0 decimal places (for whole numbers).  
     * *Required:* No
  6. PartnerResponsibilities (Long Text, Optional)  
     * *Description:* Detailed description of the partner's responsibilities, contributions, or role specific to this site assignment.  
     * *Field-Type Details:* Long Text with rich text enabled for formatting.  
     * *Required:* No
  7. 10NZ\_Responsibilities (Long Text, Optional)  
     * *Description:* Detailed description of 10NetZero's responsibilities or contributions specific to this site assignment in relation to this partner.  
     * *Field-Type Details:* Long Text with rich text enabled for formatting.  
     * *Required:* No
  8. PartnershipContract\_Link (Link to Licenses & Agreements table, multiple, Optional)  
     * *Description:* Links to specific contracts or agreements in the Licenses & Agreements table that govern this particular site-partner assignment.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
     * *Required:* No
  9. Notes (Long Text, Optional)  
     * *Description:* Any additional notes specific to this site-partner assignment.  
     * *Field-Type Details:* Long Text with rich text enabled for formatting.  
     * *Required:* No

### **A.1.5. Vendors Table (Master)**

* **Purpose:** Master list of all vendor organizations or individuals that provide goods or services.  
* **SDD Reference:** Section 3.1.5  
* **Fields:**  
  1. VendorID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the vendor.  
     * *Field-Type Details:* Autonumber preferred.  
     * *Required:* Yes
  2. VendorName (Single Line Text, Required, Unique)  
     * *Description:* Official name of the vendor organization or full name of the individual vendor. Must be unique.  
     * *Field-Type Details:* Required field. Constraint: Unique.  
     * *Required:* Yes
  3. ServiceType (Multiple Select)  
     * *Description:* Classifies the primary types of goods or services offered by the vendor.  
     * *Field-Type Details:* Airtable Multiple Select type.  
     * *Options:* "Electrical Services", "Plumbing Services", "HVAC Services", "Logistics & Transport", "Security Services", "Equipment Rental", "Waste Management", "IT Support", "Consulting \- Engineering", "Consulting \- Financial", "Consulting \- Legal", "Consulting \- Accounting/Audit", "Raw Material Supplier", "ASIC Supplier", "Software Provider", "General Contractor", "Specialized Repair Services", "Office Supplies", "Other". (Allows users to add new options).  
     * *Required:* No
  4. ContactPerson\_FirstName (Single Line Text, Optional)  
     * *Description:* First name of the primary contact person at the vendor organization.  
     * *Required:* No
  5. ContactPerson\_LastName (Single Line Text, Optional)  
     * *Description:* Last name of the primary contact person at the vendor organization.  
     * *Required:* No
  6. Email (Email, Optional)  
     * *Description:* Primary contact email address for the vendor or the main contact person.  
     * *Field-Type Details:* Airtable Email type.  
     * *Required:* No
  7. Phone (Phone Number, Optional)  
     * *Description:* Primary contact phone number for the vendor or the main contact person.  
     * *Field-Type Details:* Airtable Phone Number type.  
     * *Required:* No
  8. Address\_Street1 (Single Line Text, Optional)  
     * *Description:* Street address line 1 for the vendor.  
     * *Required:* No
  9. Address\_Street2 (Single Line Text, Optional)  
     * *Description:* Street address line 2 for the vendor (e.g., suite, floor, P.O. Box).  
     * *Required:* No
  10. Address\_City (Single Line Text, Optional)  
      * *Description:* City for the vendor's address.  
     * *Required:* No
  11. Address\_State (Single Line Text, Optional)  
      * *Description:* State or province for the vendor's address.  
     * *Required:* No
  12. Address\_Zip (Single Line Text, Optional)  
      * *Description:* Postal code for the vendor's address.  
     * *Required:* No
  13. FullAddress (Formula)  
      * *Description:* A calculated field that combines the individual address components into a single, formatted string for easy viewing or copying.  
      * *Field-Type Details:* Formula field. Example formula: IF({Address\_Street1}, {Address\_Street1} & "\\n", "") & IF({Address\_Street2}, {Address\_Street2} & "\\n", "") & IF({Address\_City}, {Address\_City} & ", ", "") & IF({Address\_State}, {Address\_State} & " ", "") & IF({Address\_Zip}, {Address\_Zip}, "") (Adjust field names in formula as per actual Airtable field names).  
     * *Required:* No
  14. Website (URL, Optional)  
      * *Description:* Official website of the vendor organization.  
      * *Field-Type Details:* Airtable URL type.  
     * *Required:* No
  15. RelevantAgreements\_Link (Link to Licenses & Agreements table, multiple, Optional)  
      * *Description:* Links to key *general* contracts (e.g., Master Service Agreements), rate sheets, or other relevant legal documents with this vendor stored in the Licenses & Agreements table. Site-specific service agreements/POs are linked via the Site\_Vendor\_Assignments table.  
      * *Field-Type Details:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
     * *Required:* No
  16. Vendor\_General\_Attachments (Multiple Attachments, Optional)  
      * *Description:* For general vendor-related documents that are not formal contracts or agreements (e.g., brochures, capability statements, insurance certificates if not tracked formally, miscellaneous correspondence).  
      * *Field-Type Details:* Airtable Attachment type.  
     * *Required:* No
  17. Site\_Assignments\_Link (Link to Site\_Vendor\_Assignments table)  
      * *Description:* Shows site-specific service assignments, scope, and agreement links for this vendor via the Site\_Vendor\_Assignments junction table.  
      * *Field-Type Details:* This will be an Airtable Linked Record field that allows linking to multiple records from Site\_Vendor\_Assignments. The primary links are made *from* the Site\_Vendor\_Assignments table *to* Vendors and Sites.  
     * *Required:* No
  18. Notes (Long Text, Optional)  
      * *Description:* General notes about the vendor, service history, performance, key terms not captured elsewhere, etc.  
      * *Field-Type Details:* Use Airtable's Long Text with rich text enabled.  
     * *Required:* No
  19. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if this is a current, active vendor relationship. Uncheck for vendors no longer used or approved.  
      * *Field-Type Details:* Default value for new records is TRUE.  
     * *Required:* No

### **A.1.6. Site\_Vendor\_Assignments Table (Junction Table)**

* **Purpose:** Links Vendors and Sites to define specific service or supply details for each site. Each record represents a unique service engagement between one vendor and one site.  
* **SDD Reference:** Section 3.1.6  
* **Fields:**  
  1. VendorAssignmentID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for this specific site-vendor assignment.  
     * *Field-Type Details:* Autonumber preferred.  
     * *Required:* Yes
  2. LinkedSite (Link to Sites table, Required)  
     * *Description:* Specifies the site for which the service is being provided.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Sites table. Must link to one site record. Required field.  
     * *Required:* Yes
  3. LinkedVendor (Link to Vendors table, Required)  
     * *Description:* Specifies the vendor providing the service for this assignment.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Vendors table. Must link to one vendor record. Required field.  
     * *Required:* Yes
  4. ServiceDescription\_SiteSpecific (Long Text, Optional)  
     * *Description:* A detailed description of the specific services or goods being provided by the vendor for this site assignment (e.g., scope of work, specific tasks, equipment involved).  
     * *Field-Type Details:* Long Text with rich text enabled for formatting.  
     * *Required:* No
  5. VendorContract\_Link (Link to Licenses & Agreements table, multiple, Optional)  
     * *Description:* Links to specific contracts, Statements of Work (SOWs), Purchase Orders (POs), or other agreements in the Licenses & Agreements table that govern this particular site-vendor assignment.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
     * *Required:* No
  6. Notes (Long Text, Optional)  
     * *Description:* Any additional notes specific to this site-vendor assignment (e.g., project codes, specific site contact for this job, access instructions).  
     * *Field-Type Details:* Long Text with rich text enabled for formatting.  
     * *Required:* No

### **A.1.7. Equipment Table (Master \- General Assets)**

* **Purpose:** Master list of general physical assets (non-ASIC), such as tools, machinery, vehicles, and IT hardware.  
* **SDD Reference:** Section 3.1.7  
* **Fields:**  
  1. AssetTagID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the equipment item. (Original SDD concept: "10NZ-GEN-001" \- can be a formula field if a specific prefix is desired on top of autonumber).  
     * *Field-Type Details:* Autonumber preferred for simplicity.  
     * *Required:* Yes
  2. EquipmentName (Single Line Text, Required)  
     * *Description:* Common, human-readable name or description for the equipment (e.g., "Honda Generator GX390 with Wheel Kit"). This can be manually entered or a formula combining Make, Model, and key features.  
     * *Field-Type Details:* Required field.  
     * *Required:* Yes
  3. Make (Single Line Text, Optional)  
     * *Description:* Manufacturer or brand of the equipment (e.g., "Honda", "DeWalt", "Caterpillar").  
     * *Required:* No
  4. Model (Single Line Text, Optional)  
     * *Description:* Specific model name or number of the equipment (e.g., "GX390", "DCD771C2", "308E2").  
     * *Required:* No
  5. EquipmentType (Single Select)  
     * *Description:* Classification of the equipment.  
     * *Field-Type Details:* Airtable Single Select type.  
     * *Options:* "Generator", "Pump", "Vehicle \- Light Duty", "Vehicle \- Heavy Duty", "Heavy Equipment", "Power Tool \- Corded", "Power Tool \- Cordless", "IT Hardware \- Laptop", "IT Hardware \- Desktop", "IT Hardware \- Monitor", "IT Hardware \- Network Gear", "Safety Gear", "Tool \- Hand", "Tool \- Diagnostic", "Office Equipment", "Other". (Allows users to add new options).  
     * *Required:* No
  6. SerialNumber (Single Line Text, Optional)  
     * *Description:* Manufacturer's serial number for the specific unit. Should be unique if available and tracked.  
     * *Field-Type Details:* Attempt to ensure uniqueness if practical, but not a strict system constraint if SNs are sometimes unavailable.  
     * *Required:* No
  7. SiteLocation\_Link (Link to Sites table, Optional)  
     * *Description:* Current physical location of the equipment. Links to a Sites record, which can be an operational site or a designated "Warehouse" site.  
     * *Field-Type Details:* Airtable Linked Record type, pointing to the Sites table. Allows linking to only one site.  
     * *Required:* No
  8. Specifications (Long Text, Optional)  
     * *Description:* Detailed specifications, capabilities, or configuration notes for the equipment.  
     * *Field-Type Details:* Long Text with rich text enabled.  
     * *Required:* No
  9. PurchaseDate (Date, Optional)  
     * *Description:* Date the equipment was purchased.  
     * *Field-Type Details:* Airtable Date type.  
     * *Required:* No
  10. PurchasePrice (Currency, Optional)  
      * *Description:* Original purchase price of the equipment.  
      * *Field-Type Details:* Airtable Currency type.  
      * *Required:* No
  11. PurchaseReceipt (Multiple Attachments, Optional)  
      * *Description:* Scanned copy of the purchase receipt or invoice.  
      * *Field-Type Details:* Airtable Attachment type.  
      * *Required:* No
  12. CurrentStatus (Single Select)  
      * *Description:* Current operational status of the equipment.  
      * *Field-Type Details:* Airtable Single Select type.  
      * *Options:* "Operational", "Needs Maintenance", "Out of Service", "In Storage", "In Transit", "Awaiting Repair", "Irreparable/Disposed".  
      * *Required:* No
  13. WarrantyExpiryDate (Date, Optional)  
      * *Description:* Date the manufacturer's or seller's warranty expires.  
      * *Field-Type Details:* Airtable Date type.  
      * *Required:* No
  14. LastMaintenanceDate (Date, Optional)  
      * *Description:* Date the last maintenance was performed on the equipment.  
      * *Field-Type Details:* Airtable Date type.  
      * *Required:* No
  15. NextScheduledMaintenanceDate (Date, Optional)  
      * *Description:* Date the next routine maintenance is scheduled or due.  
      * *Field-Type Details:* Airtable Date type.  
      * *Required:* No
  16. Eq\_Manual (Multiple Attachments, Optional)  
      * *Description:* Digital copy of the equipment's user manual, service manual, or other relevant documentation.  
      * *Field-Type Details:* Airtable Attachment type.  
      * *Required:* No
  17. EquipmentPictures (Multiple Attachments, Optional)  
      * *Description:* Photographs of the equipment.  
      * *Field-Type Details:* Airtable Attachment type.  
      * *Required:* No
  18. Employee\_Log\_Link (Link to Employee\_Equipment\_Log table)  
      * *Description:* Shows the assignment history of this equipment to personnel via the Employee\_Equipment\_Log junction table.  
      * *Field-Type Details:* This will be an Airtable Linked Record field allowing linking to multiple records from Employee\_Equipment\_Log.  
      * *Required:* No
  19. Notes (Long Text, Optional)  
      * *Description:* General notes about the equipment (e.g., known issues, specific configurations, usage history not captured elsewhere).  
      * *Field-Type Details:* Long Text with rich text enabled.  
      * *Required:* No

### **A.1.8. ASICs Table (Master \- Mining Hardware)**

* **Purpose:** Dedicated master list for Bitcoin mining hardware (Application-Specific Integrated Circuits).  
* **SDD Reference:** Section 3.1.8  
* **Fields:**  
  1. ASIC\_ID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the ASIC record.  
     * *Required:* Yes
  2. SerialNumber (Single Line Text, Required, Unique)  
     * *Description:* Manufacturer's serial number for the specific ASIC unit. This should be unique across all ASICs.  
     * *Field-Type Details:* Required field. Constraint: Unique.  
     * *Required:* Yes
  3. ASIC\_Make (Single Select)  
     * *Description:* Manufacturer of the ASIC.  
     * *Options:* "Bitmain", "MicroBT", "Canaan", "Other". (Allows adding more later).  
     * *Required:* No
  4. ASIC\_Model (Single Select)  
     * *Description:* Specific model of the ASIC.  
     * *Field-Type Details:* This list is based on recent models (circa 2024-2025) and may need updating. Allows adding new options.  
     * *Options:* "Antminer S21 Hyd (335Th)", "Antminer S21 Pro (234Th)", "Antminer S21 (200Th)", "Antminer S21 XP Hydro (473Th)", "Antminer S19 XP Hyd (255Th)", "Antminer S19k Pro", "Whatsminer M66S Immersion (298Th)", "Whatsminer M63S Hydro (390Th)", "Whatsminer M60S (186Th)", "Whatsminer M56S (212Th)", "Whatsminer M50S (126Th)", "Whatsminer M30S++", "Avalon A1566", "Other".  
     * *Required:* No
  5. SiteLocation\_Link (Link to Sites table, Optional)  
     * *Description:* Current physical location of the ASIC. Links to a Sites record (operational site or "Warehouse").  
     * *Field-Type Details:* Linked Record type, pointing to Sites, allows linking to one site.  
     * *Required:* No
  6. RackLocation\_In\_Site (Single Line Text, Optional)  
     * *Description:* Specific location within the site (e.g., "Container A, Rack 3, Shelf B, Unit 1", "Warehouse Shelf C-12").  
     * *Required:* No
  7. PurchaseDate (Date, Optional)  
     * *Description:* Date the ASIC was purchased.  
     * *Required:* No
  8. PurchasePrice (Currency, Optional)  
     * *Description:* Original purchase price of the ASIC.  
     * *Required:* No
  9. CurrentStatus (Single Select)  
     * *Description:* Current operational status of the ASIC.  
     * *Options:* "Mining", "Idle", "Needs Maintenance", "Error", "Offline", "In Storage", "Awaiting Repair", "Decommissioned".  
     * *Required:* No
  10. NominalHashRate\_THs (Number, Decimal, Optional)  
      * *Description:* Manufacturer's specified or expected hash rate in Terahashes per second (TH/s).  
      * *Field-Type Details:* Number type, 2 decimal places recommended.  
      * *Required:* No
  11. NominalPowerConsumption\_W (Number, Integer, Optional)  
      * *Description:* Manufacturer's specified or expected power consumption in Watts (W).  
      * *Field-Type Details:* Number type, integer preferred.  
      * *Required:* No
  12. HashRate\_Actual\_THs (Number, Decimal, Optional)  
      * *Description:* Last measured or reported actual hash rate in TH/s. (May be updated by monitoring systems).  
      * *Field-Type Details:* Number type, 2 decimal places recommended.  
      * *Required:* No
  13. PowerConsumption\_Actual\_W (Number, Integer, Optional)  
      * *Description:* Last measured or reported actual power consumption in Watts. (May be updated by monitoring systems).  
      * *Field-Type Details:* Number type, integer preferred.  
      * *Required:* No
  14. PoolAccount\_Link (Link to Mining\_Pool\_Accounts table, Optional)  
      * *Description:* Links to the mining pool account this ASIC is configured to use.  
      * *Field-Type Details:* Linked Record type, pointing to Mining\_Pool\_Accounts.  
      * *Required:* No
  15. FirmwareVersion (Single Line Text, Optional)  
      * *Description:* Current firmware version installed on the ASIC.  
      * *Required:* No
  16. IP\_Address (Single Line Text, Optional)  
      * *Description:* Last known IP address assigned to the ASIC on the local network.  
      * *Required:* No
  17. MAC\_Address (Single Line Text, Optional)  
      * *Description:* Hardware MAC address of the ASIC's network interface.  
      * *Required:* No
  18. LastMaintenanceDate (Date, Optional)  
      * *Description:* Date the last maintenance was performed on this ASIC.  
      * *Required:* No
  19. WarrantyExpiryDate (Date, Optional)  
      * *Description:* Date the manufacturer's or seller's warranty expires.  
      * *Required:* No
  20. ASIC\_Manual (Multiple Attachments, Optional)  
      * *Description:* Digital copy of the ASIC's user manual, technical guides, or related documentation.  
      * *Required:* No
  21. Notes (Long Text, Optional)  
      * *Description:* General notes about the ASIC (e.g., specific configurations, repair history, known issues).  
      * *Field-Type Details:* Long Text with rich text enabled.  
      * *Required:* No

### **A.1.9. Employee\_Equipment\_Log Table (Junction Table)**

* **Purpose:** This table acts as a log to track general equipment and tools (from the Equipment table) that are issued to, and returned by, employees. It maintains a history of assignments, including dates, the condition of the equipment at issue and return, and can optionally track expected return dates and personnel involved in issuing/receiving.  
* **SDD Reference:** Section 3.1.9  
* **Fields:**  
  1. LogID\_PK (Primary Key \- Airtable Autonumber)  
     * **Description:** A unique, system-generated identifier for each equipment log entry. This serves as the Primary Key for the table, ensuring each log transaction can be uniquely referenced.  
     * **Required:** Yes (Implicit for Primary Key)  
     * **Notes:** Automatically increments for each new record.  
  2. LinkedEmployee (Airtable Link to another record)  
     * **Description:** Specifies the employee to whom the equipment item is, or was, issued. This ensures clear accountability for the loaned item.  
     * **Required:** Yes  
     * **Notes:** Links to the Personnel table (Section A.1.2). This field should be configured in Airtable to allow linking to only *one* Personnel record per log entry.  
  3. LinkedEquipment (Airtable Link to another record)  
     * **Description:** Specifies the individual piece of general equipment that is being logged as issued or returned.  
     * **Required:** Yes  
     * **Notes:** Links to the Equipment table (Section A.1.7 General Assets). This field does *not* link to the ASICs table. It should be configured in Airtable to allow linking to only *one* Equipment record per log entry.  
  4. DateIssued (Airtable Date)  
     * **Description:** The actual date and time when the equipment was physically given to and accepted by the employee. This is critical for tracking the start of the loan period.  
     * **Required:** Yes  
     * **Notes:** The Airtable field option "Include a time field" should be enabled. This date/time is intended to be manually entered or confirmed by the user creating the log to reflect the true event time, which may differ from the record creation time.  
  5. DateReturned (Airtable Date)  
     * **Description:** The actual date and time when the equipment was physically returned by the employee. This field will be blank if the equipment is currently assigned out under this specific log entry.  
     * **Required:** No (This field is only populated when the item is returned).  
     * **Notes:** The Airtable field option "Include a time field" should be enabled.  
  6. ConditionIssued (Airtable Single select)  
     * **Description:** Describes the physical and functional condition of the equipment at the time it was issued to the employee. This is important for establishing a baseline.  
     * **Required:** Yes  
     * **Options:**  
       * New: The equipment is brand new, unused, and in its original state from the manufacturer/vendor.  
       * Good: The equipment is used but in excellent working order, with all parts functional and minimal to no cosmetic defects (e.g., minor scuffs that don't affect performance).  
       * Fair: The equipment is used and shows clear signs of wear and tear (e.g., noticeable scratches, dents, or fading) but remains fully functional for its intended purpose.  
       * Minor Wear: The equipment is used and has evident cosmetic wear (more than "Good," potentially similar to "Fair" but specifically highlighting wear over distinct damage), but is fully functional.  
       * Damaged: The equipment has specific, identifiable damage (e.g., a cracked casing, a bent component, a known fault) but is still being issued. The nature of the damage should be documented in the Notes field of this log entry.  
     * **Required:** Yes
  7. ConditionReturned (Airtable Single select)  
     * **Description:** Describes the physical and functional condition of the equipment at the time it was returned by the employee.  
     * **Required:** No (This field is only populated when the item is returned or if its status changes to Lost/Stolen).  
     * **Options:**  
       * Same as Issued: The equipment is returned in the identical condition (both functional and cosmetic) as it was when issued.  
       * Good: The equipment is returned in excellent working order, with all parts functional and minimal to no new cosmetic defects beyond what might have been noted at issuance.  
       * Fair: The equipment is returned fully functional but with clear signs of wear and tear, potentially new or worsened since issuance.  
       * Minor Wear: The equipment is returned with new minor cosmetic wear accrued during use, but remains fully functional.  
       * Damaged: The equipment is returned with new specific damage, or pre-existing damage has worsened. Details of the damage should be documented in the Notes field.  
       * Needs Repair: The equipment is returned and requires repair before it can be re-issued, regardless of its cosmetic condition. This could be due to malfunction, significant damage, or safety concerns.  
       * Lost/Stolen: The equipment was not returned because it has been reported as lost or stolen. This will trigger appropriate follow-up procedures for asset management.  
     * **Required:** No
  8. IsCurrentlyAssigned (Airtable Formula)  
     * **Description:** A system-calculated field that provides an at-a-glance indication (via a checkbox) of whether this specific log entry represents an equipment item that is still actively assigned out (i.e., the DateReturned field for this entry is blank).  
     * **Required:** N/A (Formula-generated)  
     * **Notes:** Formula: IF({DateReturned} \= BLANK(), TRUE(), FALSE()). A checked box means the item for this specific transaction is still out; an unchecked box means it has been returned for this transaction.  
  9. Notes (Airtable Long text)  
     * **Description:** A general-purpose field for capturing any additional relevant details, observations, or context about the equipment issuance or return. This could include specifics of damage not covered by the single-select condition, accessories included/missing, purpose of the loan if unusual, or any other pertinent information.  
     * **Required:** No  
     * **Notes:** The "Enable rich text formatting" option should be turned on for this field in Airtable to allow for better readability and emphasis if needed.  
  10. DateRecordCreated (Airtable Created time)  
      * **Description:** An automatic timestamp, generated by Airtable, indicating the exact date and time when this specific log record was first created in the database.  
      * **Required:** N/A (System-generated)  
      * **Notes:** This field is crucial for audit trails and understanding the history of record creation.  
  11. DateRecordLastModified (Airtable Last modified time)  
      * **Description:** An automatic timestamp, generated by Airtable, indicating the exact date and time when this specific log record was last modified.  
      * **Required:** N/A (System-generated)  
      * **Notes:** This field is important for audit trails and tracking any changes made to a log entry after its initial creation.  
  12. ExpectedReturnDate (Airtable Date)  
      * **Description:** Specifies the date and, optionally, the time when the issued equipment is expected to be returned by the employee. This can help in managing equipment inventory and tracking overdue items.  
      * **Required:** No  
      * **Notes:** The Airtable field option "Include a time field" should be enabled. For MVP, this field can be included in the schema but may be hidden in default user data entry views if it's not consistently used, to simplify forms.  
  13. IssuingManager\_Link (Airtable Link to another record)  
      * **Description:** Optionally identifies the manager or other authorized personnel who approved the issuance of the equipment or physically handed it over. This adds a layer of accountability for the issuance process.  
      * **Required:** No  
      * **Notes:** Links to the Personnel table (Section A.1.2). Allows linking to only one Personnel record. For MVP, this field can be included in the schema but may be hidden in default user data entry views to simplify forms, to be used when specific accountability for the act of issuance is required.  
  14. ReturnProcessedBy\_Link (Airtable Link to another record)  
      * **Description:** Optionally identifies the personnel member who received the equipment back from the employee and processed its return in the system (e.g., a store manager or team lead).  
      * **Required:** No  
      * **Notes:** Links to the Personnel table (Section A.1.2). Allows linking to only one Personnel record. For MVP, this field can be included in the schema but may be hidden in default user data entry views, to be used when specific accountability for the act of return processing is required.


### **A.1.10. Operators Table (Master)**

* **Purpose:** Master list of entities (companies or individuals) that operate the wells or sites. This table helps track who is responsible for the day-to-day operations of specific sites.
* **SDD Reference:** Section 3.1.10
* **Fields:**
    1.  **OperatorID\_PK** (Primary Key - Airtable Autonumber)
        * *Description:* Unique system-generated identifier for the operator.
        * *Field-Type Details:* Autonumber preferred for simplicity.
        * *Required:* Yes
    2.  **OperatorName** (Single Line Text, Required)
        * *Description:* Official name of the operating entity or full name of the individual operator. Should ideally be unique.
        * *Field-Type Details:* Required field.
        * *Required:* Yes
    3.  **ContactPerson\_FirstName** (Single Line Text, Optional)
        * *Description:* First name of the primary contact person at the operating entity.
        * *Required:* No
    4.  **ContactPerson\_LastName** (Single Line Text, Optional)
        * *Description:* Last name of the primary contact person at the operating entity.
        * *Required:* No
    5.  **Email** (Email, Optional)
        * *Description:* Primary contact email address for the operator or their main contact person.
        * *Field-Type Details:* Airtable Email type.
        * *Required:* No
    6.  **Phone** (Phone Number, Optional)
        * *Description:* Primary contact phone number for the operator or their main contact person.
        * *Field-Type Details:* Airtable Phone Number type.
        * *Required:* No
    7.  **Address\_Street1** (Single Line Text, Optional)
        * *Description:* Street address line 1 for the operator.
        * *Required:* No
    8.  **Address\_Street2** (Single Line Text, Optional)
        * *Description:* Street address line 2 for the operator (e.g., suite, floor, P.O. Box).
        * *Required:* No
    9.  **Address\_City** (Single Line Text, Optional)
        * *Description:* City for the operator's address.
        * *Required:* No
    10. **Address\_State** (Single Line Text, Optional)
        * *Description:* State or province for the operator's address.
        * *Required:* No
    11. **Address\_Zip** (Single Line Text, Optional)
        * *Description:* Postal code for the operator's address.
        * *Required:* No
    12. **FullAddress** (Formula, Optional)
        * *Description:* A calculated field that combines the individual address components into a single, formatted string.
        * *Field-Type Details:* Formula: `IF({Address_Street1}, {Address_Street1} & "\n", "") & IF({Address_Street2}, {Address_Street2} & "\n", "") & IF({Address_City}, {Address_City} & ", ", "") & IF({Address_State}, {Address_State} & " ", "") & IF({Address_Zip}, {Address_Zip}, "")`
        * *Required:* No
    13. **OperatedSites\_Link** (Link to Sites table, multiple, Optional)
        * *Description:* Links to the Sites records that this entity operates.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Sites table. Allows linking to multiple sites. On the Sites table, the corresponding link would be `Operator_Link` (linking to one Operator).
        * *Required:* No
    14. **RelevantAgreements\_Link** (Link to Licenses & Agreements table, multiple, Optional)
        * *Description:* Links to operating agreements, service contracts, or other relevant legal documents with this operator stored in the Licenses & Agreements table.
        * *Field-Type Details:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.
        * *Required:* No
    15. **Notes** (Long Text, Optional)
        * *Description:* General notes about the operator, their responsibilities, typical scope of work, historical performance, or any other relevant information.
        * *Field-Type Details:* Use Airtable's Long Text with rich text enabled.
        * *Required:* No
    16. **IsActive** (Checkbox, Default: TRUE)
        * *Description:* Indicates if this is a current, active operator. Uncheck for former or inactive operators.
        * *Field-Type Details:* Default value for new records is TRUE.
        * *Required:* No


### **A.1.11. Licenses & Agreements Table (Master)**

* **Purpose:** A consolidated repository for all contracts, permits, licenses, legal documents, and other formal agreements relevant to the business operations, sites, personnel, partners, and vendors.
* **SDD Reference:** Section 3.1.11
* **Fields:**
    1.  **AgreementID\_PK** (Primary Key - Airtable Autonumber)
        * *Description:* Unique system-generated identifier for the agreement record.
        * *Field-Type Details:* Autonumber preferred.
        * *Required:* Yes
    2.  **AgreementName** (Single Line Text, Required)
        * *Description:* A clear, descriptive name for the agreement (e.g., "Site Alpha Gas Purchase Agreement - XYZ Corp", "John Doe Employment Contract", "Master Service Agreement - ABC Electrics").
        * *Field-Type Details:* Required field.
        * *Required:* Yes
    3.  **AgreementType** (Single Select)
        * *Description:* Classifies the nature or category of the agreement.
        * *Field-Type Details:* Allows users to add new options.
        * *Options:* "Gas Purchase Agreement", "Permit - Environmental", "Permit - Construction", "License - Operational", "Service Agreement (MSA)", "Statement of Work (SOW)", "Purchase Order (PO)", "Lease Agreement - Land", "Lease Agreement - Equipment", "Partnership Agreement", "Joint Venture Agreement", "Vendor Contract", "Non-Disclosure Agreement (NDA)", "Employment Agreement", "Consulting Agreement", "Financing Agreement", "Insurance Policy", "Other".
        * *Required:* No
    4.  **Status** (Single Select)
        * *Description:* Current lifecycle status of the agreement.
        * *Field-Type Details:* Options can be color-coded in Airtable for visibility.
        * *Options:* "Draft", "Under Review", "Pending Signature", "Active", "Expired", "Terminated", "Archived", "Superseded".
        * *Required:* No
    5.  **CounterpartyName** (Single Line Text, Optional)
        * *Description:* The name of the other party (or primary other party) to the agreement, if not represented by a linked record (e.g., an individual, a company not yet in Partners/Vendors). If linked below, this can be a formula to pull from the linked record or a manually entered name for external entities.
        * *Required:* No
    6.  **Counterparty\_Link\_Partner** (Link to Partners table, optional)
        * *Description:* Links to a Partner record if the agreement is with a partner.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Partners table. Allows linking to one partner.
        * *Required:* No
    7.  **Counterparty\_Link\_Vendor** (Link to Vendors table, optional)
        * *Description:* Links to a Vendor record if the agreement is with a vendor.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Vendors table. Allows linking to one vendor.
        * *Required:* No
    8.  **Counterparty\_Link\_Operator** (Link to Operators table, optional)
        * *Description:* Links to an Operator record if the agreement is with a site operator.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Operators table. Allows linking to one operator.
        * *Required:* No
    9.  **Counterparty\_Link\_Personnel** (Link to Personnel table, optional)
        * *Description:* Links to a Personnel record if the agreement is with an employee (e.g., employment contract).
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Personnel table. Allows linking to one personnel record.
        * *Required:* No
    10. **Site\_Link** (Link to Sites table, multiple, Optional)
        * *Description:* Links to one or more Sites records if the agreement is specific to or directly associated with particular sites (e.g., a site-specific permit, a lease for a specific location).
        * *Field-Type Details:* Airtable Linked Record type, pointing to the Sites table. Allows linking to multiple sites.
        * *Required:* No
    11. **EffectiveDate** (Date, Optional)
        * *Description:* The date on which the agreement becomes legally effective or binding.
        * *Field-Type Details:* Airtable Date type.
        * *Required:* No
    12. **ExpiryDate** (Date, Optional)
        * *Description:* The date on which the agreement is set to expire.
        * *Field-Type Details:* Airtable Date type.
        * *Required:* No
    13. **NoticePeriod\_Days** (Number, Integer, Optional)
        * *Description:* If applicable, the notice period (in days) required for termination or renewal (e.g., 30, 60, 90 days).
        * *Field-Type Details:* Number type, integer.
        * *Required:* No
    14. **RenewalReminderDate** (Date, Formula or Manual, Optional)
        * *Description:* A calculated or manually set date to trigger a reminder for reviewing the agreement for renewal or termination. Could be `DATEADD({ExpiryDate}, -{NoticePeriod_Days}, 'days')` or a manually set date.
        * *Field-Type Details:* Airtable Date type. If formula, ensure fields used are present.
        * *Required:* No
    15. **Document** (Multiple Attachments, Optional)
        * *Description:* Uploaded digital copy/copies of the signed agreement, amendments, and related official documents (e.g., PDF, Word files).
        * *Field-Type Details:* Airtable Attachment type, allows multiple files.
        * *Required:* No
    16. **Document\_Link\_External** (URL, Optional)
        * *Description:* A URL link to the document if stored in an external system (e.g., a dedicated contract management system, a specific folder in Google Drive not managed by the system's site-SOP automation).
        * *Field-Type Details:* URL field type.
        * *Required:* No
    17. **KeyTerms\_Summary** (Long Text, Rich Text, Optional)
        * *Description:* A summary of the key terms, obligations, financial details, and other critical aspects of the agreement. Useful for quick reference without reading the full document.
        * *Field-Type Details:* Long Text with rich text enabled.
        * *Required:* No
    18. **Notes** (Long Text, Rich Text, Optional)
        * *Description:* General notes, comments, history, or any other relevant information about the agreement not captured elsewhere.
        * *Field-Type Details:* Long Text with rich text enabled.
        * *Required:* No
    19. **IsActive\_SystemCheck** (Checkbox, Formula, Optional)
        * *Description:* A formula-based checkbox that indicates if the agreement is currently active based on its `Status` field, or `EffectiveDate` and `ExpiryDate`. For example: `OR(Status="Active", AND(EffectiveDate <= TODAY(), ExpiryDate >= TODAY()))`. This provides an automated check.
        * *Field-Type Details:* Formula returning a boolean.
        * *Required:* No

### **A.1.12. Mining\_Pool\_Accounts Table (Master)**

* **Purpose:** Stores essential information about accounts held with various Bitcoin mining pools, including connection details, credentials, and performance metrics.
* **SDD Reference:** Section 3.1.12
* **Fields:**
    1.  **PoolAccountID\_PK** (Primary Key - Airtable Autonumber)
        * *Description:* Unique system-generated identifier for the mining pool account record.
        * *Field-Type Details:* Autonumber preferred.
        * *Required:* Yes
    2.  **PoolName** (Single Line Text, Required)
        * *Description:* The common name of the mining pool (e.g., "Foundry USA Pool", "AntPool", "Braiins Pool").
        * *Field-Type Details:* Required field. Could also be a Single Select if the list of pools used is fixed, but Single Line Text is more flexible.
        * *Required:* Yes
    3.  **PoolWebsite** (URL, Optional)
        * *Description:* The official website URL for the mining pool.
        * *Field-Type Details:* Airtable URL type.
        * *Required:* No
    4.  **AccountUsername** (Single Line Text, Optional)
        * *Description:* The username or account identifier used to log in to the mining pool's dashboard or for configuring ASICs.
        * *Required:* No
    5.  **DefaultWorkerNameBase** (Single Line Text, Optional)
        * *Description:* The base name or prefix used for worker IDs on this pool (e.g., "10NetZeroSiteA"). The system might append ASIC-specific identifiers to this base.
        * *Required:* No
    6.  **StratumURL\_Primary** (Single Line Text, Optional)
        * *Description:* The primary Stratum connection URL for miners to connect to this pool.
        * *Required:* No
    7.  **StratumURL\_Backup** (Single Line Text, Optional)
        * *Description:* A secondary or backup Stratum connection URL for redundancy.
        * *Required:* No
    8.  **ExpectedFeePercentage** (Percent, Optional)
        * *Description:* The mining fee percentage charged by the pool (e.g., 2.5%).
        * *Field-Type Details:* Airtable Percent type, precision to 1 or 2 decimal places.
        * *Required:* No
    9.  **CurrentTotalHashRate\_THs** (Number, Decimal, Optional)
        * *Description:* The current total hashrate (in TH/s) being directed to this pool account by all associated ASICs. This field is intended to be updated periodically via an external process, API integration with the pool, or manual entry.
        * *Field-Type Details:* Number type, 2 decimal places recommended.
        * *Required:* No
    10. **PayoutWalletAddress** (Single Line Text, Optional)
        * *Description:* The Bitcoin wallet address configured in the pool for receiving mining payouts.
        * *Required:* No
    11. **API\_Key\_ForStats** (Single Line Text, Optional - Store Securely)
        * *Description:* API key provided by the mining pool for accessing account statistics or performance data.
        * *Field-Type Details:* This field contains sensitive information. Consider if direct storage in Airtable is appropriate per security policies, or if it should be managed via a secrets manager and only referenced. For MVP, if stored, ensure base permissions are restrictive.
        * *Required:* No
    12. **ASICs\_Using\_Pool\_Link** (Link to ASICs table, multiple, Optional)
        * *Description:* Links to ASIC records that are currently configured to mine to this pool account.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the ASICs table. Allows linking to multiple ASICs.
        * *Required:* No
    13. **Notes** (Long Text, Rich Text, Optional)
        * *Description:* General notes about the pool account, specific configurations, payout history observations, support contacts, or any other relevant information.
        * *Field-Type Details:* Long Text with rich text enabled.
        * *Required:* No
    14. **IsActive** (Checkbox, Default: TRUE, Optional)
        * *Description:* Indicates if this pool account is currently in active use.
        * *Field-Type Details:* Default value for new records is TRUE.
        * *Required:* No



## **A.2. 10NetZero-FLRTS Base**

This base holds operational data for the FLRTS application and includes synced data from the `10NetZero_Main_Datastore` to provide local references for linking and application use.

### **A.2.1. Synced\_Sites Table**

* **Purpose:** Provides a read-only local reference to the master list of operational sites within the `10NetZero-FLRTS Base`. This allows FLRTS items to be linked to sites without directly querying or modifying the `10NetZero_Main_Datastore` for this purpose.
* **SDD Reference:** Section 3.2.1
* **Source:** This table is populated and kept up-to-date via a one-way synchronization from the **Sites Table (Master)** (Section A.1.1) in the `10NetZero_Main_Datastore` base, using Airtable's native sync feature.
* **Fields:**
    * All fields in this table mirror the fields defined in the **Sites Table (Master)** (see Section A.1.1 for detailed field definitions).
    * The synchronization setting should include all fields from the source `Sites` table.
* **Notes:**
    * Data in this table is read-only within the `10NetZero-FLRTS Base` context. Any additions or modifications to site information must be made in the source `Sites` table in the `10NetZero_Main_Datastore`.
    * The primary key (`SiteID_PK` or its equivalent) from the source table will be synced and should be used for reliable linking.


### **A.2.3. Users Table (FLRTS App Specific)**

* **Purpose:** Manages FLRTS application-specific user records, primarily linking authenticated `Personnel` (via `TelegramUserID`) to their activity within the FLRTS system. For MVP, detailed role-based permissioning via the flags below is largely deferred for users interacting through the Telegram Bot/MiniApp, with such users operating under a unified "FLRTS Operator" model. The comprehensive permission flags are included in the schema for future enhancements and for potential use by the Flask Admin Panel.
* **SDD Reference:** Sections 3.2.3, 4.1 (MVP Simplification)
* **Fields:**
    1.  **UserID\_PK** (Primary Key - Airtable Autonumber or UUID)
        * *Description:* Unique system-generated identifier for the FLRTS user record.
        * *Field-Type Details:* Autonumber preferred for simplicity.
        * *Required:* Yes
    2.  **Personnel\_Link** (Link to `Synced_Personnel` table, Required, Unique)
        * *Description:* Links this FLRTS user record to the corresponding master record in the `Synced_Personnel` table.
        * *Field-Type Details:* Airtable Linked Record type, pointing to `Synced_Personnel`. Must link to one `Synced_Personnel` record. Unique.
        * *Required:* Yes
    3.  **FLRTS\_Role** (Single Select)
        * *Description:* Defines the user's nominal role. For MVP, users interacting via the Telegram Bot/MiniApp will functionally be "FLRTS Operators." This field allows for future role differentiation.
        * *Field-Type Details:* Default value for new records: "FLRTS Operator".
        * *Options (initial set, can be expanded post-MVP):* "FLRTS Operator", "Manager", "Admin".
        * *Required:* Yes (or set a default)
    4.  **PasswordHash** (Single Line Text, Conceptual)
        * *Description:* Conceptual field for storing a hashed password if a future version of the FLRTS application implements direct username/password authentication for a web UI, separate from the main Flask Admin Panel's specific login. Not used for Telegram bot authentication.
        * *Required:* No
    5.  **IsActive** (Checkbox, Default: TRUE)
        * *Description:* Indicates if the FLRTS user account is currently active. Can be used to disable a user's bot access if needed.
        * *Required:* No
    6.  **DateAdded** (Created Time)
        * *Description:* Timestamp of when the FLRTS user record was created.
        * *Field-Type Details:* Airtable 'Created time' type.
        * *Required:* Yes (system-generated)
    7.  **LastLoginTimestamp** (Date, Optional)
        * *Description:* Timestamp of the user's last login or significant interaction with the system. Updated by the backend application.
        * *Field-Type Details:* Airtable Date type with time enabled.
        * *Required:* No

    ---
    **Permission Flags:**

    * ***MVP Note on Permission Flags:*** *For the MVP, the following permission flags are defined in the schema for future use and potential application by the Flask Admin Panel logic. For users interacting via the Telegram Bot/MiniApp (i.e., "FLRTS Operators"), these granular flags are generally NOT actively checked or enforced by the application logic; their capabilities are broadly defined in SDD Section 4.1. The Flask Admin Panel will have its own separate authentication (`___FLASK_ADMIN_USER___`/`___FLASK_ADMIN_PASS___`) and may implement logic based on a user's `FLRTS_Role` if specific admin users are also represented in this table.*
    ---
    8.  **Can\_Access\_Admin\_UI** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Indicates if the user (if their `Personnel_Link` is an admin) can access the Flask Admin Panel. Primary access to Admin Panel is via shared credentials for MVP.
        * *Required:* No
    9.  **Can\_View\_System\_Logs** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to view system logs, typically via an Admin UI.
        * *Required:* No
    10. **Can\_Manage\_System\_Settings** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to modify system-wide settings.
        * *Required:* No
    11. **Can\_Manage\_Integrations** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to configure third-party integrations.
        * *Required:* No
    12. **Can\_Manage\_All\_Users** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to manage other user accounts (create, edit roles/permissions).
        * *Required:* No
    13. **Can\_Manage\_All\_Permissions** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to modify the permission settings or role definitions themselves.
        * *Required:* No
    14. **Can\_CRUD\_All\_FLRTS\_Items\_Global** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Unrestricted Create, Read, Update, Delete access to all FLRTS items globally, overriding privacy.
        * *Required:* No
    15. **Can\_CRUD\_All\_MasterData\_Global** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Unrestricted Create, Read, Update, Delete access to all records in all Main Datastore tables.
        * *Required:* No
    16. **Can\_Read\_All\_FLRTS\_Items\_Global** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to read all FLRTS items (e.g., Lists, Field Reports). For MVP Bot/MiniApp, this is effectively TRUE for all users for most items.
        * *Required:* No
    17. **Can\_View\_All\_Tasks\_Reminders\_Global** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view all Tasks and Reminders across the system. For MVP Bot/MiniApp, this is effectively TRUE for all users.
        * *Required:* No
    18. **Can\_View\_Own\_Or\_Assigned\_Tasks\_Reminders** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission for a user to view only tasks/reminders they created or are assigned to. Superseded by global view for MVP Bot/MiniApp.
        * *Required:* No
    19. **Can\_Create\_Edit\_Own\_FLRTS\_Items** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Basic permission to create/edit one's own FLRTS items. Assumed TRUE for all active FLRTS Operators in MVP.
        * *Required:* No
    20. **Can\_Add\_To\_System\_Lists** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to add items to system-generated lists. Assumed TRUE for all active FLRTS Operators in MVP.
        * *Required:* No
    21. **Can\_Create\_MasterData\_Site** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to create new Site records in the Main Datastore.
        * *Required:* No
    22. **Can\_Create\_MasterData\_Personnel** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to create new Personnel records in the Main Datastore.
        * *Required:* No
    23. **Can\_Edit\_MasterData\_Via\_UI** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Broad permission to edit master data via an Admin UI.
        * *Required:* No
    24. **Can\_View\_MasterData\_Sites** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view Site records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    25. **Can\_View\_MasterData\_Personnel** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view Personnel records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    26. **Can\_View\_MasterData\_Vendors** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view Vendor records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    27. **Can\_View\_MasterData\_Equipment** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view Equipment records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    28. **Can\_View\_MasterData\_ASICs** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view ASIC records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    29. **Can\_View\_MasterData\_Operators** (Checkbox, Default: TRUE for MVP Bot Users' effective capability)
        * *Description:* (Future Granular Control) Permission to view Operator records. Assumed available as needed for context for FLRTS Operators in MVP.
        * *Required:* No
    30. **Can\_View\_MasterData\_Partners** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to view sensitive Partners master data. Not available to general FLRTS Operators via bot in MVP.
        * *Required:* No
    31. **Can\_View\_MasterData\_LicensesAgreements** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to view sensitive Licenses & Agreements master data. Not available to general FLRTS Operators via bot in MVP.
        * *Required:* No
    32. **Can\_View\_MasterData\_MiningPools** (Checkbox, Default: FALSE)
        * *Description:* (Future/Admin Panel) Permission to view sensitive Mining Pool Accounts master data. Not available to general FLRTS Operators via bot in MVP.
        * *Required:* No

---
**(End of Document Update Block)**

This provides the simplified SDD Section 4 focused on the MVP operational model and the detailed `Users` table definition for Appendix A, which retains the permission fields for future use but clearly states their non-enforcement in the MVP for bot/MiniApp users.

Please let me know if these revisions are suitable.

### **A.2.4. FLRTS\_Items Table**

* **Purpose:** This is the core operational table for the FLRTS application, storing all Field Reports, Lists, Reminders, Tasks, and Subtasks created by users or the system.
* **SDD Reference:** Section 3.2.4
* **Fields:**
    1.  **ItemID\_PK** (Primary Key - Airtable Autonumber or UUID)
        * *Description:* Unique system-generated identifier for each FLRTS item.
        * *Field-Type Details:* Autonumber is simple; UUID can be generated by Flask if preferred for global uniqueness before saving.
        * *Required:* Yes
    2.  **ItemType** (Single Select, Required)
        * *Description:* Classifies the nature of the FLRTS item.
        * *Options:* "Field Report", "List", "Reminder", "Task", "Subtask".
        * *Required:* Yes
    3.  **Title** (Single Line Text)
        * *Description:* A concise title for the item. For "Field Report" type, this might be auto-generated (e.g., "Field Report - [Date] - [Site]") or set by the LLM; for new Field Reports from raw input, LLM might set this to null initially. For other types, usually user-supplied or derived.
        * *Required:* No (conditionally required depending on `ItemType` and workflow)
    4.  **Description** (Long Text, Rich Text)
        * *Description:* The main content or body of the FLRTS item. Crucial for "Field Report" (contains the report text), "Task"/"Subtask" (details of the task), "List" (overall purpose of the list), "Reminder" (details of what to be reminded about).
        * *Required:* No (but often essential)
    5.  **Status** (Single Select)
        * *Description:* The current workflow status of the item.
        * *Options:* "Open", "In Progress", "Completed", "Pending Review", "On Hold", "Cancelled", "Archived". (Expanded from SDD for more states)
        * *Required:* No (should default to "Open" or similar)
    6.  **Priority** (Single Select)
        * *Description:* The urgency or importance of the item.
        * *Options:* "Highest", "High", "Medium", "Low", "Lowest".
        * *Required:* No (can default to "Medium")
    7.  **DueDate** (Date)
        * *Description:* The date (and optionally time) by which the item is expected to be completed. If the item is synced with Todoist, Todoist is the authoritative source for this value.
        * *Field-Type Details:* Airtable Date type, "Include a time field" enabled.
        * *Required:* No
    8.  **ReminderTime** (Date)
        * *Description:* Specific date and time for a reminder, if the item itself is a "Reminder" type and not primarily managed by Todoist, or for ad-hoc reminders on other item types.
        * *Field-Type Details:* Airtable Date type, "Include a time field" enabled.
        * *Required:* No
    9.  **CreatedDate** (Created Time)
        * *Description:* Timestamp of when the FLRTS item was created.
        * *Field-Type Details:* Airtable 'Created time' type.
        * *Required:* Yes (system-generated)
    10. **CreatedBy\_UserLink** (Link to Users table)
        * *Description:* Links to the FLRTS user who created this item.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the `Users` table.
        * *Required:* No (but should be set by the system; could link to a "System" user for system-generated items)
    11. **LastModifiedDate** (Last Modified Time)
        * *Description:* Timestamp of when the FLRTS item was last modified.
        * *Field-Type Details:* Airtable 'Last modified time' type.
        * *Required:* Yes (system-generated)
    12. **AssignedTo\_UserLink** (Link to Users table, multiple)
        * *Description:* Links to one or more FLRTS users to whom this item is assigned.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the `Users` table. "Allow linking to multiple records" should be TRUE.
        * *Required:* No
    13. **Site\_Link** (Link to Synced\_Sites table)
        * *Description:* Links to a site in the `Synced_Sites` table if the item is specific to a particular site.
        * *Field-Type Details:* Airtable Linked Record type, pointing to `Synced_Sites`.
        * *Required:* No
    14. **Scope** (Single Select)
        * *Description:* Defines the context or applicability of the item.
        * *Options:* "Site" (related to a specific linked site), "Personnel" (related to a specific person, perhaps the assignee or creator), "Project" (if project tracking is added later), "General" (not specific to site/personnel).
        * *Required:* No (could default to "General")
    15. **Visibility** (Single Select)
        * *Description:* Controls who can view the item (conceptual, actual enforcement by application logic).
        * *Options:* "Public" (viewable by users according to their general role permissions), "Private" (viewable only by creator, assignees, and admins/managers).
        * *Required:* No (could default to "Public")
    16. **ParentItem\_Link** (Link to FLRTS\_Items table, self-linking)
        * *Description:* If this item is a "Subtask" or an item within a "List", this field links to the parent "Task" or "List" item in this same table.
        * *Field-Type Details:* Airtable Linked Record type, pointing to this `FLRTS_Items` table itself.
        * *Required:* No
    17. **TodoistTaskID** (Single Line Text, Unique)
        * *Description:* Stores the unique ID of the corresponding task in Todoist if this item is synced with Todoist. Used for synchronization and linking.
        * *Field-Type Details:* Should be marked as unique if possible in Airtable, though uniqueness is managed by the backend.
        * *Required:* No
    18. **RawTelegramInput** (Long Text)
        * *Description:* Stores the original, unprocessed natural language input received from the user via Telegram (or other input source) that led to the creation of this item. Useful for debugging, retraining LLMs, or understanding user intent.
        * *Required:* No
    19. **ParsedLLM\_JSON** (Long Text, AI-enabled in Airtable optional)
        * *Description:* Stores the structured JSON output received from the General LLM after parsing the user's input. This shows what the LLM extracted.
        * *Field-Type Details:* Airtable's "AI Text" field type could be considered if direct Airtable AI features are used for this, otherwise Long Text.
        * *Required:* No
    20. **Source** (Single Select)
        * *Description:* Indicates how the FLRTS item was created.
        * *Options:* "Telegram Bot", "Telegram MiniApp", "Admin Web UI", "System Generated", "Todoist Sync", "SiteGPT Suggestion" (Post-MVP).
        * *Required:* No (should be set by the system)
    21. **IsSystemGenerated** (Checkbox, Default: FALSE)
        * *Description:* Flag indicating if the item was programmatically generated by the system (e.g., default site lists, onboarding tasks) rather than directly by a user.
        * *Required:* No
    22. **SystemListCategory** (Single Select, Optional)
        * *Description:* For system-generated lists, this categorizes the list's purpose (e.g., "Site\_Tools", "Site\_Tasks\_Master", "Site\_Shopping", "Employee\_Onboarding"). Null for user-created items or non-list types.
        * *Options:* "Site\_Tools\_List", "Site\_Master\_Task\_List", "Site\_Shopping\_List", "Employee\_Onboarding\_List", (add others as needed).
        * *Required:* No
    23. **IsArchived** (Checkbox, Default: FALSE)
        * *Description:* Flag indicating if the item has been archived. Archived items are typically hidden from active views but retained for records.
        * *Required:* No
    24. **ArchivedBy\_UserLink** (Link to Users table)
        * *Description:* Links to the FLRTS user who archived this item.
        * *Field-Type Details:* Linked Record type, pointing to the `Users` table.
        * *Required:* No
    25. **ArchivedAt\_Timestamp** (Date)
        * *Description:* Timestamp of when the item was archived.
        * *Field-Type Details:* Date type with time field enabled.
        * *Required:* No
    26. **DoneAt\_Timestamp** (Date)
        * *Description:* Timestamp of when the item was marked as "Completed" or its equivalent final state.
        * *Field-Type Details:* Date type with time field enabled.
        * *Required:* No
    27. **Tags** (Multiple Select, Optional)
        * *Description:* User-defined tags for categorizing or filtering items.
        * *Field-Type Details:* Airtable Multiple Select type, allows users to create new tags.
        * *Required:* No
    28. **Attachments** (Multiple Attachments, Optional)
        * *Description:* For uploading files directly related to the FLRTS item (e.g., photos for a field report, documents for a task).
        * *Field-Type Details:* Airtable Attachment type.
        * *Required:* No

### **A.2.5. Field\_Report\_Edits Table**

* **Purpose:** Stores an append-only history of edits made to "Field Report" type items from the `FLRTS_Items` table. This ensures that original report content and subsequent modifications are preserved for auditability and tracking.
* **SDD Reference:** Section 3.2.5
* **Fields:**
    1.  **EditID\_PK** (Primary Key - Airtable Autonumber)
        * *Description:* Unique system-generated identifier for each edit record.
        * *Field-Type Details:* Autonumber preferred.
        * *Required:* Yes
    2.  **ParentFieldReport\_Link** (Link to FLRTS\_Items table, Required)
        * *Description:* Links to the specific "Field Report" item in the `FLRTS_Items` table that this edit pertains to.
        * *Field-Type Details:* Airtable Linked Record type, pointing to `FLRTS_Items`. This link should ideally be filtered or validated to ensure it only links to items where `FLRTS_Items.ItemType` = "Field Report".
        * *Required:* Yes
    3.  **Author\_UserLink** (Link to Users table, Required)
        * *Description:* Links to the FLRTS user who made this specific edit.
        * *Field-Type Details:* Airtable Linked Record type, pointing to the `Users` table.
        * *Required:* Yes
    4.  **Timestamp** (Created Time)
        * *Description:* Timestamp of when this edit record was created (i.e., when the edit was saved).
        * *Field-Type Details:* Airtable 'Created time' type.
        * *Required:* Yes (system-generated)
    5.  **EditText** (Long Text, Rich Text, Required)
        * *Description:* The actual content of the edit. Depending on the editing strategy, this could be the full text of the field report *after* the edit, or just the delta/changes made. For simplicity and audit, storing the full text as of that version is often easier.
        * *Required:* Yes
    6.  **EditSummary** (Single Line Text, Optional)
        * *Description:* An optional, brief summary of the changes made in this edit (e.g., "Corrected typos in section 2", "Added equipment readings"). Could be user-supplied or system-generated if a diffing mechanism is in place.
        * *Required:* No
    7.  **VersionNumber** (Number, Integer, Optional)
        * *Description:* A sequential version number for the edits of a particular field report (e.g., 1, 2, 3...). This would require application logic to calculate and assign.
        * *Field-Type Details:* Number type, integer.
        * *Required:* No