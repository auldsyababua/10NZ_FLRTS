import re

# Read the original file
with open('app/services/database_client.py', 'r') as f:
    content = f.read()

# Find and replace the supabase import
import_pattern = 'from supabase import create_client, Client'
new_import = 'from supabase import create_client, Client\nfrom supabase.client import ClientOptions'

content = content.replace(import_pattern, new_import)

# Find and replace the client creation
old_client = '''        self.supabase: Client = create_client(
            settings.supabase_url,
            settings.supabase_key
        )'''

new_client = '''        options = ClientOptions()
        self.supabase: Client = create_client(
            settings.supabase_url,
            settings.supabase_key,
            options=options
        )'''

content = content.replace(old_client, new_client)

# Write the fixed file
with open('app/services/database_client.py', 'w') as f:
    f.write(content)

print('Fixed Supabase client initialization')
