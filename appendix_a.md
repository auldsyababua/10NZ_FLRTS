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
  * *Airtable Field Type Notes:* Autonumber preferred for simplicity.
2. **SiteName** (Single Line Text, Required)
  * *Description:* Common, human-readable name for the site. Must be unique.
3. **SiteAddress_Street** (Single Line Text)
  * *Description:* Street number and name for the site's physical address.
4. **SiteAddress_City** (Single Line Text)
  * *Description:* City for the site's physical address.
5. **SiteAddress_State** (Single Line Text)
  * *Description:* State or province for the site's physical address.
6. **SiteAddress_Zip** (Single Line Text)
  * *Description:* Postal code for the site's physical address.
7. **SiteLatitude** (Number, Decimal)
  * *Description:* Latitude of the site in decimal degrees. For mapping and location services.
  * *Airtable Field Type Notes:* Precision should be at least 6 decimal places.
8. **SiteLongitude** (Number, Decimal)
  * *Description:* Longitude of the site in decimal degrees. For mapping and location services.
  * *Airtable Field Type Notes:* Precision should be at least 6 decimal places.
9. **SiteStatus** (Single Select)
  * *Description:* Current high-level operational status of the site.
  * *Options:* "Commissioning", "Running", "In Maintenance", "Contracted", "Planned", "Decommissioned".
10. **Operator_Link** (Link to Operators table)
  * *Description:* Links to the primary operator entity responsible for this site. (Allows linking to one record from the Operators table).
11. **Site_Partner_Assignments_Link** (Lookup or Rollup via Site_Partner_Assignments table – TBD, or direct Link field)
  * *Description:* Displays partners associated with this site via the Site_Partner_Assignments junction table.
  * *Notes:* SDD states "Link to Site_Partner_Assignments table". This creates a link *from* Sites *to* the junction. Typically, you link *from* the junction *to* Sites. We'll refine this when defining junction tables. For now, the intent is clear: to see related partners.
12. **Site_Vendor_Assignments_Link** (Lookup or Rollup via Site_Vendor_Assignments table – TBD, or direct Link field)
  * *Description:* Displays vendors assigned to this site via the Site_Vendor_Assignments junction table.
  * *Notes:* Same as above regarding link direction.
13. **Licenses_Agreements_Link** (Link to Licenses & Agreements table)
  * *Description:* Links to contracts, permits, or agreements directly associated with this site. (Allows linking to multiple records).
14. **Equipment_At_Site_Link** (Link to Equipment table, multiple)
  * *Description:* Links to records of general equipment (non-ASIC) physically located or primarily assigned to this site. (This field on the Sites table would be a "Linked Record" field type allowing multiple Equipment records. The corresponding link would be on the Equipment table, likely as SiteLocation_Link).
15. **ASICs_At_Site_Link** (Link to ASICs table, multiple)
  * *Description:* Links to records of ASIC mining hardware physically located or primarily assigned to this site. (Similar to Equipment_At_Site_Link).
16. **SOP_Document_Link** (URL)
  * *Description:* Direct link to this site's official Standard Operating Procedure (SOP) master document, stored in Google Drive. This document is automatically generated and linked by the system upon site creation.
17. **IsActive** (Checkbox, Default: TRUE)
  * *Description:* Indicates if the site record is currently considered active and should appear in regular operational listings and interfaces. Uncheck for temporarily inactive or archived sites.
18. **Default_Lists_Created_by_App** (Checkbox, Default: FALSE)
  * *Description:* System field. Set to TRUE by the Flask application after successfully creating the site's default programmatic FLRTS lists (e.g., Tools List, Master Task List, Shopping List). Used by safety net automations to ensure these essential lists are created.
  * *Notes:* We will need to ensure the successful creation of the SOP_Document_Link is also covered by a safety net, possibly by expanding this flag or adding another like Initial_Site_Setup_Completed_by_App. We can detail this in SDD Section 8.1.

### **A.1.2. Personnel Table (Master)**

* **Purpose:** Master list of all employees and individuals who might interact with or be referenced in the system. This includes users of the FLRTS application.  
* **SDD Reference:** Section 3.1.2  
* **Fields:**  
  1. PersonnelID\_PK (Primary Key \- Airtable Autonumber or Formula generating "P001" style ID)  
     * *Description:* Unique system-generated identifier for the personnel record.  
     * *Airtable Field Type Notes:* Autonumber preferred for simplicity.  
  2. FullName (Single Line Text, Required)  
     * *Description:* Full legal name of the individual.  
     * *Airtable Field Type Notes:* Required field.  
  3. WorkEmail (Email, Unique)  
     * *Description:* Primary work email address. Must be unique across all personnel records. Used for system notifications if not via Telegram and for initial user account linking if applicable.  
     * *Airtable Field Type Notes:* Airtable Email type. Constraint: Unique.  
  4. PhoneNumber (Phone Number)  
     * *Description:* Primary contact phone number for the individual (e.g., work mobile).  
     * *Airtable Field Type Notes:* Airtable Phone Number type.  
  5. TelegramUserID (Number, Unique)  
     * *Description:* The unique, permanent numeric User ID assigned by Telegram to the user's account. This is crucial for bot interaction, FLRTS user account identification, and system security.  
     * *Airtable Field Type Notes:* Airtable Number type (Integer). Constraint: Unique. This field is essential if the personnel will use the Telegram bot.  
  6. TelegramHandle (Single Line Text, Optional)  
     * *Description:* The user's Telegram @username (e.g., @colinaulds). Used for display, user-friendly mentions, and as a convenience. Not used as a primary identifier by the system as it can be changed by the user.  
     * *Airtable Field Type Notes:* Optional field.  
  7. EmployeePosition (Single Line Text)  
     * *Description:* The individual's official job title or formal position within the organization (e.g., "Field Technician," "Operations Manager," "Director of Operations").  
  8. StartDate (Date)  
     * *Description:* The individual's official start date with the company or engagement.  
     * *Airtable Field Type Notes:* Airtable Date type (no time component needed).  
  9. EmploymentContract\_Link (Link to Licenses & Agreements table, Optional)  
     * *Description:* Links to the individual's employment contract or other relevant legal agreements stored in the Licenses & Agreements table.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Licenses & Agreements table.  
  10. Assigned\_Equipment\_Log\_Link (Link to Employee\_Equipment\_Log table)  
      * *Description:* Shows equipment currently or previously assigned to this person via the Employee\_Equipment\_Log junction table.  
      * *Airtable Field Type Notes:* This will be an Airtable Linked Record field that allows linking to multiple records from the Employee\_Equipment\_Log table. The primary links are made *from* the Employee\_Equipment\_Log table *to* Personnel and Equipment.  
  11. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if the personnel record is currently active (e.g., current employee). Uncheck for former employees or inactive records. Controls visibility in some system lookups.  
      * *Airtable Field Type Notes:* Default value for new records is TRUE.  
  12. Default\_Employee\_Lists\_Created (Checkbox, Default: FALSE)  
      * *Description:* System field. Set to TRUE by the Flask application after successfully creating the employee's default "Onboarding" FLRTS list. Used by safety net automations to ensure this list is programmatically generated.  
      * *Airtable Field Type Notes:* Default value for new records is FALSE.

### **A.1.3. Partners Table (Master)**

* **Purpose:** Master list of partner organizations or individuals, primarily those with an investment, lending, or funding relationship concerning 10NetZero projects/sites.  
* **SDD Reference:** Section 3.1.3  
* **Fields:**  
  1. PartnerID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the partner.  
     * *Airtable Field Type Notes:* Autonumber preferred.  
  2. PartnerName (Single Line Text, Required)  
     * *Description:* Official name of the partner organization or full name of the individual partner. Must be unique.  
     * *Airtable Field Type Notes:* Required field.  
  3. PartnerType (Single Select)  
     * *Description:* Classifies the nature of the partnership.  
     * *Options:* "Co-Investor", "Site JV Partner", "Lender", "Fundraiser/Placement Agent", "Other Financial Partner".  
  4. Logo (Multiple Attachments, Optional)  
     * *Description:* Partner's company logo or relevant branding images.  
     * *Airtable Field Type Notes:* Airtable Attachment type, allows multiple files.  
  5. ContactPerson\_FirstName (Single Line Text, Optional)  
     * *Description:* First name of the primary contact person at the partner organization.  
  6. ContactPerson\_LastName (Single Line Text, Optional)  
     * *Description:* Last name of the primary contact person at the partner organization.  
  7. Email (Email, Optional)  
     * *Description:* Primary contact email address for the partner or the main contact person.  
     * *Airtable Field Type Notes:* Airtable Email type.  
  8. Phone (Phone Number, Optional)  
     * *Description:* Primary contact phone number for the partner or the main contact person.  
     * *Airtable Field Type Notes:* Airtable Phone Number type.  
  9. Address\_Street1 (Single Line Text, Optional)  
     * *Description:* Street address line 1 for the partner.  
  10. Address\_Street2 (Single Line Text, Optional)  
      * *Description:* Street address line 2 for the partner (e.g., suite, floor, P.O. Box).  
  11. Address\_City (Single Line Text, Optional)  
      * *Description:* City for the partner's address.  
  12. Address\_State (Single Line Text, Optional)  
      * *Description:* State or province for the partner's address.  
  13. Address\_Zip (Single Line Text, Optional)  
      * *Description:* Postal code for the partner's address.  
  14. FullAddress (Formula)  
      * *Description:* A calculated field that combines the individual address components into a single, formatted string for easy viewing or copying.  
      * *Airtable Field Type Notes:* Formula field. Example formula: IF({Address\_Street1}, {Address\_Street1} & "\\n", "") & IF({Address\_Street2}, {Address\_Street2} & "\\n", "") & IF({Address\_City}, {Address\_City} & ", ", "") & IF({Address\_State}, {Address\_State} & " ", "") & IF({Address\_Zip}, {Address\_Zip}, "") (Adjust field names in formula as per actual Airtable field names).  
  15. Website (URL, Optional)  
      * *Description:* Official website of the partner organization.  
      * *Airtable Field Type Notes:* Airtable URL type.  
  16. RelevantAgreements\_Link (Link to Licenses & Agreements table, multiple, Optional)  
      * *Description:* Links to key *general* contracts, master partnership agreements, or other relevant legal documents with this partner stored in the Licenses & Agreements table. Site-specific agreements are linked via the Site\_Partner\_Assignments table.  
      * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
  17. Site\_Assignments\_Link (Link to Site\_Partner\_Assignments table)  
      * *Description:* Shows site-specific assignments, roles, and agreement links for this partner via the Site\_Partner\_Assignments junction table.  
      * *Airtable Field Type Notes:* This will be an Airtable Linked Record field that allows linking to multiple records from Site\_Partner\_Assignments. The primary links are made *from* the Site\_Partner\_Assignments table *to* Partners and Sites.  
  18. Notes (Long Text, Optional)  
      * *Description:* General notes about the partner, relationship history, key terms not captured elsewhere, or high-level financial arrangement summaries.  
      * *Airtable Field Type Notes:* Use Airtable's Long Text with rich text enabled.  
  19. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if this is a current, active partnership. Uncheck for dissolved or inactive partnerships.  
      * *Airtable Field Type Notes:* Default value for new records is TRUE.

### **A.1.4. Site\_Partner\_Assignments Table (Junction Table)**

* **Purpose:** Links Sites and Partners to define specific partnership details for each site. Each record represents a unique relationship between one partner and one site.  
* **SDD Reference:** Section 3.1.4  
* **Fields:**  
  1. AssignmentID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for this specific site-partner assignment.  
     * *Airtable Field Type Notes:* Autonumber preferred.  
  2. LinkedSite (Link to Sites table, Required)  
     * *Description:* Specifies the site involved in this assignment.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Sites table. Must link to one site record. Required field.  
  3. LinkedPartner (Link to Partners table, Required)  
     * *Description:* Specifies the partner involved in this assignment.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Partners table. Must link to one partner record. Required field.  
  4. PartnershipStartDate (Date, Optional)  
     * *Description:* The date this specific partnership assignment at this site commenced.  
     * *Airtable Field Type Notes:* Airtable Date type.  
  5. OwnershipPercentage (Percent, Optional)  
     * *Description:* The partner's ownership percentage specifically related to this site assignment, if applicable.  
     * *Airtable Field Type Notes:* Airtable Percent type, precision set to 0 decimal places (for whole numbers).  
  6. PartnerResponsibilities (Long Text, Optional)  
     * *Description:* Detailed description of the partner's responsibilities, contributions, or role specific to this site assignment.  
     * *Airtable Field Type Notes:* Long Text with rich text enabled for formatting.  
  7. 10NZ\_Responsibilities (Long Text, Optional)  
     * *Description:* Detailed description of 10NetZero's responsibilities or contributions specific to this site assignment in relation to this partner.  
     * *Airtable Field Type Notes:* Long Text with rich text enabled for formatting.  
  8. PartnershipContract\_Link (Link to Licenses & Agreements table, multiple, Optional)  
     * *Description:* Links to specific contracts or agreements in the Licenses & Agreements table that govern this particular site-partner assignment.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
  9. Notes (Long Text, Optional)  
     * *Description:* Any additional notes specific to this site-partner assignment.  
     * *Airtable Field Type Notes:* Long Text with rich text enabled for formatting.

### **A.1.5. Vendors Table (Master)**

* **Purpose:** Master list of all vendor organizations or individuals that provide goods or services.  
* **SDD Reference:** Section 3.1.5  
* **Fields:**  
  1. VendorID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the vendor.  
     * *Airtable Field Type Notes:* Autonumber preferred.  
  2. VendorName (Single Line Text, Required, Unique)  
     * *Description:* Official name of the vendor organization or full name of the individual vendor. Must be unique.  
     * *Airtable Field Type Notes:* Required field. Constraint: Unique.  
  3. ServiceType (Multiple Select)  
     * *Description:* Classifies the primary types of goods or services offered by the vendor.  
     * *Airtable Field Type Notes:* Airtable Multiple Select type.  
     * *Options:* "Electrical Services", "Plumbing Services", "HVAC Services", "Logistics & Transport", "Security Services", "Equipment Rental", "Waste Management", "IT Support", "Consulting \- Engineering", "Consulting \- Financial", "Consulting \- Legal", "Consulting \- Accounting/Audit", "Raw Material Supplier", "ASIC Supplier", "Software Provider", "General Contractor", "Specialized Repair Services", "Office Supplies", "Other". (Allows users to add new options).  
  4. ContactPerson\_FirstName (Single Line Text, Optional)  
     * *Description:* First name of the primary contact person at the vendor organization.  
  5. ContactPerson\_LastName (Single Line Text, Optional)  
     * *Description:* Last name of the primary contact person at the vendor organization.  
  6. Email (Email, Optional)  
     * *Description:* Primary contact email address for the vendor or the main contact person.  
     * *Airtable Field Type Notes:* Airtable Email type.  
  7. Phone (Phone Number, Optional)  
     * *Description:* Primary contact phone number for the vendor or the main contact person.  
     * *Airtable Field Type Notes:* Airtable Phone Number type.  
  8. Address\_Street1 (Single Line Text, Optional)  
     * *Description:* Street address line 1 for the vendor.  
  9. Address\_Street2 (Single Line Text, Optional)  
     * *Description:* Street address line 2 for the vendor (e.g., suite, floor, P.O. Box).  
  10. Address\_City (Single Line Text, Optional)  
      * *Description:* City for the vendor's address.  
  11. Address\_State (Single Line Text, Optional)  
      * *Description:* State or province for the vendor's address.  
  12. Address\_Zip (Single Line Text, Optional)  
      * *Description:* Postal code for the vendor's address.  
  13. FullAddress (Formula)  
      * *Description:* A calculated field that combines the individual address components into a single, formatted string for easy viewing or copying.  
      * *Airtable Field Type Notes:* Formula field. Example formula: IF({Address\_Street1}, {Address\_Street1} & "\\n", "") & IF({Address\_Street2}, {Address\_Street2} & "\\n", "") & IF({Address\_City}, {Address\_City} & ", ", "") & IF({Address\_State}, {Address\_State} & " ", "") & IF({Address\_Zip}, {Address\_Zip}, "") (Adjust field names in formula as per actual Airtable field names).  
  14. Website (URL, Optional)  
      * *Description:* Official website of the vendor organization.  
      * *Airtable Field Type Notes:* Airtable URL type.  
  15. RelevantAgreements\_Link (Link to Licenses & Agreements table, multiple, Optional)  
      * *Description:* Links to key *general* contracts (e.g., Master Service Agreements), rate sheets, or other relevant legal documents with this vendor stored in the Licenses & Agreements table. Site-specific service agreements/POs are linked via the Site\_Vendor\_Assignments table.  
      * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
  16. Vendor\_General\_Attachments (Multiple Attachments, Optional)  
      * *Description:* For general vendor-related documents that are not formal contracts or agreements (e.g., brochures, capability statements, insurance certificates if not tracked formally, miscellaneous correspondence).  
      * *Airtable Field Type Notes:* Airtable Attachment type.  
  17. Site\_Assignments\_Link (Link to Site\_Vendor\_Assignments table)  
      * *Description:* Shows site-specific service assignments, scope, and agreement links for this vendor via the Site\_Vendor\_Assignments junction table.  
      * *Airtable Field Type Notes:* This will be an Airtable Linked Record field that allows linking to multiple records from Site\_Vendor\_Assignments. The primary links are made *from* the Site\_Vendor\_Assignments table *to* Vendors and Sites.  
  18. Notes (Long Text, Optional)  
      * *Description:* General notes about the vendor, service history, performance, key terms not captured elsewhere, etc.  
      * *Airtable Field Type Notes:* Use Airtable's Long Text with rich text enabled.  
  19. IsActive (Checkbox, Default: TRUE)  
      * *Description:* Indicates if this is a current, active vendor relationship. Uncheck for vendors no longer used or approved.  
      * *Airtable Field Type Notes:* Default value for new records is TRUE.

### **A.1.6. Site\_Vendor\_Assignments Table (Junction Table)**

* **Purpose:** Links Vendors and Sites to define specific service or supply details for each site. Each record represents a unique service engagement between one vendor and one site.  
* **SDD Reference:** Section 3.1.6  
* **Fields:**  
  1. VendorAssignmentID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for this specific site-vendor assignment.  
     * *Airtable Field Type Notes:* Autonumber preferred.  
  2. LinkedSite (Link to Sites table, Required)  
     * *Description:* Specifies the site for which the service is being provided.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Sites table. Must link to one site record. Required field.  
  3. LinkedVendor (Link to Vendors table, Required)  
     * *Description:* Specifies the vendor providing the service for this assignment.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Vendors table. Must link to one vendor record. Required field.  
  4. ServiceDescription\_SiteSpecific (Long Text, Optional)  
     * *Description:* A detailed description of the specific services or goods being provided by the vendor for this site assignment (e.g., scope of work, specific tasks, equipment involved).  
     * *Airtable Field Type Notes:* Long Text with rich text enabled for formatting.  
  5. VendorContract\_Link (Link to Licenses & Agreements table, multiple, Optional)  
     * *Description:* Links to specific contracts, Statements of Work (SOWs), Purchase Orders (POs), or other agreements in the Licenses & Agreements table that govern this particular site-vendor assignment.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to Licenses & Agreements, allows multiple links.  
  6. Notes (Long Text, Optional)  
     * *Description:* Any additional notes specific to this site-vendor assignment (e.g., project codes, specific site contact for this job, access instructions).  
     * *Airtable Field Type Notes:* Long Text with rich text enabled for formatting.

### **A.1.7. Equipment Table (Master \- General Assets)**

* **Purpose:** Master list of general physical assets (non-ASIC), such as tools, machinery, vehicles, and IT hardware.  
* **SDD Reference:** Section 3.1.7  
* **Fields:**  
  1. AssetTagID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the equipment item. (Original SDD concept: "10NZ-GEN-001" \- can be a formula field if a specific prefix is desired on top of autonumber).  
     * *Airtable Field Type Notes:* Autonumber preferred for simplicity.  
  2. EquipmentName (Single Line Text, Required)  
     * *Description:* Common, human-readable name or description for the equipment (e.g., "Honda Generator GX390 with Wheel Kit"). This can be manually entered or a formula combining Make, Model, and key features.  
     * *Airtable Field Type Notes:* Required field.  
  3. Make (Single Line Text, Optional)  
     * *Description:* Manufacturer or brand of the equipment (e.g., "Honda", "DeWalt", "Caterpillar").  
  4. Model (Single Line Text, Optional)  
     * *Description:* Specific model name or number of the equipment (e.g., "GX390", "DCD771C2", "308E2").  
  5. EquipmentType (Single Select)  
     * *Description:* Classification of the equipment.  
     * *Airtable Field Type Notes:* Airtable Single Select type.  
     * *Options:* "Generator", "Pump", "Vehicle \- Light Duty", "Vehicle \- Heavy Duty", "Heavy Equipment", "Power Tool \- Corded", "Power Tool \- Cordless", "IT Hardware \- Laptop", "IT Hardware \- Desktop", "IT Hardware \- Monitor", "IT Hardware \- Network Gear", "Safety Gear", "Tool \- Hand", "Tool \- Diagnostic", "Office Equipment", "Other". (Allows users to add new options).  
  6. SerialNumber (Single Line Text, Optional)  
     * *Description:* Manufacturer's serial number for the specific unit. Should be unique if available and tracked.  
     * *Airtable Field Type Notes:* Attempt to ensure uniqueness if practical, but not a strict system constraint if SNs are sometimes unavailable.  
  7. SiteLocation\_Link (Link to Sites table, Optional)  
     * *Description:* Current physical location of the equipment. Links to a Sites record, which can be an operational site or a designated "Warehouse" site.  
     * *Airtable Field Type Notes:* Airtable Linked Record type, pointing to the Sites table. Allows linking to only one site.  
  8. Specifications (Long Text, Optional)  
     * *Description:* Detailed specifications, capabilities, or configuration notes for the equipment.  
     * *Airtable Field Type Notes:* Long Text with rich text enabled.  
  9. PurchaseDate (Date, Optional)  
     * *Description:* Date the equipment was purchased.  
     * *Airtable Field Type Notes:* Airtable Date type.  
  10. PurchasePrice (Currency, Optional)  
      * *Description:* Original purchase price of the equipment.  
      * *Airtable Field Type Notes:* Airtable Currency type.  
  11. PurchaseReceipt (Multiple Attachments, Optional)  
      * *Description:* Scanned copy of the purchase receipt or invoice.  
      * *Airtable Field Type Notes:* Airtable Attachment type.  
  12. CurrentStatus (Single Select)  
      * *Description:* Current operational status of the equipment.  
      * *Airtable Field Type Notes:* Airtable Single Select type.  
      * *Options:* "Operational", "Needs Maintenance", "Out of Service", "In Storage", "In Transit", "Awaiting Repair", "Irreparable/Disposed".  
  13. WarrantyExpiryDate (Date, Optional)  
      * *Description:* Date the manufacturer's or seller's warranty expires.  
      * *Airtable Field Type Notes:* Airtable Date type.  
  14. LastMaintenanceDate (Date, Optional)  
      * *Description:* Date the last maintenance was performed on the equipment.  
      * *Airtable Field Type Notes:* Airtable Date type.  
  15. NextScheduledMaintenanceDate (Date, Optional)  
      * *Description:* Date the next routine maintenance is scheduled or due.  
      * *Airtable Field Type Notes:* Airtable Date type.  
  16. Eq\_Manual (Multiple Attachments, Optional)  
      * *Description:* Digital copy of the equipment's user manual, service manual, or other relevant documentation.  
      * *Airtable Field Type Notes:* Airtable Attachment type.  
  17. EquipmentPictures (Multiple Attachments, Optional)  
      * *Description:* Photographs of the equipment.  
      * *Airtable Field Type Notes:* Airtable Attachment type.  
  18. Employee\_Log\_Link (Link to Employee\_Equipment\_Log table)  
      * *Description:* Shows the assignment history of this equipment to personnel via the Employee\_Equipment\_Log junction table.  
      * *Airtable Field Type Notes:* This will be an Airtable Linked Record field allowing linking to multiple records from Employee\_Equipment\_Log.  
  19. Notes (Long Text, Optional)  
      * *Description:* General notes about the equipment (e.g., known issues, specific configurations, usage history not captured elsewhere).  
      * *Airtable Field Type Notes:* Long Text with rich text enabled.

### **A.1.8. ASICs Table (Master \- Mining Hardware)**

* **Purpose:** Dedicated master list for Bitcoin mining hardware (Application-Specific Integrated Circuits).  
* **SDD Reference:** Section 3.1.8  
* **Fields:**  
  1. ASIC\_ID\_PK (Primary Key \- Airtable Autonumber)  
     * *Description:* Unique system-generated identifier for the ASIC record.  
  2. SerialNumber (Single Line Text, Required, Unique)  
     * *Description:* Manufacturer's serial number for the specific ASIC unit. This should be unique across all ASICs.  
     * *Airtable Field Type Notes:* Required field. Constraint: Unique.  
  3. ASIC\_Make (Single Select)  
     * *Description:* Manufacturer of the ASIC.  
     * *Options:* "Bitmain", "MicroBT", "Canaan", "Other". (Allows adding more later).  
  4. ASIC\_Model (Single Select)  
     * *Description:* Specific model of the ASIC.  
     * *Airtable Field Type Notes:* This list is based on recent models (circa 2024-2025) and may need updating. Allows adding new options.  
     * *Options:* "Antminer S21 Hyd (335Th)", "Antminer S21 Pro (234Th)", "Antminer S21 (200Th)", "Antminer S21 XP Hydro (473Th)", "Antminer S19 XP Hyd (255Th)", "Antminer S19k Pro", "Whatsminer M66S Immersion (298Th)", "Whatsminer M63S Hydro (390Th)", "Whatsminer M60S (186Th)", "Whatsminer M56S (212Th)", "Whatsminer M50S (126Th)", "Whatsminer M30S++", "Avalon A1566", "Other".  
  5. SiteLocation\_Link (Link to Sites table, Optional)  
     * *Description:* Current physical location of the ASIC. Links to a Sites record (operational site or "Warehouse").  
     * *Airtable Field Type Notes:* Linked Record type, pointing to Sites, allows linking to one site.  
  6. RackLocation\_In\_Site (Single Line Text, Optional)  
     * *Description:* Specific location within the site (e.g., "Container A, Rack 3, Shelf B, Unit 1", "Warehouse Shelf C-12").  
  7. PurchaseDate (Date, Optional)  
     * *Description:* Date the ASIC was purchased.  
  8. PurchasePrice (Currency, Optional)  
     * *Description:* Original purchase price of the ASIC.  
  9. CurrentStatus (Single Select)  
     * *Description:* Current operational status of the ASIC.  
     * *Options:* "Mining", "Idle", "Needs Maintenance", "Error", "Offline", "In Storage", "Awaiting Repair", "Decommissioned".  
  10. NominalHashRate\_THs (Number, Decimal, Optional)  
      * *Description:* Manufacturer's specified or expected hash rate in Terahashes per second (TH/s).  
      * *Airtable Field Type Notes:* Number type, 2 decimal places recommended.  
  11. NominalPowerConsumption\_W (Number, Integer, Optional)  
      * *Description:* Manufacturer's specified or expected power consumption in Watts (W).  
      * *Airtable Field Type Notes:* Number type, integer preferred.  
  12. HashRate\_Actual\_THs (Number, Decimal, Optional)  
      * *Description:* Last measured or reported actual hash rate in TH/s. (May be updated by monitoring systems).  
      * *Airtable Field Type Notes:* Number type, 2 decimal places recommended.  
  13. PowerConsumption\_Actual\_W (Number, Integer, Optional)  
      * *Description:* Last measured or reported actual power consumption in Watts. (May be updated by monitoring systems).  
      * *Airtable Field Type Notes:* Number type, integer preferred.  
  14. PoolAccount\_Link (Link to Mining\_Pool\_Accounts table, Optional)  
      * *Description:* Links to the mining pool account this ASIC is configured to use.  
      * *Airtable Field Type Notes:* Linked Record type, pointing to Mining\_Pool\_Accounts.  
  15. FirmwareVersion (Single Line Text, Optional)  
      * *Description:* Current firmware version installed on the ASIC.  
  16. IP\_Address (Single Line Text, Optional)  
      * *Description:* Last known IP address assigned to the ASIC on the local network.  
  17. MAC\_Address (Single Line Text, Optional)  
      * *Description:* Hardware MAC address of the ASIC's network interface.  
  18. LastMaintenanceDate (Date, Optional)  
      * *Description:* Date the last maintenance was performed on this ASIC.  
  19. WarrantyExpiryDate (Date, Optional)  
      * *Description:* Date the manufacturer's or seller's warranty expires.  
  20. ASIC\_Manual (Multiple Attachments, Optional)  
      * *Description:* Digital copy of the ASIC's user manual, technical guides, or related documentation.  
  21. Notes (Long Text, Optional)  
      * *Description:* General notes about the ASIC (e.g., specific configurations, repair history, known issues).  
      * *Airtable Field Type Notes:* Long Text with rich text enabled.

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
     * **Notes:** These specific option names and their documented meanings should be used when configuring this field in Airtable.  
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
     * **Notes:** These specific option names and their documented meanings should be used.  
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

    


