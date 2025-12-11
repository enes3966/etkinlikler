from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.session import Base
import datetime

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False) # Etkinlik Başlığı
    description = Column(String)                       # Açıklama
    
    # Zaman
    date_time = Column(DateTime, default=datetime.datetime.utcnow) # Ne zaman?

    # Konum (Harita için koordinatlar)
    latitude = Column(Float)  # Enlem (Örn: 39.9207)
    longitude = Column(Float) # Boylam (Örn: 32.8541)

    # İlişki: Bu etkinliği kim oluşturdu?
    # users tablosunun id'sine bağlanıyoruz (Foreign Key)
    organizer_id = Column(Integer, ForeignKey("users.id"))

    # Kod yazarken kolaylık olsun diye ilişki tanımı
    # event.organizer dediğimizde direkt kullanıcı bilgilerini getirecek.
    organizer = relationship("User")