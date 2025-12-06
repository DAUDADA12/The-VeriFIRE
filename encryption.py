import os
import json
import re
import secrets
import string
from cryptography.fernet import Fernet
from typing import Dict, Any, Optional

KEY_FILE = "fernet_secret.key"

# unique id length
ID_LENGTH = 25 

def ensure_and_load_key() -> bytes:
    # ensures a fernet key exists, generates one if missing, and loads it
    if os.path.exists(KEY_FILE):
        with open(KEY_FILE, "rb") as key_file:
            key = key_file.read()
        print(f"Key loaded successfully from '{KEY_FILE}'.")
        return key
    else:
        # generate and save a new key (only happens once!) NOTE: NEEDS TO BE KEPT SAFE, KEEP BACKUP FILE OF KEY
        key = Fernet.generate_key()
        with open(KEY_FILE, "wb") as key_file:
            key_file.write(key)
        print(f"New Fernet key generated and saved to '{KEY_FILE}'.")
        print("KEEP THIS FILE SAFE AND DO NOT CHANGE IT!")
        return key

def generate_unique_id(first_name: str, last_name: str) -> str:
    
    # generates a unique ID in a specific format
    # if user's name is Saumy Kakkad, unique id would be:
    # SAU[ 25 random characters (numbers, alphabets, special characters) ]KAD
    
    first_part = first_name[:3].upper()
    last_part = last_name[-3:].upper()
    characters = string.ascii_letters + string.digits + '!@#$^*()_+-='
    random_part = ''.join(secrets.choice(characters) for _ in range(ID_LENGTH))
    unique_id = f"{first_part}{random_part}{last_part}"
    
    return unique_id

def get_user_data() -> Dict[str, Any]:
    # gathers user data via cli
    print("\nData Collection")
    
    while True:
        country_code = input("Enter Country Code (e.g., +91): ")
        if re.match(r"^\+\d{1,4}$", country_code): 
            break
        print("Invalid format. Please enter the country code starting with '+' followed by 1 to 4 digits.")
        
    phone_number_body = input("Enter Phone Number (without country code): ")
    phone_number = f"{country_code}{phone_number_body.replace(' ', '').replace('-', '')}"
    
    first_name = input("Enter First Name: ")
    last_name = input("Enter Last Name: ")
    middle_name_input = input("Enter Middle Name (optional, press Enter to skip): ")
    middle_name: Optional[str] = middle_name_input if middle_name_input else None
    
    # only encrypting id number to keep it simple for now, for database storage as per atharv's request
    # will encrypt other data in future updates for extra security
    government_id = input("Enter Government ID Number (string): ")

    unique_id = generate_unique_id(first_name, last_name)
    print(f"Generated Unique ID: {unique_id}")

    # structure the data into a dictionary ('user_data' must NOT be deleted)
    user_data = {
        "Phone Number": phone_number,
        "Name": {
            "First": first_name,
            "Middle": middle_name,
            "Last": last_name
        },
        "Unique ID": unique_id,         
        "Government ID": government_id  
    }
    return user_data


def encrypt_data_string(data_string: str, fernet: Fernet) -> str: 
    data_bytes = data_string.encode('utf-8')
    encrypted_bytes = fernet.encrypt(data_bytes)
    encrypted_string = encrypted_bytes.decode('utf-8')
    return encrypted_string


def decrypt_data_string(encrypted_string: str, fernet: Fernet) -> Optional[str]:
    # decrypts the stored string back into the original data string
    try:
        encrypted_bytes = encrypted_string.encode('utf-8')
        decrypted_bytes = fernet.decrypt(encrypted_bytes)
        decrypted_data = decrypted_bytes.decode('utf-8')
        return decrypted_data
    except Exception as e:
        # if this fails, the key or the data is wrong/corrupted
        print(f"\nDecryption failed! Reason: {e}")
        return None

def main():
    # ensures the existence of key and loads it
    key = ensure_and_load_key()
    fernet = Fernet(key)
    
    print("\n Government ID Encryption")
    
    # get user's details and both IDs
    user_record = get_user_data()
    
    original_govt_id = user_record["Government ID"]
    encrypted_govt_id = encrypt_data_string(original_govt_id, fernet)
    
    firebase_record = user_record.copy()
    firebase_record["Government ID"] = encrypted_govt_id
    
    print("\nEncryption successful!")
    print(f"Original Government ID: {original_govt_id}")
    print(f"Encrypted Government ID: {encrypted_govt_id[:40]}... (Total length: {len(encrypted_govt_id)})")
    
    print("\n Data Sent to Firebase (Simulated)")
    print(f"JSON Payload for Firebase:\n{json.dumps(firebase_record, indent=4)}")
    
    
    print("\n Decryption (Simulated Retrieval from Firebase)")
    
    retrieved_encrypted_id = firebase_record["Government ID"]
    
    # decrypt
    decrypted_govt_id = decrypt_data_string(retrieved_encrypted_id, fernet)
    
    if decrypted_govt_id:
        print("Decryption successful!")
        print(f"Decrypted Government ID: {decrypted_govt_id}")
        # verification check
        print(f"Verification: {'Match!' if decrypted_govt_id == original_govt_id else 'Mismatch!'}")

if __name__ == "__main__":
    main()
