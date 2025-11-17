from sqlalchemy import Column, String, Date, Integer, Numeric, Boolean, ForeignKey, Text, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.core.database import Base
class StatusInscricaoEnum(str, enum.Enum):
    ATIVA = "ativa"
    CANCELADA = "cancelada"
    PAUSADA = "pausada"
    FINALIZADA = "finalizada"
class StatusPagamentoEnum(str, enum.Enum):
    PAGO = "pago"
    PENDENTE = "pendente"
    ATRASADO = "atrasado"
class Unidade(Base):
    __tablename__ = "unidades"
    id_unidade = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), unique=True, nullable=False, index=True)
    endereco = Column(Text)
    telefone = Column(String(20))
    inscricoes = relationship("Inscricao", back_populates="unidade")
    def __repr__(self):
        return f"<Unidade(id={self.id_unidade}, nome={self.nome})>"
class Aluno(Base):
    __tablename__ = "alunos"
    matricula = Column(String(6), primary_key=True, index=True)
    nome_completo = Column(String(200), nullable=False, index=True)
    sexo = Column(String(20), nullable=False)  # Alterado de String(1) para String(20) para suportar 'Masculino', 'Feminino', 'Outro'
    cpf = Column(String(14), unique=True, nullable=False, index=True)
    data_nascimento = Column(Date, nullable=False)
    email = Column(String(200), unique=True, nullable=False, index=True)
    telefone = Column(String(20), nullable=False)
    data_cadastro = Column(Date, nullable=False, default=func.current_date())
    inscricoes = relationship("Inscricao", back_populates="aluno", cascade="all, delete-orphan")
    def __repr__(self):
        return f"<Aluno(matricula={self.matricula}, nome={self.nome_completo})>"
class Plano(Base):
    __tablename__ = "planos"
    id_plano = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), unique=True, nullable=False, index=True)
    descricao = Column(Text)
    preco_mensal = Column(Numeric(10, 2), nullable=False)
    inscricoes = relationship("Inscricao", back_populates="plano")
    modalidades = relationship("Modalidade", secondary="plano_modalidades", back_populates="planos")
    def __repr__(self):
        return f"<Plano(id={self.id_plano}, nome={self.nome}, preco={self.preco_mensal})>"
class Modalidade(Base):
    __tablename__ = "modalidades"
    id_modalidade = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), unique=True, nullable=False, index=True)
    planos = relationship("Plano", secondary="plano_modalidades", back_populates="modalidades")
    inscricoes_modalidades = relationship("InscricaoModalidade", back_populates="modalidade")
    def __repr__(self):
        return f"<Modalidade(id={self.id_modalidade}, nome={self.nome})>"
class PlanoModalidade(Base):
    __tablename__ = "plano_modalidades"
    id_plano = Column(Integer, ForeignKey("planos.id_plano", ondelete="CASCADE"), primary_key=True)
    id_modalidade = Column(Integer, ForeignKey("modalidades.id_modalidade", ondelete="CASCADE"), primary_key=True)
class Promocao(Base):
    __tablename__ = "promocoes"
    id_promocao = Column(Integer, primary_key=True, autoincrement=True)
    nome_campanha = Column(String(150), unique=True, nullable=False)
    descricao = Column(Text)
    tipo = Column(String(20), nullable=False)  # 'percentual' ou 'valor_fixo'
    valor = Column(Numeric(10, 2), nullable=False)
    duracao_meses = Column(Integer)
    data_inicio_validade = Column(Date, nullable=False)
    data_fim_validade = Column(Date, nullable=False)
    ativa = Column(Boolean, default=True)
    def __repr__(self):
        return f"<Promocao(id={self.id_promocao}, nome={self.nome_campanha})>"
class Inscricao(Base):
    __tablename__ = "inscricoes"
    id_inscricao = Column(Integer, primary_key=True, autoincrement=True)
    id_aluno = Column(String(6), ForeignKey("alunos.matricula", ondelete="CASCADE"), nullable=False, index=True)
    id_plano = Column(Integer, ForeignKey("planos.id_plano", ondelete="SET NULL"), index=True)
    id_promocao = Column(Integer, ForeignKey("promocoes.id_promocao", ondelete="SET NULL"), index=True)
    id_unidade = Column(Integer, ForeignKey("unidades.id_unidade", ondelete="RESTRICT"), nullable=False, index=True)
    data_inicio = Column(Date, nullable=False, index=True)
    data_fim = Column(Date)
    status = Column(String(20), nullable=False, default="ativa", index=True)
    aluno = relationship("Aluno", back_populates="inscricoes")
    plano = relationship("Plano", back_populates="inscricoes")
    unidade = relationship("Unidade", back_populates="inscricoes")
    pagamentos = relationship("Pagamento", back_populates="inscricao", cascade="all, delete-orphan")
    inscricoes_modalidades = relationship("InscricaoModalidade", back_populates="inscricao", cascade="all, delete-orphan")
    def __repr__(self):
        return f"<Inscricao(id={self.id_inscricao}, aluno={self.id_aluno}, status={self.status})>"
class InscricaoModalidade(Base):
    __tablename__ = "inscricoes_modalidades"
    id_inscricao = Column(Integer, ForeignKey("inscricoes.id_inscricao", ondelete="CASCADE"), primary_key=True, index=True)
    id_modalidade = Column(Integer, ForeignKey("modalidades.id_modalidade", ondelete="CASCADE"), primary_key=True, index=True)
    inscricao = relationship("Inscricao", back_populates="inscricoes_modalidades")
    modalidade = relationship("Modalidade", back_populates="inscricoes_modalidades")
    def __repr__(self):
        return f"<InscricaoModalidade(inscricao={self.id_inscricao}, modalidade={self.id_modalidade})>"
class TipoTransacao(Base):
    __tablename__ = "tipos_transacao"
    id_tipo_transacao = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), unique=True, nullable=False)
    descricao = Column(Text)
    itens_pagamento = relationship("ItemPagamento", back_populates="tipo_transacao")
    def __repr__(self):
        return f"<TipoTransacao(id={self.id_tipo_transacao}, nome={self.nome})>"
class Pagamento(Base):
    __tablename__ = "pagamentos"
    id_pagamento = Column(Integer, primary_key=True, autoincrement=True)
    id_inscricao = Column(Integer, ForeignKey("inscricoes.id_inscricao", ondelete="CASCADE"), nullable=False, index=True)
    data_vencimento = Column(Date, nullable=False, index=True)
    data_pagamento = Column(Date)
    valor_total_devido = Column(Numeric(10, 2), nullable=False)
    valor_total_pago = Column(Numeric(10, 2))
    status = Column(String(20), nullable=False, default="atrasado", index=True)
    inscricao = relationship("Inscricao", back_populates="pagamentos")
    itens = relationship("ItemPagamento", back_populates="pagamento", cascade="all, delete-orphan")
    def __repr__(self):
        return f"<Pagamento(id={self.id_pagamento}, inscricao={self.id_inscricao}, status={self.status})>"
class ItemPagamento(Base):
    __tablename__ = "itens_pagamento"
    id_item_pagamento = Column(Integer, primary_key=True, autoincrement=True)
    id_pagamento = Column(Integer, ForeignKey("pagamentos.id_pagamento", ondelete="CASCADE"), nullable=False, index=True)
    id_tipo_transacao = Column(Integer, ForeignKey("tipos_transacao.id_tipo_transacao", ondelete="RESTRICT"))
    descricao_item = Column(String(255))
    valor = Column(Numeric(10, 2), nullable=False)
    pagamento = relationship("Pagamento", back_populates="itens")
    tipo_transacao = relationship("TipoTransacao", back_populates="itens_pagamento")
    def __repr__(self):
        return f"<ItemPagamento(id={self.id_item_pagamento}, pagamento={self.id_pagamento}, valor={self.valor})>"
class Usuario(Base):
    __tablename__ = "usuarios"
    id_usuario = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    senha_hash = Column(String(255), nullable=False)
    nome_completo = Column(String(100))
    email = Column(String(100))
    ativo = Column(Boolean, default=True)
    data_criacao = Column(TIMESTAMP, server_default=func.now())
    ultimo_acesso = Column(TIMESTAMP)
    def __repr__(self):
        return f"<Usuario(id={self.id_usuario}, username={self.username}, ativo={self.ativo})>"
