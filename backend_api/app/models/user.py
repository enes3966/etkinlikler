from sqlalchemy import Column, Integer, String, Boolean
from app.db.session import Base

class User(Base):
    __tablename__ = "users"

    # Tablo Sütunları
    id = Column(Integer, primary_key=True, index=True) # Her kullanıcının eşsiz numarası (1, 2, 3...)
    full_name = Column(String, index=True)             # Adı Soyadı
    email = Column(String, unique=True, index=True, nullable=False) # E-posta (Eşsiz olmalı)
    hashed_password = Column(String, nullable=False)   # Şifre (Şifrelenmiş olarak saklanacak)
    is_active = Column(Boolean(), default=True)        # Hesap aktif mi? (Banlanmış mı?)
    is_superuser = Column(Boolean(), default=False)    # Yönetici mi?