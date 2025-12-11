from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.api.v1.api import api_router
from app.db.session import engine, Base
# Modelleri içeri aktar ki tablolar oluşsun
from app import models 

# 1. Veritabanı Tablolarını Oluştur (Otomatik)
# Kod çalıştığında veritabanına bakacak, tablolar yoksa oluşturacak.
Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.PROJECT_NAME)

# 2. CORS Ayarları - EN ÜSTTE OLMALI
# Mobil uygulamanın veya başkalarının sunucuya erişebilmesi için izinler.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme aşamasında herkese izin ver
    allow_credentials=False,  # allow_origins=["*"] ile credentials kullanılamaz
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# OPTIONS istekleri için özel handler
@app.options("/{full_path:path}")
async def options_handler(full_path: str):
    return JSONResponse(
        content={},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS, PATCH",
            "Access-Control-Allow-Headers": "*",
        }
    )

# 3. Rotaları (Endpointleri) Tanımla
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {"message": "SocialApp API Çalışıyor! Hoşgeldin Oğuz."}