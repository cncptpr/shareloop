import asyncio
from collections import defaultdict

from fastapi import WebSocket


class NotificationRegistry:
    def __init__(self):
        self._connections: dict[int, set[WebSocket]] = defaultdict(set)
        self._lock = asyncio.Lock()

    async def register(self, user_id: int, ws: WebSocket):
        async with self._lock:
            self._connections[user_id].add(ws)

    async def unregister(self, user_id: int, ws: WebSocket):
        async with self._lock:
            self._connections[user_id].discard(ws)
            if not self._connections[user_id]:
                del self._connections[user_id]

    async def notify(self, user_id: int, payload: str):
        async with self._lock:
            connections = list(self._connections.get(user_id, set()))
        for ws in connections:
            try:
                await ws.send_text(payload)
            except Exception:
                pass


registry = NotificationRegistry()
