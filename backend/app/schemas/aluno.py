from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import date
from typing import Optional

class AlunoBase(BaseModel):
    nome_completo: str = Field(..., min_length=3, max_length=200, description="Nome completo do aluno")
    sexo: str = Field(..., min_length=1, max_length=10, description="Sexo do aluno")
    cpf: str = Field(..., pattern=r"^\d{3}\.\d{3}\.\d{3}-\d{2}$", description="CPF no formato XXX.XXX.XXX-XX")
    data_nascimento: date = Field(..., description="Data de nascimento")
    email: EmailStr = Field(..., description="Email válido")
    telefone: str = Field(..., min_length=10, max_length=20, description="Telefone")
    @field_validator('data_nascimento')
    @classmethod
    def validate_idade(cls, v: date) -> date:
        hoje = date.today()
        idade = hoje.year - v.year - ((hoje.month, hoje.day) < (v.month, v.day))
        if idade < 16:
            raise ValueError('Idade mÃ­nima: 16 anos')
        if idade > 120:
            raise ValueError('Data de nascimento invÃ¡lida')
        return v
    @field_validator('nome_completo')
    @classmethod
    def validate_nome(cls, v: str) -> str:
        if len(v.split()) < 2:
            raise ValueError('Informe nome e sobrenome')
        return v.strip().title()
class AlunoCreate(AlunoBase):
    pass
class AlunoUpdate(BaseModel):
    nome_completo: Optional[str] = Field(None, min_length=3, max_length=200)
    sexo: Optional[str] = Field(None, min_length=1, max_length=10)
    email: Optional[EmailStr] = None
    telefone: Optional[str] = Field(None, min_length=10, max_length=20)
    cpf: Optional[str] = Field(None, pattern=r"^\d{3}\.\d{3}\.\d{3}-\d{2}$", description="CPF no formato XXX.XXX.XXX-XX")
    data_nascimento: Optional[date] = Field(None, description="Data de nascimento")
    @field_validator('data_nascimento')
    @classmethod
    def validate_idade(cls, v: Optional[date]) -> Optional[date]:
        if v is None:
            return v
        hoje = date.today()
        idade = hoje.year - v.year - ((hoje.month, hoje.day) < (v.month, v.day))
        if idade < 16:
            raise ValueError('Idade mÃ­nima: 16 anos')
        if idade > 120:
            raise ValueError('Data de nascimento invÃ¡lida')
        return v
    @field_validator('nome_completo')
    @classmethod
    def validate_nome(cls, v: Optional[str]) -> Optional[str]:
        if v and len(v.split()) < 2:
            raise ValueError('Informe nome e sobrenome')
        return v.strip().title() if v else None
class AlunoResponse(AlunoBase):
    matricula: str = Field(..., description="Matrícula do aluno (6 dígitos)")
    data_cadastro: date = Field(..., description="Data de cadastro")
    class Config:
        from_attributes = True
class AlunoListResponse(BaseModel):
    matricula: str
    nome_completo: str
    email: str
    telefone: str
    cpf: str
    data_cadastro: date
    class Config:
        from_attributes = True
class AlunoDetalhado(AlunoResponse):
    total_inscricoes: int = 0
    inscricao_ativa: bool = False
    ultimo_pagamento: Optional[date] = None
    class Config:
        from_attributes = True
