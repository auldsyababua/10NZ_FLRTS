# 10NZ FLRTS Project

## Project Overview

10NetZero-FLRTS provides a comprehensive system for managing field operations, reporting, and task assignment for sustainable energy sites. The application integrates with various MCPs (Model Context Protocol servers) including Todoist, Google Drive, Noloco, Telegram, and Supabase.

## 🎯 Current Status: Phase 1 Complete ✅

**Database Implementation**: The Supabase PostgreSQL schema has been **successfully implemented and audited**. All 28 tables, business logic functions, triggers, and sample data are operational and production-ready.

**Next Phase**: Flask backend development and system integration.

## Database Implementation

This project includes a complete PostgreSQL database schema implementation in Supabase, designed according to the specifications in `docs/noloco_appendix_a.md`. The schema provides a robust relational model with:

- **Master Data Management**: Sites, partners, vendors, operators, and personnel
- **Financial Tracking**: Automated markup calculation and partner billing 
- **Equipment Management**: General equipment and ASIC tracking
- **Operational Management**: Field reports, tasks, reminders, and notifications
- **Audit & Security**: Change tracking and data integrity enforcement

## Key Features

- **Markup Manager**: Automatically calculates and applies markups to vendor invoices based on site-partner relationships
- **Financial Reporting**: Provides detailed financial summaries for partners and sites
- **Operational Management**: Tracks field reports, tasks, and equipment across all sites
- **Integration**: Connects with multiple systems through MCP interfaces
- **Business Logic**: Implemented directly in PostgreSQL with functions and triggers

## File Structure

```
├── database/                    # Core database files
│   ├── supabase_schema_fixed.sql      # Primary database schema
│   ├── supabase_schema_update.sql     # Business logic functions & triggers
│   └── supabase_sample_data_upsert.sql # Test data
├── scripts/                     # Deployment and utility scripts
│   ├── execute_psql.sh               # Direct PostgreSQL deployment
│   ├── push_schema.sh                # Schema deployment script
│   └── supabase_migration.sh         # Migration script
├── docs/                        # Documentation
│   ├── system_design_doc.md          # System architecture
│   ├── noloco_appendix_a.md          # Schema specifications
│   ├── implementation_guide_updated.md # Implementation details
│   ├── AI_Collaboration_Guide_Updated.md # Development standards
│   └── db_implementation_audit.md     # Database audit report
├── supabase/                    # Supabase configuration
│   └── migrations/                    # Migration files
└── .mcp/                        # MCP configuration
    ├── mcp.json                      # Server configuration
    └── various scripts and tools
```

## Database Status: ✅ PRODUCTION READY

The database has been comprehensively audited and verified:

- **28 Tables**: All implemented with correct structure
- **51 Foreign Keys**: All relationships properly configured
- **6 Business Functions**: All markup and financial functions operational
- **3 Triggers**: Automatic processing for invoices and assignments
- **50+ Indexes**: Performance optimized for common queries
- **145 Constraints**: Data validation and integrity enforced
- **Sample Data**: Loaded and tested successfully

## Project Setup

This project uses the Model Context Protocol (MCP) for integrating with external services.

### Quick Setup

Use these aliases to quickly set up and manage the project:

```bash
mcphelp            # Show comprehensive MCP help and documentation
setup10nzflrts     # Configure MCPs and check environment
runflrtsmcps       # Start the MCP servers with detailed error checking
check10nzflrts     # Check if servers are running correctly
debug10nzflrts     # Run comprehensive diagnostics and troubleshooting
editcreds_10nzflrts  # Edit project-specific credentials
```

### Database Access

The Supabase PostgreSQL database is accessible at:
```
Host: db.thnwlykidzhrsagyjncc.supabase.co
Port: 5432
Database: postgres
```

To deploy or update the schema:
```bash
chmod +x scripts/execute_psql.sh
./scripts/execute_psql.sh
```

### MCP Configuration

**Project-specific MCPs** configured in `.mcp/mcp.json`:
- Todoist (for task management)
- Google Drive (for document storage)
- Noloco (for web interface)
- Telegram Bot (for field technician interface)
- Supabase (for database operations)

## Development Standards

This project follows strict development standards outlined in `docs/AI_Collaboration_Guide_Updated.md`:

- **PostgreSQL-first**: Business logic implemented in the database
- **Comprehensive documentation**: All code extensively documented
- **Audit trails**: All changes logged and tracked
- **Performance optimization**: Strategic indexing and query optimization
- **Security**: Row-level security and role-based access control

## Next Steps

With the database foundation complete, the next development phase focuses on:

1. **Flask Backend Development**: Python backend to orchestrate business logic
2. **Telegram Bot Implementation**: Natural language interface for field technicians  
3. **Noloco Web Interface**: Administrative interface connected to Supabase
4. **API Integration**: Connect external services (Todoist, Google Drive, LLM providers)

## License

Proprietary - All rights reserved.

## Contact

For support or questions, contact the 10NetZero team.