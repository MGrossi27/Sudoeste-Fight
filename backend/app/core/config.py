from pydantic_settings import BaseSettings
from urllib.parse import quote_plus
class Settings(BaseSettings):
    APP_NAME: str = "Sudoeste Fight API"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "API REST para Sistema de GestÃ£o de Academia"
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = True
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5436
    CORS_ORIGINS: list = [
        "http://localhost:8081",  # Frontend Expo
        "http://127.0.0.1:8081",
        "http://localhost:19006",  # Expo web alternative port
        "*",  # Permite todas as origens
    ]
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    @property
    def DATABASE_URL(self) -> str:
        password_encoded = quote_plus(self.POSTGRES_PASSWORD)
        return f"postgresql://{self.POSTGRES_USER}:{password_encoded}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
    @property
    def ASYNC_DATABASE_URL(self) -> str:
        password_encoded = quote_plus(self.POSTGRES_PASSWORD)
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{password_encoded}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
    class Config:
        env_file = ".env"
        case_sensitive = True
settings = Settings()
