import os

from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.database import get_db
from src.db.models import ItemImage

router = APIRouter(tags=["images"])


@router.get("/api/images/{image_id}")
async def api_get_image(image_id: str, db: AsyncSession = Depends(get_db)):
    import uuid as uuid_pkg
    try:
        parsed = uuid_pkg.UUID(image_id)
    except Exception:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST) from None

    result = await db.execute(select(ItemImage).where(ItemImage.id == parsed))
    image = result.scalar_one_or_none()
    if image is None:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    parts = image.original_name.rsplit(".", 1)
    ext_map = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    ext = ext_map.get(parts[-1].lower() if len(parts) > 1 else "", "jpg")
    filepath = os.path.join(settings.uploads_dir, f"{image_id}.{ext}")

    if not os.path.exists(filepath):
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    return FileResponse(filepath, media_type=image.mime_type)
