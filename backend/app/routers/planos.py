from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.models import Plano, Modalidade, PlanoModalidade
from app.schemas.plano import (
    PlanoComModalidades,
    PlanoListResponse,
    ModalidadeResponse
)
router = APIRouter(
    prefix="/planos",
    tags=["Planos"],
)
@router.get("/", response_model=List[PlanoListResponse], summary="Listar planos")
async def listar_planos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db)
):
    planos = db.query(Plano).offset(skip).limit(limit).all()
    result = []
    for plano in planos:
        qtd_modalidades = db.query(PlanoModalidade).filter(
            PlanoModalidade.id_plano == plano.id_plano
        ).count()
        result.append({
            "id_plano": plano.id_plano,
            "nome": plano.nome,
            "preco_mensal": plano.preco_mensal,
            "qtd_modalidades": qtd_modalidades
        })
    return result
@router.get("/{id_plano}", response_model=PlanoComModalidades, summary="Buscar plano")
async def buscar_plano(
    id_plano: int,
    db: Session = Depends(get_db)
):
    plano = db.query(Plano).filter(Plano.id_plano == id_plano).first()
    if not plano:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Plano {id_plano} nÃ£o encontrado"
        )
    modalidades = db.query(Modalidade)\
        .join(PlanoModalidade)\
        .filter(PlanoModalidade.id_plano == id_plano)\
        .all()
    return {
        "id_plano": plano.id_plano,
        "nome": plano.nome,
        "descricao": plano.descricao,
        "preco_mensal": plano.preco_mensal,
        "modalidades": modalidades
    }
@router.get("/modalidades/", response_model=List[ModalidadeResponse], summary="Listar modalidades")
async def listar_modalidades(
    db: Session = Depends(get_db)
):
    modalidades = db.query(Modalidade).all()
    return modalidades
@router.get("/{id_plano}/modalidades", response_model=List[ModalidadeResponse], summary="Modalidades do plano")
async def listar_modalidades_plano(
    id_plano: int,
    db: Session = Depends(get_db)
):
    plano = db.query(Plano).filter(Plano.id_plano == id_plano).first()
    if not plano:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Plano {id_plano} nÃ£o encontrado"
        )
    modalidades = db.query(Modalidade)\
        .join(PlanoModalidade)\
        .filter(PlanoModalidade.id_plano == id_plano)\
        .all()
    return modalidades
