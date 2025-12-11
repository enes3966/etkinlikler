import requests
import json
import sys

url = "http://localhost:8080/api/v1/auth/signup"

demo_user = {
    "email": "demo@example.com",
    "password": "demo123",
    "full_name": "Demo Kullanici",
    "is_active": True
}

try:
    response = requests.post(url, json=demo_user)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        print("\n✅ Demo kullanici basariyla olusturuldu!")
        print(f"E-posta: {demo_user['email']}")
        print(f"Sifre: {demo_user['password']}")
    elif response.status_code == 400:
        print("\n⚠️ Kullanici zaten var olabilir.")
        print("Giris yapmayi deneyin:")
        print(f"E-posta: {demo_user['email']}")
        print(f"Sifre: {demo_user['password']}")
    else:
        print(f"\n⚠️ Hata: {response.status_code}")
        try:
            print(f"Response: {response.text}")
        except:
            pass
except Exception as e:
    print(f"Hata: {e}")

