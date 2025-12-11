from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.api import deps
from app.core import security
from app.core.config import settings
from app.models.user import User
from app.schemas.user_schema import UserCreate, UserResponse, UserBase

router = APIRouter()

# 1. KAYIT OLMA (Sign Up)
@router.post("/signup", response_model=UserResponse)
def create_user(
    user_in: UserCreate,
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Yeni kullanıcı oluşturur.
    """
    # Bu email zaten var mı kontrol et
    user = db.query(User).filter(User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="Bu email adresi ile zaten kayıt olunmuş.",
        )
    
    # Yeni kullanıcı oluştur
    user = User(
        email=user_in.email,
        full_name=user_in.full_name,
        hashed_password=security.get_password_hash(user_in.password), # Şifreyi şifrele
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

# 2. GİRİŞ YAPMA (Login)
@router.post("/login")
def login_access_token(
    db: Session = Depends(deps.get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    Giriş yapar ve Access Token (Erişim Bileti) verir.
    """
    # Kullanıcıyı bul
    user = db.query(User).filter(User.email == form_data.username).first()
    
    # Şifre kontrolü
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Hatalı email veya şifre")
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Kullanıcı hesabı pasif.")

    # Token oluştur
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }