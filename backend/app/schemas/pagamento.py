from pydantic import BaseModel, Field
from datetime import date
from typing import Optional, List
from decimal import Decimal
from app.models.models import StatusPagamentoEnum
class ItemPagamentoBase(BaseModel):
    id_tipo_transacao: int = Field(..., description="ID do tipo de transação")
    descricao: str = Field(..., min_length=3, max_length=200)
    valor: Decimal = Field(..., gt=0, description="Valor do item")
class ItemPagamentoResponse(BaseModel):
    id_item_pagamento: int
    id_pagamento: int
    id_tipo_transacao: int
    descricao_item: str
    valor: Decimal
    class Config:
        from_attributes = True
class PagamentoBase(BaseModel):
    id_inscricao: int = Field(..., gt=0, description="ID da inscrição")
    data_vencimento: date = Field(..., description="Data de vencimento")
    valor_total_devido: Decimal = Field(..., gt=0, description="Valor total devido")
class PagamentoCreate(PagamentoBase):
    itens: List[ItemPagamentoBase] = Field(..., min_length=1, description="Itens do pagamento")
class PagamentoUpdate(BaseModel):
    data_pagamento: date = Field(..., description="Data do pagamento")
    valor_total_pago: Decimal = Field(..., gt=0, description="Valor pago")
    status: StatusPagamentoEnum = Field(default=StatusPagamentoEnum.PAGO)
class PagamentoResponse(PagamentoBase):
    id_pagamento: int
    data_pagamento: Optional[date] = None
    valor_total_pago: Optional[Decimal] = None
    status: StatusPagamentoEnum
    itens: List[ItemPagamentoResponse] = []
    class Config:
        from_attributes = True
class PagamentoListResponse(BaseModel):
    id_pagamento: int
    id_inscricao: int
    aluno_nome: Optional[str] = None
    aluno_matricula: Optional[str] = None
    data_vencimento: date
    data_pagamento: Optional[date] = None
    valor_total_devido: Decimal
    valor_total_pago: Optional[Decimal] = None
    status: StatusPagamentoEnum
    class Config:
        from_attributes = True
class PagamentoDetalhado(PagamentoResponse):
    aluno_nome: str
    aluno_matricula: str
    plano_nome: str
    class Config:
        from_attributes = True
