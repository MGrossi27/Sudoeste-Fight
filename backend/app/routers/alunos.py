
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from datetime import date
from app.core.database import get_db
from app.models.models import Aluno, Inscricao
from app.schemas.aluno import (
    AlunoCreate,
    AlunoUpdate,
    AlunoResponse,
    AlunoListResponse
)
router = APIRouter(
    prefix="/alunos",
    tags=["Alunos"],
)
def gerar_matricula(db: Session) -> str:
    ultimo_aluno = db.query(Aluno).order_by(Aluno.matricula.desc()).first()
    if not ultimo_aluno:
        return "000001"
    try:
        proximo_numero = int(ultimo_aluno.matricula) + 1
        return str(proximo_numero).zfill(6)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao gerar matrícula"
        )
@router.get("/count", summary="Contar total de alunos")
async def contar_alunos(
    nome: Optional[str] = Query(None, description="Filtrar por nome ou matrícula"),
    ativo: Optional[bool] = Query(None, description="Filtrar por status ativo/inativo (baseado em inscrição ativa)"),
    db: Session = Depends(get_db)
):
    print(f"[COUNT] Parâmetros recebidos - nome: {nome}, ativo: {ativo} (tipo: {type(ativo)})")
    if ativo is not None:
        if ativo:
            query = db.query(func.count(func.distinct(Aluno.matricula)))\
                .join(Inscricao, Aluno.matricula == Inscricao.id_aluno)\
                .filter(Inscricao.status == "ativa")
        else:
            subquery = db.query(Inscricao.id_aluno)\
                .filter(Inscricao.status == "ativa")\
                .subquery()
            query = db.query(func.count(Aluno.matricula))\
                .filter(~Aluno.matricula.in_(subquery))
        if nome:
            search_term = f"%{nome}%"
            query = query.filter(
                (Aluno.nome_completo.ilike(search_term)) |
                (Aluno.matricula.ilike(search_term))
            )
        total = query.scalar()
    else:
        query = db.query(Aluno)
        if nome:
            search_term = f"%{nome}%"
            query = query.filter(
                (Aluno.nome_completo.ilike(search_term)) |
                (Aluno.matricula.ilike(search_term))
            )
        total = query.count()
    print(f"� [COUNT] Total encontrado: {total}")
    return {"total": total}
@router.get("/", response_model=List[AlunoListResponse], summary="Listar alunos")
async def listar_alunos(
    skip: int = Query(0, ge=0, description="Registros a pular"),
    limit: int = Query(100, ge=1, le=500, description="Limite de registros"),
    nome: Optional[str] = Query(None, description="Filtrar por nome ou matrícula"),
    ativo: Optional[bool] = Query(None, description="Filtrar por status ativo/inativo (baseado em inscrição ativa)"),
    db: Session = Depends(get_db)
):
    print(f"� [LIST] Parâmetros recebidos - skip: {skip}, limit: {limit}, nome: {nome}, ativo: {ativo} (tipo: {type(ativo)})")
    if ativo is not None:
        if ativo:
            query = db.query(Aluno)\
                .join(Inscricao, Aluno.matricula == Inscricao.id_aluno)\
                .filter(Inscricao.status == "ativa")\
                .distinct()
        else:
            subquery = db.query(Inscricao.id_aluno)\
                .filter(Inscricao.status == "ativa")\
                .subquery()
            query = db.query(Aluno)\
                .filter(~Aluno.matricula.in_(subquery))
    else:
        query = db.query(Aluno)
    if nome:
        search_term = f"%{nome}%"
        query = query.filter(
            (Aluno.nome_completo.ilike(search_term)) |
            (Aluno.matricula.ilike(search_term))
        )
    query = query.order_by(Aluno.matricula)
    alunos = query.offset(skip).limit(limit).all()
    print(f"[LIST] Total encontrado: {len(alunos)}")
    return alunos
@router.get("/{matricula}", response_model=AlunoResponse, summary="Buscar aluno")
async def buscar_aluno(
    matricula: str,
    db: Session = Depends(get_db)
):
    aluno = db.query(Aluno).filter(Aluno.matricula == matricula).first()
    if not aluno:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Aluno com matrícula {matricula} não encontrado"
        )
    return aluno
@router.post("/", response_model=AlunoResponse, status_code=status.HTTP_201_CREATED, summary="Criar aluno")
async def criar_aluno(
    aluno: AlunoCreate,
    db: Session = Depends(get_db)
):
    cpf_exists = db.query(Aluno).filter(Aluno.cpf == aluno.cpf).first()
    if cpf_exists:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"CPF {aluno.cpf} já cadastrado"
        )
    email_exists = db.query(Aluno).filter(Aluno.email == aluno.email).first()
    if email_exists:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Email {aluno.email} já cadastrado"
        )
    matricula = gerar_matricula(db)
    novo_aluno = Aluno(
        matricula=matricula,
        nome_completo=aluno.nome_completo,
        sexo=aluno.sexo,
        cpf=aluno.cpf,
        data_nascimento=aluno.data_nascimento,
        email=aluno.email,
        telefone=aluno.telefone,
        data_cadastro=date.today()
    )
    db.add(novo_aluno)
    db.commit()
    db.refresh(novo_aluno)
    return novo_aluno
@router.put("/{matricula}", response_model=AlunoResponse, summary="Atualizar aluno")
async def atualizar_aluno(
    matricula: str,
    aluno_update: AlunoUpdate,
    db: Session = Depends(get_db)
):
    aluno = db.query(Aluno).filter(Aluno.matricula == matricula).first()
    if not aluno:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Aluno com matrícula {matricula} não encontrado"
        )
    if aluno_update.email and aluno_update.email != aluno.email:
        email_exists = db.query(Aluno).filter(
            Aluno.email == aluno_update.email,
            Aluno.matricula != matricula
        ).first()
        if email_exists:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Email {aluno_update.email} já cadastrado"
            )
    if aluno_update.cpf and aluno_update.cpf != aluno.cpf:
        cpf_exists = db.query(Aluno).filter(
            Aluno.cpf == aluno_update.cpf,
            Aluno.matricula != matricula
        ).first()
        if cpf_exists:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"CPF {aluno_update.cpf} já cadastrado"
            )
    update_data = aluno_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(aluno, field, value)
    db.commit()
    db.refresh(aluno)
    return aluno
@router.delete("/{matricula}", status_code=status.HTTP_204_NO_CONTENT, summary="Excluir aluno")
async def excluir_aluno(
    matricula: str,
    db: Session = Depends(get_db)
):
    aluno = db.query(Aluno).filter(Aluno.matricula == matricula).first()
    if not aluno:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Aluno com matrícula {matricula} não encontrado"
        )
    db.delete(aluno)
    db.commit()
    return None
@router.get("/{matricula}/inscricoes", summary="Listar inscrições do aluno")
async def listar_inscricoes_aluno(
    matricula: str,
    db: Session = Depends(get_db)
):
    aluno = db.query(Aluno).filter(Aluno.matricula == matricula).first()
    if not aluno:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Aluno com matrícula {matricula} não encontrado"
        )
    inscricoes = db.query(Inscricao).filter(
        Inscricao.id_aluno == matricula
    ).all()
    resultado = []
    for inscricao in inscricoes:
        modalidades = [
            {
                "id_modalidade": im.modalidade.id_modalidade,
                "nome": im.modalidade.nome
            }
            for im in inscricao.inscricoes_modalidades
        ]
        resultado.append({
            "id_inscricao": inscricao.id_inscricao,
            "plano_nome": inscricao.plano.nome if inscricao.plano else None,
            "plano_preco": float(inscricao.plano.preco_mensal) if inscricao.plano else None,
            "data_inicio": inscricao.data_inicio.isoformat() if inscricao.data_inicio else None,
            "data_fim": inscricao.data_fim.isoformat() if inscricao.data_fim else None,
            "status": inscricao.status,
            "modalidades": modalidades
        })
    return resultado
