from pydantic import BaseModel
from typing import List, Any, Optional
from decimal import Decimal
class MetricaGeral(BaseModel):
    label: str
    valor: Any
    unidade: Optional[str] = None
    variacao: Optional[str] = None
class KPIDashboard(BaseModel):
    total_alunos: int
    alunos_ativos: int
    taxa_retencao: float
    receita_total: Decimal
    mrr: Decimal
    ticket_medio: Decimal
    taxa_churn: float
    taxa_conversao_pagamentos: float
    total_pagamentos: int
    total_itens_pagamento: int
    total_inscricoes: int
class GraficoSerie(BaseModel):
    labels: List[str]
    valores: List[float]
    titulo: str
class GraficoDistribuicao(BaseModel):
    categorias: List[str]
    valores: List[float]
    percentuais: List[float]
    titulo: str
class ReceitaMensal(BaseModel):
    mes: str
    receita: Decimal
    quantidade_pagamentos: int
    ticket_medio: Decimal

class PagamentoMesAnterior(BaseModel):
    mes_origem: str
    quantidade: int
    valor: Decimal

class DetalhePagamentoMensal(BaseModel):
    mes: str
    receita_total: Decimal
    total_pagamentos_recebidos: int
    # Pagamentos referentes ao próprio mês
    pagamentos_do_mes_total: int
    pagamentos_do_mes_no_prazo: int
    pagamentos_do_mes_apos_prazo_neste_mes: int
    pagamentos_do_mes_atrasados_posteriores: int
    pagamentos_do_mes_pendentes: int
    valor_pagamentos_do_mes: Decimal
    percentual_no_prazo: float
    percentual_apos_prazo_neste_mes: float
    percentual_atrasados_posteriores: float
    percentual_pendentes: float
    # Pagamentos de meses anteriores recebidos neste mês
    pagamentos_meses_anteriores: List[PagamentoMesAnterior]
    valor_meses_anteriores: Decimal
class ChurnMensal(BaseModel):
    mes: str
    cancelamentos: int
    total_inscricoes: int
    taxa_churn: float
class AlunoRanking(BaseModel):
    matricula: str
    nome: str
    valor: Decimal
    posicao: int
class DashboardCompleto(BaseModel):
    kpis: KPIDashboard
    receita_mensal: List[ReceitaMensal]
    churn_mensal: List[ChurnMensal]
    distribuicao_status: GraficoDistribuicao
    distribuicao_planos: GraficoDistribuicao
    top_alunos_ltv: List[AlunoRanking]
    modalidades_populares: GraficoDistribuicao
