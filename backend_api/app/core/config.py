from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Proje Genel Ayarları
    PROJECT_NAME: str
    API_V1_STR: str = "/api/v1"
    
    # Güvenlik
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    
    # Veritabanı
    DATABASE_URL: str

    class Config:
        case_sensitive = True
        env_file = ".env"
        # İŞTE SİHİRLİ SATIR BURASI:
        extra = "ignore" 
        # (Bu satır sayesinde .env içindeki fazladan değişkenlere kızmayacak)

# Ayarları başlatıyoruz
settings = Settings()