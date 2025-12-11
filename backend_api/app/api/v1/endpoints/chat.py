from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api import deps
from app.models.chat import ChatMessage
from app.models.user import User
from app.schemas.chat_schema import MessageCreate, MessageResponse

router = APIRouter()

# 1. MESAJLARI GETİR (Genel grup mesajları için receiver_id = 0)
@router.get("/messages", response_model=List[MessageResponse])
def get_messages(
    receiver_id: int = 0,  # 0 = genel grup
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    Mesajları getirir. receiver_id = 0 ise genel grup mesajları.
    """
    if receiver_id == 0:
        # Genel grup mesajları (tüm mesajlar)
        messages = db.query(ChatMessage).offset(skip).limit(limit).order_by(ChatMessage.timestamp.desc()).all()
    else:
        # Belirli bir kullanıcıyla olan mesajlar
        messages = db.query(ChatMessage).filter(
            ((ChatMessage.sender_id == current_user.id) & (ChatMessage.receiver_id == receiver_id)) |
            ((ChatMessage.sender_id == receiver_id) & (ChatMessage.receiver_id == current_user.id))
        ).offset(skip).limit(limit).order_by(ChatMessage.timestamp.desc()).all()
    
    return messages

# 2. MESAJ GÖNDER
@router.post("/messages", response_model=MessageResponse)
def send_message(
    *,
    db: Session = Depends(deps.get_db),
    message_in: MessageCreate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Yeni bir mesaj gönderir.
    """
    message = ChatMessage(
        content=message_in.content,
        sender_id=current_user.id,
        receiver_id=message_in.receiver_id,
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message

