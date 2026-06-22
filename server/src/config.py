from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgres://shareloop:shareloop@localhost:5432/shareloop"
    uploads_dir: str = "./uploads"
    max_body_limit: int = 1_048_576
    max_upload_limit: int = 10_485_760

    model_config = {"env_prefix": ""}


settings = Settings()
