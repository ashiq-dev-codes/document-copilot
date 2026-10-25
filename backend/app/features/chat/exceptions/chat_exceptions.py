"""Chat errors the app can receive."""

from fastapi import HTTPException, status


class ThreadNotFound(HTTPException):
    def __init__(self) -> None:
        super().__init__(status.HTTP_404_NOT_FOUND, "Conversation not found")


class ThreadForbidden(HTTPException):
    def __init__(self) -> None:
        super().__init__(status.HTTP_403_FORBIDDEN, "This conversation isn't yours")
