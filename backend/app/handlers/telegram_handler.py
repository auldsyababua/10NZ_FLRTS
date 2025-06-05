"""
10NetZero-FLRTS Telegram Bot Handler

This module implements the Telegram bot interface for field technicians to perform
rapid, low-friction CRUD operations on FLRTS items using typed natural language commands.

The Telegram bot serves as a crucial, direct interface that allows field technicians to:
- Create tasks and reminders using natural language
- Log field reports through narrative text input
- Add items to lists (shopping lists, tool inventories)
- Query their tasks and site information
- Perform basic updates and status changes

All interactions are processed through the NLP orchestration pipeline which routes
requests to appropriate services (Todoist, OpenAI LLM, database operations).
"""

import logging
import asyncio
from typing import Dict, Any, Optional
from datetime import datetime

from flask import Blueprint, request, jsonify
from telegram import Update, Bot
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

from config.settings import settings
from app.services.database_client import db_client
from app.services.nlp_service import nlp_service


# Create Flask blueprint for Telegram webhook endpoints
telegram_bp = Blueprint('telegram', __name__)

# Global bot instance
bot_application: Optional[Application] = None


class TelegramBotHandler:
    """
    Comprehensive Telegram bot handler for the 10NetZero-FLRTS system.
    
    Manages all Telegram bot interactions including command processing,
    natural language message handling, user authentication, and
    integration with the NLP orchestration pipeline.
    """
    
    def __init__(self):
        """Initialize the Telegram bot handler with configuration and logging."""
        self.logger = logging.getLogger(__name__)
        self.bot_token = settings.telegram_bot_token
        
        if not self.bot_token:
            raise ValueError("Telegram bot token must be configured")
        
        self.bot = Bot(token=self.bot_token)
        self.logger.info("Telegram bot handler initialized")
    
    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """
        Handle the /start command for new users.
        
        Provides welcome message and basic instructions for using the bot.
        Also attempts to link the Telegram user with an existing FLRTS user account.
        """
        user = update.effective_user
        chat_id = update.effective_chat.id
        
        self.logger.info(f"Start command from user {user.id} ({user.username})")
        
        # Check if user exists in FLRTS system
        flrts_user = db_client.get_user_by_telegram_id(str(user.id))
        
        if flrts_user:
            welcome_message = (
                f"Welcome back, {flrts_user['personnel']['first_name']}! 👋\\n\\n"
                f"I'm the 10NetZero FLRTS assistant. I can help you with:\\n\\n"
                f"📝 Create field reports\\n"
                f"✅ Manage tasks and reminders\\n"
                f"📋 Update lists and inventories\\n"
                f"🔍 Query your assignments\\n\\n"
                f"Just type what you need in natural language, and I'll help you out!"
            )
        else:
            welcome_message = (
                f"Hello {user.first_name}! 👋\\n\\n"
                f"I'm the 10NetZero FLRTS assistant, but I don't have you registered in our system yet.\\n\\n"
                f"Please contact your administrator to set up your FLRTS account and link it to this Telegram ID: `{user.id}`\\n\\n"
                f"Once you're registered, I'll be able to help you with field reports, tasks, and more!"
            )
        
        await context.bot.send_message(
            chat_id=chat_id,
            text=welcome_message,
            parse_mode='Markdown'
        )
    
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """
        Handle the /help command with detailed usage instructions.
        
        Provides comprehensive help information including examples of
        natural language commands for different FLRTS operations.
        """
        chat_id = update.effective_chat.id
        
        help_text = (
            "*10NetZero FLRTS Bot Help* 🤖\\n\\n"
            "*Field Reports:*\\n"
            f"• \"Field report Site Alpha: Generator running at 80% load, fuel levels good\"\\n"
            f"• \"Log incident at Site Beta: Noticed oil leak near pump 3\"\\n\\n"
            "*Tasks & Reminders:*\\n"
            f"• \"Remind me to call Anthony tomorrow at 2pm about the new controls\"\\n"
            f"• \"Create task: Check generator maintenance schedule for next week\"\\n\\n"
            "*Lists & Inventory:*\\n"
            f"• \"Add WD-40 and rags to the Site Alpha shopping list\"\\n"
            f"• \"Add backup hard drive to equipment inventory\"\\n\\n"
            "*Queries:*\\n"
            f"• \"What are my tasks for today?\"\\n"
            f"• \"Show me the Site Beta shopping list\"\\n"
            f"• \"What's my schedule this week?\"\\n\\n"
            "*Commands:*\\n"
            f"• /start - Get started\\n"
            f"• /help - Show this help\\n"
            f"• /status - Check your account status\\n\\n"
            f"Just type naturally - I'll understand what you need! 💪"
        )
        
        await context.bot.send_message(
            chat_id=chat_id,
            text=help_text,
            parse_mode='Markdown'
        )
    
    async def status_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """
        Handle the /status command to show user account information.
        
        Displays current user status, assigned sites, and recent activity.
        """
        user = update.effective_user
        chat_id = update.effective_chat.id
        
        self.logger.info(f"Status command from user {user.id}")
        
        # Get user information
        flrts_user = db_client.get_user_by_telegram_id(str(user.id))
        
        if not flrts_user:
            await context.bot.send_message(
                chat_id=chat_id,
                text="❌ You're not registered in the FLRTS system. Please contact your administrator."
            )
            return
        
        try:
            # Get user's primary site information
            primary_site = None
            if flrts_user['personnel']['primary_site_id']:
                sites = db_client.get_sites()
                primary_site = next((site for site in sites if site['id'] == flrts_user['personnel']['primary_site_id']), None)
            
            # Get recent tasks
            recent_tasks = db_client.get_tasks_for_user(flrts_user['id'])[:5]
            
            status_text = (
                f"*Your FLRTS Status* 📊\\n\\n"
                f"*Name:* {flrts_user['personnel']['first_name']} {flrts_user['personnel']['last_name']}\\n"
                f"*Role:* {flrts_user['user_role_flrts']}\\n"
                f"*User ID:* {flrts_user['user_id_display']}\\n"
            )
            
            if primary_site:
                status_text += f"*Primary Site:* {primary_site['site_name']}\\n"
            
            status_text += f"\\n*Recent Tasks:*\\n"
            
            if recent_tasks:
                for task in recent_tasks:
                    status_emoji = "✅" if task['status'] == 'Completed' else "🔄" if task['status'] == 'In Progress' else "📝"
                    status_text += f"{status_emoji} {task['task_title']}\\n"
            else:
                status_text += "No recent tasks found\\n"
            
            status_text += f"\\n_Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M')}_"
            
            await context.bot.send_message(
                chat_id=chat_id,
                text=status_text,
                parse_mode='Markdown'
            )
            
        except Exception as e:
            self.logger.error(f"Error in status command: {e}")
            await context.bot.send_message(
                chat_id=chat_id,
                text="❌ Sorry, I couldn't retrieve your status information right now. Please try again later."
            )
    
    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """
        Handle natural language messages from users.
        
        This is the core method that processes all non-command messages through
        the NLP orchestration pipeline. It handles:
        1. User authentication and validation
        2. Message preprocessing and intent classification
        3. Routing to appropriate service handlers
        4. Response generation and delivery
        """
        user = update.effective_user
        message = update.message
        chat_id = update.effective_chat.id
        
        if not message or not message.text:
            return
        
        user_input = message.text.strip()
        
        # Skip empty messages
        if not user_input:
            return
        
        self.logger.info(f"Message from user {user.id} ({user.username}): {user_input[:100]}")
        
        # Authenticate user
        flrts_user = db_client.get_user_by_telegram_id(str(user.id))
        
        if not flrts_user:
            await context.bot.send_message(
                chat_id=chat_id,
                text="❌ You're not registered in the FLRTS system. Please use /start and contact your administrator to get set up."
            )
            return
        
        # Check message length
        if len(user_input) > settings.max_message_length:
            await context.bot.send_message(
                chat_id=chat_id,
                text=f"❌ Message too long. Please keep messages under {settings.max_message_length} characters."
            )
            return
        
        try:
            # Send typing indicator
            await context.bot.send_chat_action(chat_id=chat_id, action="typing")
            
            # Process message through NLP service
            nlp_response = await nlp_service.process_user_input(
                user_input=user_input,
                user_context={
                    'flrts_user_id': flrts_user['id'],
                    'telegram_user_id': str(user.id),
                    'primary_site_id': flrts_user['personnel']['primary_site_id'],
                    'user_role': flrts_user['user_role_flrts'],
                    'full_name': f"{flrts_user['personnel']['first_name']} {flrts_user['personnel']['last_name']}"
                }
            )
            
            # Send response back to user
            response_text = nlp_response.get('response', 'I processed your request, but something went wrong generating a response.')
            
            # Add status indicators based on success
            if nlp_response.get('success', False):
                if nlp_response.get('action_taken'):
                    response_text = f"✅ {response_text}"
                else:
                    response_text = f"ℹ️ {response_text}"
            else:
                response_text = f"❌ {response_text}"
            
            await context.bot.send_message(
                chat_id=chat_id,
                text=response_text,
                parse_mode='Markdown' if nlp_response.get('use_markdown', False) else None
            )
            
            # Log successful processing
            self.logger.info(f"Successfully processed message from user {user.id}, action: {nlp_response.get('intent', 'unknown')}")
            
        except Exception as e:
            self.logger.error(f"Error processing message from user {user.id}: {e}")
            await context.bot.send_message(
                chat_id=chat_id,
                text="❌ Sorry, I encountered an error processing your request. Please try again or contact support if the problem persists."
            )
    
    async def error_handler(self, update: object, context: ContextTypes.DEFAULT_TYPE) -> None:
        """
        Handle errors in bot processing.
        
        Logs errors and sends appropriate error messages to users when possible.
        """
        self.logger.error(f"Bot error: {context.error}", exc_info=context.error)
        
        # Try to send error message to user if update contains chat info
        if isinstance(update, Update) and update.effective_chat:
            try:
                await context.bot.send_message(
                    chat_id=update.effective_chat.id,
                    text="❌ Sorry, something went wrong. Please try again in a moment."
                )
            except Exception as e:
                self.logger.error(f"Could not send error message to user: {e}")


# Global bot handler instance
telegram_handler = TelegramBotHandler()


async def initialize_bot_application():
    """
    Initialize the Telegram bot application with handlers.
    
    Sets up all command handlers, message handlers, and error handlers
    for the bot to function properly.
    """
    global bot_application
    
    if bot_application:
        return bot_application
    
    # Create application
    bot_application = Application.builder().token(settings.telegram_bot_token).build()
    
    # Add command handlers
    bot_application.add_handler(CommandHandler("start", telegram_handler.start_command))
    bot_application.add_handler(CommandHandler("help", telegram_handler.help_command))
    bot_application.add_handler(CommandHandler("status", telegram_handler.status_command))
    
    # Add message handler for natural language processing
    bot_application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, telegram_handler.handle_message))
    
    # Add error handler
    bot_application.add_error_handler(telegram_handler.error_handler)
    
    logging.getLogger(__name__).info("Telegram bot application initialized with handlers")
    return bot_application


@telegram_bp.route('/webhook', methods=['POST'])
def telegram_webhook():
    """
    Flask endpoint for receiving Telegram webhook updates.
    
    This endpoint receives updates from Telegram and processes them
    through the bot application. Used in production with webhook mode.
    """
    try:
        # Get update data from request
        update_data = request.get_json()
        
        if not update_data:
            return jsonify({'error': 'No update data provided'}), 400
        
        # Create Update object
        update = Update.de_json(update_data, telegram_handler.bot)
        
        if not update:
            return jsonify({'error': 'Invalid update data'}), 400
        
        # Process update asynchronously
        asyncio.create_task(process_telegram_update(update))
        
        return jsonify({'status': 'ok'})
        
    except Exception as e:
        logging.getLogger(__name__).error(f"Webhook error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


async def process_telegram_update(update: Update):
    """
    Process a Telegram update through the bot application.
    
    Args:
        update: Telegram Update object to process
    """
    try:
        # Initialize bot application if needed
        application = await initialize_bot_application()
        
        # Process the update
        await application.process_update(update)
        
    except Exception as e:
        logging.getLogger(__name__).error(f"Error processing Telegram update: {e}")


@telegram_bp.route('/set_webhook', methods=['POST'])
def set_telegram_webhook():
    """
    Flask endpoint to set up the Telegram webhook.
    
    This is used to configure the webhook URL with Telegram servers.
    Should be called once during deployment setup.
    """
    try:
        webhook_url = settings.telegram_webhook_url
        
        if not webhook_url:
            return jsonify({'error': 'Webhook URL not configured'}), 400
        
        # Set webhook with Telegram
        success = asyncio.run(telegram_handler.bot.set_webhook(
            url=f"{webhook_url}/telegram/webhook",
            secret_token=settings.telegram_webhook_secret
        ))
        
        if success:
            return jsonify({
                'status': 'success',
                'message': 'Webhook set successfully',
                'webhook_url': f"{webhook_url}/telegram/webhook"
            })
        else:
            return jsonify({'error': 'Failed to set webhook'}), 500
            
    except Exception as e:
        logging.getLogger(__name__).error(f"Error setting webhook: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@telegram_bp.route('/webhook_info', methods=['GET'])
def get_webhook_info():
    """
    Flask endpoint to get current webhook information.
    
    Returns the current webhook configuration from Telegram servers.
    Useful for debugging and verification.
    """
    try:
        webhook_info = asyncio.run(telegram_handler.bot.get_webhook_info())
        
        return jsonify({
            'webhook_url': webhook_info.url,
            'has_custom_certificate': webhook_info.has_custom_certificate,
            'pending_update_count': webhook_info.pending_update_count,
            'last_error_date': webhook_info.last_error_date.isoformat() if webhook_info.last_error_date else None,
            'last_error_message': webhook_info.last_error_message,
            'max_connections': webhook_info.max_connections,
            'allowed_updates': webhook_info.allowed_updates
        })
        
    except Exception as e:
        logging.getLogger(__name__).error(f"Error getting webhook info: {e}")
        return jsonify({'error': 'Internal server error'}), 500