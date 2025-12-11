from pydantic import BaseModel
from datetime import datetime

# Mesaj gönderirken (Sadece kime ve ne gönderdiği lazım)
class MessageCreate(BaseModel):
    receiver_id: int
    content: str

# Mesajı okurken (Kimden geldiği ve zamanı da lazım)
class MessageResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    content: str
    timestamp: datetime

    class Config:
        from_attributes = True