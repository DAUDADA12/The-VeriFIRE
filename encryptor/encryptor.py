import os
import json
from cryptography.fernet import Fernet 
from typing import Dict, Any, Optional

KEY_FILE = "fernet_secret.key"

def ensure_and_load_key() -> bytes:
    # ensures a fernet key exists, generates one if missing, and loads it
    if os.path.exists(KEY_FILE):
        # load existing key
        with open(KEY_FILE, "rb") as key_file:
            key = key_file.read()
        print(f"Key loaded successfully from '{KEY_FILE}'.")
        return key
    else:
        # generate and save a new key (only happens once!!!!!!!!!!!!!!!!!!!) NEEDS TO BE KEPT SAFE, KEEP BACKUP FILE OF KEY
        key = Fernet.generate_key()
        with open(KEY_FILE, "wb") as key_file:
            key_file.write(key)
        print(f"New Fernet key generated and saved to '{KEY_FILE}'.")
        print("KEEP THIS FILE SAFE AND DO NOT CHANGE IT!")
        return key

def get_user_data() -> Dict[str, Any]:
    # gathers user data via command line input
    print("\nData Collection")
    
    email = input("Enter your Email ID: ")
    first_name = input("Enter First Name: ")
    last_name = input("Enter Last Name: ")
    
    middle_name_input = input("Enter Middle Name (optional, press Enter to skip): ")
    middle_name: Optional[str] = middle_name_input if middle_name_input else None

    # age verification loop
    while True:
        try:
            age = int(input("Enter Age: "))
            if age < 0:
                 raise ValueError
            break
        except ValueError:
            print("Invalid age. Please enter a positive whole number.")

    id_number = input("Enter ID Number (string): ")
    
    # structure the data into a dictionary (optional return for verification, but DO NOT DELETE "user_data" var, EMPHASIS ON THE DO NOT)
    user_data = {
        "Email ID": email,
        "Name": {
            "First": first_name,
            "Middle": middle_name,
            "Last": last_name
        },
        "Age": age,
        "ID Number": id_number
    }
    return user_data

def encrypt_record(record: Dict[str, Any], fernet: Fernet) -> str:
    # converts a py dictionary to json, encrypts it, and returns the result as a storable string (Base64) suitable for Firebase.
    json_string = json.dumps(record)
    data_bytes = json_string.encode('utf-8')
    encrypted_bytes = fernet.encrypt(data_bytes)
    encrypted_string = encrypted_bytes.decode('utf-8')
    
    return encrypted_string


def decrypt_record(encrypted_string: str, fernet: Fernet) -> Optional[Dict[str, Any]]:
    # takes encrypted string from db, converts into bytes, decrypts, and loads into a py dictionary
    try:
        encrypted_bytes = encrypted_string.encode('utf-8')
        decrypted_bytes = fernet.decrypt(encrypted_bytes)
        json_string = decrypted_bytes.decode('utf-8')
        decrypted_data = json.loads(json_string)
        return decrypted_data
    except Exception as e:
        # if this fails, the key or the data is wrong/corrupted
        print(f"\nDecryption failed! Reason: {e}")
        return None

def main():
    # ensures the existence of key
    key = ensure_and_load_key()
    fernet = Fernet(key)
    
    print("\n Encryption")
    
    # get user's details; name (full; first, middle, last), email, age, id number
    user_record = get_user_data()
    
    # encrypt 
    encrypted_record = encrypt_record(user_record, fernet)
    
    print("\nEncryption successful!")
    print(f"Original Record (JSON): {json.dumps(user_record)}")
    print(f"Encrypted Record (Bytes): {encrypted_record[:40]}... (Total length: {len(encrypted_record)})")
    
    
    print("\n Decryption")
    
    # decrypt
    decrypted_record = decrypt_record(encrypted_record, fernet)
    
    if decrypted_record:
        print("Decryption successful!")
        print(f"Decrypted Data Structure:\n{json.dumps(decrypted_record, indent=4)}")

if __name__ == "__main__":
    main()