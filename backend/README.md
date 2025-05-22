# 10NetZero-FLRTS Backend

Python Flask backend for the 10NetZero Field Reports, Lists, Reminders, Tasks, and Subtasks (FLRTS) system.

## Overview

The Flask backend serves as the central nervous system for intelligent processing, integrations, and interactions. It provides:

- **Telegram Bot Interface**: Natural language processing for field technicians
- **NLP Orchestration**: Intent classification and routing to appropriate services
- **Database Integration**: Comprehensive Supabase PostgreSQL client
- **External API Integration**: Todoist, OpenAI, Google Drive
- **Business Logic**: FLRTS CRUD operations and markup calculations
- **REST API**: Endpoints for Noloco and other integrations

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Telegram Bot   │    │   Noloco Web    │    │  External APIs  │
│   Interface     │    │   Interface     │    │ (Todoist, etc.) │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼───────────────┐
                    │       Flask Backend        │
                    │                            │
                    │  ┌─────────────────────┐   │
                    │  │   NLP Service       │   │
                    │  │ Intent Classification│   │
                    │  └─────────────────────┘   │
                    │                            │
                    │  ┌─────────────────────┐   │
                    │  │ Database Client     │   │
                    │  │ (Supabase/PostgreSQL)│   │
                    │  └─────────────────────┘   │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │     Supabase Database      │
                    │    (Single Source of Truth) │
                    └─────────────────────────────┘
```

## Quick Start

### 1. Environment Setup

```bash
# Clone and navigate to backend directory
cd backend

# Copy environment template
cp .env.template .env

# Edit .env with your configuration
# Required: SUPABASE_URL, SUPABASE_KEY, POSTGRES_PASSWORD, TELEGRAM_BOT_TOKEN
```

### 2. Installation and Startup

```bash
# Run startup script (handles everything)
./startup.sh
```

Or manually:

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start development server
python3 app.py
```

### 3. Verify Installation

```bash
# Check health endpoint
curl http://localhost:5000/health

# Check detailed status
curl http://localhost:5000/status
```

## Configuration

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `FLASK_SECRET_KEY` | Flask session secret | `your-secret-key` |
| `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_KEY` | Supabase anon key | `eyJ...` |
| `POSTGRES_PASSWORD` | Database password | `your-db-password` |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | `123:ABC...` |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for NLP | None |
| `TODOIST_API_TOKEN` | Todoist integration | None |
| `GOOGLE_API_KEY` | Google Drive integration | None |
| `ENVIRONMENT` | deployment environment | `development` |
| `LOG_LEVEL` | Logging level | `INFO` |

## API Endpoints

### Health & Status
- `GET /health` - Simple health check
- `GET /status` - Detailed status with component checks

### Telegram Integration
- `POST /telegram/webhook` - Telegram webhook endpoint
- `POST /telegram/set_webhook` - Configure webhook
- `GET /telegram/webhook_info` - Webhook status

### FLRTS Operations
- `POST /api/nlp/process` - Process natural language input
- `POST /api/tasks` - Create task
- `GET /api/tasks/user/<user_id>` - Get user tasks
- `POST /api/tasks/<task_id>/complete` - Complete task
- `POST /api/field-reports` - Create field report
- `GET /api/field-reports/site/<site_id>` - Get site reports

### Business Logic
- `POST /api/business/markup-calculation/<invoice_id>` - Execute markup calculation
- `GET /api/business/financial-summary/site/<site_id>` - Get financial summary
- `GET /api/business/outstanding-billings` - Get outstanding billings

## Development

### Project Structure

```
backend/
├── app/                    # Main application package
│   ├── __init__.py        # Flask app factory
│   ├── handlers/          # Request handlers
│   │   ├── telegram_handler.py  # Telegram bot logic
│   │   └── api_handler.py       # REST API endpoints
│   └── services/          # Business logic services
│       ├── database_client.py   # Supabase/PostgreSQL client
│       ├── nlp_service.py       # NLP orchestration
│       └── external_apis.py     # External API integrations
├── config/
│   └── settings.py        # Configuration management
├── requirements.txt       # Python dependencies
├── app.py                # Development entry point
├── wsgi.py               # Production WSGI entry point
└── startup.sh            # Development startup script
```

### Adding New Features

1. **New API Endpoints**: Add to `app/handlers/api_handler.py`
2. **New Services**: Create in `app/services/`
3. **Database Operations**: Extend `app/services/database_client.py`
4. **NLP Intents**: Add to `app/services/nlp_service.py`

### Testing

```bash
# Install test dependencies
pip install pytest pytest-flask

# Run tests
pytest tests/

# Run with coverage
pytest --cov=app tests/
```

## Deployment

### Production with Gunicorn

```bash
# Install Gunicorn
pip install gunicorn

# Start production server
gunicorn --bind 0.0.0.0:5000 --workers 4 wsgi:application
```

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:application"]
```

### Environment Variables for Production

Set `ENVIRONMENT=production` and ensure:
- `FLASK_DEBUG=false`
- Strong `FLASK_SECRET_KEY`
- Restricted `CORS_ORIGINS`
- All required API keys configured

## Integration with Other Components

### Telegram Bot Setup

1. Create bot with @BotFather
2. Set `TELEGRAM_BOT_TOKEN` in environment
3. Configure webhook: `POST /telegram/set_webhook`

### Noloco Integration

Connect Noloco to Supabase database directly. The backend provides supplementary API endpoints for operations not supported by Noloco.

### MCP Integration

The backend works with the MCP (Model Context Protocol) servers configured in the project. Ensure MCP servers are running before starting the backend.

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check `POSTGRES_PASSWORD` in `.env`
   - Verify Supabase project settings
   - Test connection: `curl http://localhost:5000/api/test/database-connection`

2. **Telegram Bot Not Responding**
   - Verify `TELEGRAM_BOT_TOKEN`
   - Check webhook configuration
   - Review logs for error messages

3. **NLP Processing Errors**
   - Ensure `OPENAI_API_KEY` is set (optional but recommended)
   - Check API quotas and limits
   - Fallback pattern matching works without OpenAI

### Logs

- Application logs: `logs/flrts_backend.log`
- Console output shows real-time activity
- Set `LOG_LEVEL=DEBUG` for detailed logging

## Support

For issues and questions:
1. Check the logs for error details
2. Verify configuration against this README
3. Test individual components using the API endpoints
4. Review the system design document for architecture details