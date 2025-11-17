from pydantic import BaseModel, Field, field_validator
from datetime import date
from typing import Optional
from decimal import Decimal
from app.models.models import StatusInscricaoEnum
class InscricaoBase(BaseModel):
    id_aluno: str = Field(..., pattern=r"^\d{6}$", description="Matrícula do aluno (6 dígitos)")
    id_plano: int = Field(..., gt=0, description="ID do plano")
    data_inicio: date = Field(..., description="Data de início da inscrição")
    @field_validator('data_inicio')
    @classmethod
    def validate_data_inicio(cls, v: date) -> date:
        if v.year < 2020:
            raise ValueError('Data de início inválida')
        return v
class InscricaoCreate(InscricaoBase):
    pass
class InscricaoUpdate(BaseModel):
    id_plano: Optional[int] = None
    status: Optional[StatusInscricaoEnum] = None
    data_fim: Optional[date] = None
class InscricaoResponse(InscricaoBase):
    id_inscricao: int
    data_fim: Optional[date] = None
    status: StatusInscricaoEnum
    class Config:
        from_attributes = True
class InscricaoDetalhada(BaseModel):
    id_inscricao: int
    aluno_nome: str
    aluno_matricula: str
    plano_nome: str
    plano_preco: Decimal
    data_inicio: date
    data_fim: Optional[date] = None
    status: StatusInscricaoEnum
    total_pagamentos: int = 0
    valor_pago: Decimal = Decimal("0.00")
    class Config:
        from_attributes = True
class InscricaoListResponse(BaseModel):
    id_inscricao: int
    aluno_nome: str
    aluno_matricula: str
    plano_nome: str
    data_inicio: date
    status: StatusInscricaoEnum
    class Config:
        from_attributes = True
