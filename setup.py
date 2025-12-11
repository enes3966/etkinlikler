import os

def create_project_structure():
    root_dir = "backend_api"
    
    # Klasör ve Dosya Yapısı Tanımlaması
    structure = {
        "": ["main.py", "requirements.txt", ".env", "README.md"],
        "app": ["__init__.py"],
        "app/core": ["__init__.py", "config.py", "security.py"],
        "app/db": ["__init__.py", "base.py", "session.py"],
        "app/models": ["__init__.py", "user.py", "event.py", "chat.py", "game.py"],
        "app/schemas": ["__init__.py", "user_schema.py", "event_schema.py", "chat_schema.py", "game_schema.py"],
        "app/api": ["__init__.py", "deps.py"],
        "app/api/v1": ["__init__.py"],
        "app/api/v1/endpoints": ["__init__.py", "auth.py", "events.py", "chat.py", "games.py"],
        "app/websockets": ["__init__.py", "connection_manager.py", "chat_socket.py", "game_socket.py"],
        "tests": ["__init__.py", "test_main.py"]
    }

    print(f"'{root_dir}' klasör yapısı oluşturuluyor...")

    for folder, files in structure.items():
        # Tam klasör yolunu oluştur
        current_path = os.path.join(root_dir, folder)
        
        # Klasörü yarat (varsa hata verme)
        os.makedirs(current_path, exist_ok=True)
        
        # Dosyaları yarat
        for file in files:
            file_path = os.path.join(current_path, file)
            with open(file_path, 'w', encoding='utf-8') as f:
                # requirements.txt içine temel paketleri yazalım ki kolaylık olsun
                if file == "requirements.txt":
                    f.write("fastapi\nuvicorn\nsqlalchemy\npsycopg2-binary\npython-multipart\npython-jose[cryptography]\npasslib[bcrypt]\nwebsockets\nredis\n")
                # main.py içine basit bir başlangıç kodu
                elif file == "main.py":
                    f.write("from fastapi import FastAPI\n\napp = FastAPI(title='SocialApp API')\n\n@app.get('/')\ndef read_root():\n    return {'message': 'API Calisiyor'}")
                else:
                    pass # Diğer dosyalar boş kalsın

    print(f"✅ Başarılı! '{root_dir}' klasörü tüm dosyalarıyla hazır.")

if __name__ == "__main__":
    create_project_structure()