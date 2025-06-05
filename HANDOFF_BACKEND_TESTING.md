# 10NetZero-FLRTS Backend Testing Handoff Document

## Session Overview
**Date**: May 22, 2025  
**Phase**: Phase 3 - Testing & Integration  
**Task**: Backend Testing & Deployment  
**Status**: Backend Successfully Started - API Endpoints Need Debugging  

---

## Current State

### ✅ What's Working
- **Flask Backend**: Successfully running on http://127.0.0.1:5001
- **Environment**: Virtual environment configured with all dependencies
- **Configuration**: `.env` file populated with live API keys from MCP
- **Services**: All external services initialize correctly:
  - Supabase database client
  - Telegram bot handler
  - OpenAI service
  - Todoist API service
  - Google Drive service
  - NLP service
- **Health Check**: `/health` endpoint returns proper JSON response
- **Logging**: Application logging working correctly
- **Debug Mode**: Flask running in development mode with detailed error reporting

### 🔍 Current Issue - API Endpoints
**Problem**: All `/api/*` endpoints return 415 UnsupportedMediaType errors  
**Error Message**: `"Did not attempt to load JSON data because the request Content-Type was not 'application/json'"`

**Diagnosis**:
- Health endpoint (`/health`) works perfectly
- Issue is specific to the `/api` blueprint 
- Flask middleware in API blueprint is requiring JSON Content-Type on all requests (including GET)
- Error occurs even when adding `Content-Type: application/json` header

---

## Technical Details

### Backend Environment
```bash
# Location
/Users/colinaulds/Desktop/projects/10NZ_FLRTS/backend

# Virtual Environment
source venv/bin/activate

# Start Command
python app.py
```

### Configuration Files
- **Environment**: `backend/.env` (configured with live API keys)
- **Settings**: `backend/config/settings.py` (Pydantic-based configuration)
- **MCP Keys Source**: `backend/.mcp/.env` (source of API keys)

### Key Configuration Changes Made
1. **CORS Origins**: Changed from `CORS_ORIGINS=*` to `CORS_ORIGINS=["*"]` (JSON array format)
2. **Flask Port**: Changed from 5000 to 5001 (avoid macOS AirPlay conflict)
3. **Async Function**: Fixed `complete_task()` in `api_handler.py:222` to be async

### Dependencies Installed
```bash
# Core Flask dependencies
flask flask-cors supabase psycopg2-binary python-telegram-bot
requests openai python-dotenv pydantic pydantic-settings

# Additional libraries added this session
marshmallow google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

---

## API Endpoints Available

### Working Endpoints
- `GET /health` - Returns application health status

### Broken Endpoints (415 UnsupportedMediaType)
```
POST /api/nlp/process
POST /api/tasks
GET  /api/tasks/user/<user_id>
POST /api/tasks/<task_id>/complete
POST /api/field-reports
GET  /api/field-reports/site/<site_id>
GET  /api/sites
GET  /api/sites/search
POST /api/business/markup-calculation/<invoice_id>
GET  /api/business/financial-summary/site/<site_id>
GET  /api/business/outstanding-billings
POST /api/integrations/todoist/sync
POST /api/integrations/google-drive/create-sop
POST /api/database/raw-query
GET  /api/test/database-connection
```

---

## Debugging Information

### Error Analysis
The 415 error suggests Flask is trying to parse JSON data when it shouldn't be. Key investigation areas:

1. **Request Middleware**: Check for global `before_request` handlers forcing JSON parsing
2. **Blueprint Middleware**: Examine middleware in `/api` blueprint specifically
3. **Decorator Issues**: Investigate `@validate_json_request` and `@handle_api_errors` decorators
4. **Flask Configuration**: Review Flask app configuration for JSON-related settings

### Files to Investigate
```
app/handlers/api_handler.py          # API endpoints and decorators
app/__init__.py                      # Flask app initialization and middleware
config/settings.py                   # Configuration that might affect request handling
```

### Test Commands
```bash
# Test working endpoint
curl -s http://127.0.0.1:5001/health

# Test broken endpoints
curl -s http://127.0.0.1:5001/api/test/database-connection
curl -s http://127.0.0.1:5001/api/sites

# Test with JSON header (still fails)
curl -s -H "Content-Type: application/json" http://127.0.0.1:5001/api/sites
```

### Potential Solutions to Try
1. **Remove JSON requirement**: Modify decorators to not require JSON on GET requests
2. **Conditional JSON parsing**: Only parse JSON when Content-Type is actually JSON
3. **Decorator order**: Change order of `@validate_json_request` and `@handle_api_errors`
4. **Middleware debugging**: Add logging to identify where the 415 error originates

---

## Next Steps Priority Order

### 🔥 Immediate Priority
1. **Fix API Endpoints**: Debug and resolve the 415 UnsupportedMediaType issue
   - Start with simple GET endpoints like `/api/test/database-connection`
   - Focus on `app/handlers/api_handler.py` middleware
   - Test decorator behavior and request processing flow

### 🎯 Once API Fixed
2. **Database Testing**: Verify CRUD operations through API endpoints
3. **Telegram Integration**: Configure webhook and test bot functionality  
4. **NLP Testing**: Test intent classification and processing
5. **External API Testing**: Verify Todoist and Google Drive integrations
6. **Performance Testing**: Load testing and optimization
7. **Deployment Prep**: Staging environment setup

---

## Development Context

### Project Architecture
- **Database**: Supabase PostgreSQL with 28 tables and business logic functions
- **Backend**: Flask with modular service architecture
- **Integration**: Telegram bot + REST API for Noloco web interface
- **External APIs**: OpenAI, Todoist, Google Drive

### Previous Phases Completed
- **Phase 1**: Database schema implementation and verification ✅
- **Phase 2**: Flask backend development and integration ✅
- **Phase 3**: Currently in backend testing phase

### Documentation
- **Development Log**: `DEV_LOG.md` (comprehensive project history)
- **Architecture**: Documented in dev log with technical specifications
- **Configuration**: Environment variables and settings documented

---

## Quick Start for Next Developer

```bash
# 1. Navigate to backend directory
cd /Users/colinaulds/Desktop/projects/10NZ_FLRTS/backend

# 2. Activate virtual environment
source venv/bin/activate

# 3. Start Flask backend
python app.py

# 4. Test health endpoint (should work)
curl http://127.0.0.1:5001/health

# 5. Test API endpoint (currently broken)
curl http://127.0.0.1:5001/api/test/database-connection

# 6. Debug the 415 UnsupportedMediaType error
# Focus on app/handlers/api_handler.py decorators and middleware
```

---

## Resources
- **Development Log**: `DEV_LOG.md` - Complete project history and context
- **MCP Integration**: API keys managed through 1Password and MCP environment
- **Database Schema**: Fully implemented and tested in previous phases
- **Service Architecture**: All backend services implemented and tested individually

**Note**: The backend infrastructure is solid and ready for testing. The API endpoint issue is likely a simple middleware configuration that needs debugging and resolution.