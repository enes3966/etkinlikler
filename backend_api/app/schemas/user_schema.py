from pydantic import BaseModel, EmailStr
from typing import Optional

# Temel Kalıp (Ortak özellikler)
class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    is_active: Optional[bool] = True

# Kayıt olurken istenecek veriler (Şifre şart)
class UserCreate(UserBase):
    password: str

# Kullanıcıya geri döndüreceğimiz veri (Şifreyi GİZLİYORUZ)
class UserResponse(UserBase):
    id: int
    is_superuser: bool

    class Config:
        from_attributes = True