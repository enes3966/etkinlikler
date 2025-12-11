from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api import deps
from app.models.event import Event
from app.models.user import User
from app.schemas.event_schema import EventCreate, EventResponse

router = APIRouter()

# 1. TÜM ETKİNLİKLERİ GETİR
@router.get("/", response_model=List[EventResponse])
def read_events(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    Sistemdeki etkinlikleri listeler.
    """
    events = db.query(Event).offset(skip).limit(limit).all()
    return events

# 2. ETKİNLİK DETAYI GETİR
@router.get("/{event_id}", response_model=EventResponse)
def read_event(
    event_id: int,
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Belirli bir etkinliğin detaylarını getirir.
    """
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Etkinlik bulunamadı")
    return event

# 3. YENİ ETKİNLİK OLUŞTUR
@router.post("/", response_model=EventResponse)
def create_event(
    *,
    db: Session = Depends(deps.get_db),
    event_in: EventCreate,
    current_user: User = Depends(deps.get_current_user), # Sadece giriş yapanlar oluşturabilir
) -> Any:
    """
    Yeni bir etkinlik oluşturur.
    """
    event = Event(
        title=event_in.title,
        description=event_in.description,
        latitude=event_in.latitude,
        longitude=event_in.longitude,
        organizer_id=current_user.id, # Oluşturan kişi şu anki kullanıcı
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event