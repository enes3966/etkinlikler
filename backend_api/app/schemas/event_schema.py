from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Temel Kalıp
class EventBase(BaseModel):
    title: str
    description: Optional[str] = None
    latitude: float
    longitude: float

# Etkinlik oluştururken istenecekler
class EventCreate(EventBase):
    pass # Base ile aynı

# Kullanıcıya gösterilecek veri
class EventResponse(EventBase):
    id: int
    organizer_id: int
    date_time: datetime

    class Config:
        from_attributes = True