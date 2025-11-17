from pydantic import BaseModel, Field
from typing import List, Optional
from decimal import Decimal
class ModalidadeBase(BaseModel):
    nome: str = Field(..., min_length=3, max_length=100)
class ModalidadeResponse(ModalidadeBase):
    id_modalidade: int
    class Config:
        from_attributes = True
class PlanoBase(BaseModel):
    nome: str = Field(..., min_length=3, max_length=100)
    descricao: Optional[str] = None
    preco_mensal: Decimal = Field(..., gt=0, description="Preço mensal maior que zero")
class PlanoResponse(PlanoBase):
    id_plano: int
    class Config:
        from_attributes = True
class PlanoComModalidades(PlanoResponse):
    modalidades: List[ModalidadeResponse] = []
    class Config:
        from_attributes = True
class PlanoListResponse(BaseModel):
    id_plano: int
    nome: str
    preco_mensal: Decimal
    qtd_modalidades: int = 0
    class Config:
        from_attributes = True
