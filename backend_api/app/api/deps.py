from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from app.core import config, security
from app.db.session import SessionLocal
from app.models.user import User

# Token'ın geleceği adres (/login endpointi)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{config.settings.API_V1_STR}/auth/login")

# 1. Veritabanı Oturumu Aç/Kapat (Her istek için)
def get_db() -> Generator:
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

# 2. Şu anki kullanıcıyı bul (Giriş yapmış mı?)
def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Giriş yapmanız gerekiyor.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # Token şifresini çöz
        payload = jwt.decode(
            token, 
            config.settings.SECRET_KEY, 
            algorithms=[security.ALGORITHM]
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Veritabanından kullanıcıyı bul
    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise credentials_exception
    return user