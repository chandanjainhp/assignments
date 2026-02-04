from jupyter_server.auth import passwd
from jupyter_server.auth.security import passwd_check

password = 'openoa'
# The hash currently in config
hash_val = 'argon2:$argon2id$v=19$m=10240,t=10,p=8$OIuzuNPEM3yFy8dYIsiTDA$sLWYlQTTAgYqalrPRhKuCvkYG+FjnFdnd5uPCETXZmKs'

print(f"Checking if password '{password}' matches the hash...")
try:
    is_valid = passwd_check(hash_val, password)
    print(f"Match: {is_valid}")
except Exception as e:
    print(f"Error checking hash: {e}")
    is_valid = False

if not is_valid:
    print("Generating new hash...")
    new_hash = passwd(password)
    with open('/app/new_hash.txt', 'w') as f:
        f.write(new_hash)
    print("New hash written to /app/new_hash.txt")
