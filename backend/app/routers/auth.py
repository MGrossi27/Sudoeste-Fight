
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime
import hashlib
from app.core.database import get_db
from app.models.models import Usuario
router = APIRouter(prefix="/auth", tags=["Autenticação"])
class LoginRequest(BaseModel):
    username: str
    senha: str
class LoginResponse(BaseModel):
    sucesso: bool
    mensagem: str
    usuario: dict | None = None
class UsuarioResponse(BaseModel):
    id_usuario: int
    username: str
    nome_completo: str | None
    email: str | None
    ativo: bool
@router.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    print(f" [LOGIN] Tentativa de login: username='{request.username}'")
    usuario = db.query(Usuario).filter(Usuario.username == request.username).first()
    if not usuario:
        print(f" [LOGIN] Usuário '{request.username}' não encontrado")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário ou senha incorretos"
        )
    print(f" [LOGIN] Usuário encontrado: id={usuario.id_usuario}, ativo={usuario.ativo}")
    if not usuario.ativo:
        print(f" [LOGIN] Usuário '{request.username}' está inativo")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo"
        )
    senha_hash = hashlib.sha256(request.senha.encode()).hexdigest()
    print(f"� [LOGIN] Hash recebido: {senha_hash}")
    print(f"� [LOGIN] Hash no banco:  {usuario.senha_hash}")
    if senha_hash != usuario.senha_hash:
        print(f" [LOGIN] Senha incorreta para '{request.username}'")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário ou senha incorretos"
        )
    print(f" [LOGIN] Senha correta! Login bem-sucedido para '{request.username}'")
    usuario.ultimo_acesso = datetime.now()
    db.commit()
    return LoginResponse(
        sucesso=True,
        mensagem="Login realizado com sucesso",
        usuario={
            "id_usuario": usuario.id_usuario,
            "username": usuario.username,
            "nome_completo": usuario.nome_completo,
            "email": usuario.email,
            "ativo": usuario.ativo
        }
    )
@router.get("/usuarios", response_model=list[UsuarioResponse])
def listar_usuarios(db: Session = Depends(get_db)):
    usuarios = db.query(Usuario).all()
    return usuarios
@router.get("/validar/{username}")
def validar_usuario(username: str, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.username == username).first()
    if not usuario:
        return {"existe": False, "ativo": False}
    return {
        "existe": True,
        "ativo": usuario.ativo,
        "nome_completo": usuario.nome_completo
    }
