from typing import Any
from fastapi import APIRouter, Depends
from app.api import deps
from app.schemas.user_schema import UserResponse
from app.models.user import User

router = APIRouter()

# "Ben Kimim?" (Profil Bilgilerimi Getir) Endpoint'i
@router.get("/me", response_model=UserResponse)
def read_user_me(
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Giriş yapmış kullanıcının profil bilgilerini getirir.
    """
    return current_user