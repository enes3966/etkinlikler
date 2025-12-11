from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.session import Base
import datetime

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(String, nullable=False)       # Mesajın içeriği
    timestamp = Column(DateTime, default=datetime.datetime.utcnow) # Ne zaman atıldı?

    # Gönderen Kişi
    sender_id = Column(Integer, ForeignKey("users.id"))
    
    # Alıcı Kişi (Kime gönderildi?)
    receiver_id = Column(Integer, ForeignKey("users.id"))

    # İlişkiler (Veritabanı bağlantıları)
    # foreign_keys ile hangi sütunun kullanıldığını özellikle belirtiyoruz
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])