from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, extract, case
from typing import List
from datetime import date, datetime, timedelta
from dateutil.relativedelta import relativedelta
from app.core.database import get_db
from app.models.models import (
    Aluno,
    Inscricao,
    Pagamento,
    Plano,
    ItemPagamento,
    StatusPagamentoEnum
)
from app.schemas.metricas import (
    KPIDashboard,
    ReceitaMensal,
    ChurnMensal,
    DashboardCompleto,
    GraficoDistribuicao,
    AlunoRanking,
    DetalhePagamentoMensal
)
router = APIRouter(
    prefix="/metricas",
    tags=["Métricas & Dashboard"],
)
@router.get("/kpis", response_model=KPIDashboard, summary="KPIs principais")
async def obter_kpis(
    db: Session = Depends(get_db)
):
    total_alunos = db.query(func.count(Aluno.matricula)).scalar()
    
    alunos_ativos = db.query(func.count(func.distinct(Inscricao.id_aluno)))\
        .filter(Inscricao.status == "ativa")\
        .scalar()
    
    total_inscricoes_ativas = db.query(func.count(Inscricao.id_inscricao))\
        .filter(Inscricao.status == "ativa")\
        .scalar()
    
    inscricoes_canceladas = db.query(func.count(Inscricao.id_inscricao))\
        .filter(Inscricao.status == "cancelada")\
        .scalar()
    
    # TAXA DE RETENÇÃO CORRIGIDA: mede a capacidade de manter clientes
    # Fórmula: alunos_ativos / (alunos_ativos + alunos_que_cancelaram) * 100
    total_alunos_que_ja_foram_clientes = alunos_ativos + inscricoes_canceladas
    taxa_retencao = (alunos_ativos / total_alunos_que_ja_foram_clientes * 100) if total_alunos_que_ja_foram_clientes > 0 else 0
    
    # TAXA DE CHURN CORRIGIDA: cancelamentos nos últimos 30 dias
    # Fórmula: (cancelamentos_ultimos_30_dias / alunos_ativos_inicio_periodo) * 100
    data_30_dias_atras = date.today() - timedelta(days=30)
    cancelamentos_recentes = db.query(func.count(Inscricao.id_inscricao))\
        .filter(
            Inscricao.status == "cancelada",
            Inscricao.data_fim >= data_30_dias_atras,
            Inscricao.data_fim.isnot(None)
        ).scalar() or 0
    
    # Alunos ativos há 30 dias atrás (aproximação: alunos_ativos + cancelamentos_recentes)
    alunos_ativos_30_dias_atras = alunos_ativos + cancelamentos_recentes
    taxa_churn = (cancelamentos_recentes / alunos_ativos_30_dias_atras * 100) if alunos_ativos_30_dias_atras > 0 else 0
    
    total_inscricoes_historico = db.query(func.count(Inscricao.id_inscricao)).scalar()
    
    receita_total = db.query(func.coalesce(func.sum(Pagamento.valor_total_pago), 0))\
        .filter(Pagamento.status == "pago")\
        .scalar()
    
    # MRR CORRIGIDO: soma o preço mensal das inscrições ativas
    # Conta todas as inscrições ativas (um aluno pode ter múltiplas inscrições)
    # Isso está correto se o modelo de negócio permite múltiplas inscrições por aluno
    mrr = db.query(func.coalesce(func.sum(Plano.preco_mensal), 0))\
        .join(Inscricao, Plano.id_plano == Inscricao.id_plano)\
        .filter(Inscricao.status == "ativa")\
        .scalar()
    
    pagamentos_pagos = db.query(func.count(Pagamento.id_pagamento))\
        .filter(Pagamento.status == "pago")\
        .scalar()
    ticket_medio = (receita_total / pagamentos_pagos) if pagamentos_pagos > 0 else 0
    
    total_pagamentos = db.query(func.count(Pagamento.id_pagamento)).scalar()
    pagamentos_pagos_count = db.query(func.count(Pagamento.id_pagamento))\
        .filter(Pagamento.status == "pago")\
        .scalar()
    # TAXA DE ADIMPLÊNCIA: percentual de pagamentos que foram quitados
    taxa_conversao = (pagamentos_pagos_count / total_pagamentos * 100) if total_pagamentos > 0 else 0
    
    total_itens_pagamento = db.query(func.count(ItemPagamento.id_item_pagamento)).scalar()
    
    return {
        "total_alunos": total_alunos,
        "alunos_ativos": alunos_ativos,
        "taxa_retencao": round(taxa_retencao, 2),
        "receita_total": receita_total,
        "mrr": mrr,
        "ticket_medio": round(ticket_medio, 2),
        "taxa_churn": round(taxa_churn, 2),
        "taxa_conversao_pagamentos": round(taxa_conversao, 2),
        "total_pagamentos": total_pagamentos,
        "total_itens_pagamento": total_itens_pagamento,
        "total_inscricoes": total_inscricoes_historico
    }
@router.get("/receita-mensal", response_model=List[ReceitaMensal], summary="Receita mensal")
async def obter_receita_mensal(
    meses: int = Query(12, ge=1, le=24, description="Quantidade de meses"),
    db: Session = Depends(get_db)
):
    primeiro_pagamento = db.query(func.min(Pagamento.data_pagamento))\
        .filter(Pagamento.status == "pago", Pagamento.data_pagamento.isnot(None))\
        .scalar()
    
    if not primeiro_pagamento:
        return []
    
    data_inicial = primeiro_pagamento.replace(day=1)
    hoje = date.today()
    
    resultados = db.query(
        extract('year', Pagamento.data_pagamento).label('ano'),
        extract('month', Pagamento.data_pagamento).label('mes'),
        func.coalesce(func.sum(Pagamento.valor_total_pago), 0).label('receita'),
        func.count(Pagamento.id_pagamento).label('quantidade')
    ).filter(
        Pagamento.status == "pago",
        Pagamento.data_pagamento.isnot(None),
        Pagamento.data_pagamento >= data_inicial
    ).group_by('ano', 'mes').order_by('ano', 'mes').all()
    
    receitas_dict = {}
    for r in resultados:
        mes_str = f"{int(r.ano)}-{str(int(r.mes)).zfill(2)}"
        ticket_medio = (r.receita / r.quantidade) if r.quantidade > 0 else 0
        receitas_dict[mes_str] = {
            "mes": mes_str,
            "receita": float(r.receita),
            "quantidade_pagamentos": r.quantidade,
            "ticket_medio": round(float(ticket_medio), 2)
        }
    
    dados = []
    mes_atual = data_inicial
    while mes_atual <= hoje:
        mes_str = mes_atual.strftime("%Y-%m")
        if mes_str in receitas_dict:
            dados.append(receitas_dict[mes_str])
        else:
            dados.append({
                "mes": mes_str,
                "receita": 0.0,
                "quantidade_pagamentos": 0,
                "ticket_medio": 0.0
            })
        mes_atual += relativedelta(months=1)
    
    return dados[-meses:]
@router.get("/churn-mensal", response_model=List[ChurnMensal], summary="Churn mensal")
async def obter_churn_mensal(
    meses: int = Query(12, ge=1, le=24, description="Quantidade de meses"),
    db: Session = Depends(get_db)
):
    # Buscar cancelamentos por mês
    resultados = db.query(
        extract('year', Inscricao.data_fim).label('ano'),
        extract('month', Inscricao.data_fim).label('mes'),
        func.count(Inscricao.id_inscricao).label('cancelamentos')
    ).filter(
        Inscricao.status == "cancelada",
        Inscricao.data_fim.isnot(None)
    ).group_by('ano', 'mes').order_by('ano', 'mes').all()
    
    dados = []
    for r in resultados[-meses:]:
        mes_str = f"{int(r.ano)}-{str(int(r.mes)).zfill(2)}"
        ano = int(r.ano)
        mes = int(r.mes)
        primeiro_dia_mes = date(ano, mes, 1)
        
        inscricoes_ativas_inicio_mes = db.query(func.count(Inscricao.id_inscricao))\
            .filter(
                Inscricao.data_inicio < primeiro_dia_mes,
                (Inscricao.data_fim.is_(None)) | (Inscricao.data_fim >= primeiro_dia_mes)
            ).scalar() or 0
        
        taxa_churn = (r.cancelamentos / inscricoes_ativas_inicio_mes * 100) if inscricoes_ativas_inicio_mes > 0 else 0
        
        dados.append({
            "mes": mes_str,
            "cancelamentos": r.cancelamentos,
            "total_inscricoes": inscricoes_ativas_inicio_mes,
            "taxa_churn": round(taxa_churn, 2)
        })
    
    return dados
@router.get("/distribuicao-status", response_model=GraficoDistribuicao, summary="Distribuição por status")
async def obter_distribuicao_status(
    db: Session = Depends(get_db)
):
    resultados = db.query(
        Inscricao.status,
        func.count(Inscricao.id_inscricao).label('quantidade')
    ).group_by(Inscricao.status).all()
    total = sum(r.quantidade for r in resultados)
    categorias = []
    valores = []
    percentuais = []
    for r in resultados:
        categorias.append(r.status)
        valores.append(float(r.quantidade))
        percentuais.append(round(r.quantidade / total * 100, 2) if total > 0 else 0)
    return {
        "categorias": categorias,
        "valores": valores,
        "percentuais": percentuais,
        "titulo": "Distribuição de Inscrições por Status"
    }
@router.get("/distribuicao-planos", response_model=GraficoDistribuicao, summary="Distribuição por planos")
async def obter_distribuicao_planos(
    db: Session = Depends(get_db)
):
    resultados = db.query(
        Plano.nome,
        func.count(Inscricao.id_inscricao).label('quantidade')
    ).join(Inscricao).filter(
        Inscricao.status == "ativa"
    ).group_by(Plano.nome).order_by(func.count(Inscricao.id_inscricao).desc()).all()
    total = sum(r.quantidade for r in resultados)
    categorias = []
    valores = []
    percentuais = []
    for r in resultados:
        categorias.append(r.nome)
        valores.append(float(r.quantidade))
        percentuais.append(round(r.quantidade / total * 100, 2) if total > 0 else 0)
    return {
        "categorias": categorias,
        "valores": valores,
        "percentuais": percentuais,
        "titulo": "Distribuição de Inscrições Ativas por Plano"
    }
@router.get("/modalidades-populares", response_model=GraficoDistribuicao, summary="Ranking de modalidades")
async def obter_modalidades_populares(
    limite: int = Query(20, ge=3, le=20, description="Quantidade de modalidades"),
    db: Session = Depends(get_db)
):
    from app.models.models import Modalidade, InscricaoModalidade
    resultados = db.query(
        Modalidade.nome,
        func.count(InscricaoModalidade.id_inscricao).label('quantidade')
    ).join(InscricaoModalidade)\
     .join(Inscricao)\
     .filter(Inscricao.status == "ativa")\
     .group_by(Modalidade.nome)\
     .order_by(func.count(InscricaoModalidade.id_inscricao).desc())\
     .limit(limite).all()
    total = sum(r.quantidade for r in resultados)
    categorias = []
    valores = []
    percentuais = []
    for r in resultados:
        categorias.append(r.nome)
        valores.append(float(r.quantidade))
        percentuais.append(round(r.quantidade / total * 100, 2) if total > 0 else 0)
    return {
        "categorias": categorias,
        "valores": valores,
        "percentuais": percentuais,
        "titulo": "Top Modalidades Mais Populares (exceto Musculação)"
    }
@router.get("/evolucao-alunos", response_model=List[ReceitaMensal], summary="Evolução de alunos ativos")
async def obter_evolucao_alunos(
    meses: int = Query(12, ge=1, le=24, description="Quantidade de meses"),
    db: Session = Depends(get_db)
):
    # CORREÇÃO: Calcular quantos alunos estavam ATIVOS em cada mês
    # (não quantos iniciaram em cada mês)
    dados = []
    hoje = date.today()
    
    for i in range(meses):
        mes_ref = hoje - relativedelta(months=meses - i - 1)
        ano = mes_ref.year
        mes = mes_ref.month
        
        primeiro_dia = date(ano, mes, 1)
        if mes == 12:
            ultimo_dia = date(ano + 1, 1, 1) - timedelta(days=1)
        else:
            ultimo_dia = date(ano, mes + 1, 1) - timedelta(days=1)
        
        alunos_ativos = db.query(func.count(func.distinct(Inscricao.id_aluno)))\
            .filter(
                Inscricao.data_inicio <= ultimo_dia,
                (Inscricao.data_fim.is_(None)) | (Inscricao.data_fim >= primeiro_dia),
                Inscricao.status == "ativa"
            ).scalar() or 0
        
        mes_str = f"{ano}-{mes:02d}"
        dados.append({
            "mes": mes_str,
            "receita": float(alunos_ativos),
            "quantidade_pagamentos": alunos_ativos,
            "ticket_medio": 0
        })
    
    return dados
@router.get("/taxa-inadimplencia", summary="Taxa de inadimplência")
async def obter_taxa_inadimplencia(
    db: Session = Depends(get_db)
):
    total_pagamentos = db.query(func.count(Pagamento.id_pagamento)).scalar()
    pagamentos_atrasados = db.query(func.count(Pagamento.id_pagamento))\
        .filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)\
        .scalar()
    valor_em_atraso = db.query(func.coalesce(func.sum(Pagamento.valor_total_devido), 0))\
        .filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)\
        .scalar()
    taxa = (pagamentos_atrasados / total_pagamentos * 100) if total_pagamentos > 0 else 0
    return {
        "taxa_inadimplencia": round(taxa, 2),
        "quantidade_atrasados": pagamentos_atrasados,
        "valor_em_atraso": float(valor_em_atraso),
        "total_pagamentos": total_pagamentos
    }
@router.get("/top-alunos-ltv", response_model=List[AlunoRanking], summary="Top alunos por LTV")
async def obter_top_alunos_ltv(
    limite: int = Query(10, ge=1, le=100, description="Quantidade de alunos"),
    db: Session = Depends(get_db)
):
    resultados = db.query(
        Aluno.matricula,
        Aluno.nome_completo,
        func.coalesce(func.sum(Pagamento.valor_total_pago), 0).label('ltv')
    ).join(Inscricao, Aluno.matricula == Inscricao.id_aluno)\
     .join(Pagamento, Inscricao.id_inscricao == Pagamento.id_inscricao)\
     .filter(Pagamento.status == "pago")\
     .group_by(Aluno.matricula, Aluno.nome_completo)\
     .order_by(func.sum(Pagamento.valor_total_pago).desc())\
     .limit(limite).all()
    ranking = []
    for idx, r in enumerate(resultados, 1):
        ranking.append({
            "matricula": r.matricula,
            "nome": r.nome_completo,
            "valor": r.ltv,
            "posicao": idx
        })
    return ranking
@router.get("/pagamentos-mensais", summary="Status de pagamento mensal - Quem pagou vs não pagou o mês")
async def obter_pagamentos_mensais(
    meses: int = Query(12, ge=1, le=24, description="Quantidade de meses"),
    db: Session = Depends(get_db)
):
    """
    Mostra status de pagamento dos alunos ativos em cada mês.
    - Total de alunos: todos com inscrição ativa
    - Alunos em dia: pagaram o mês OU não têm fatura para aquele mês (primeiro pagamento é futuro)
    - Alunos inadimplentes: têm fatura do mês E não pagaram
    """
    data_fim = datetime.now()
    data_inicio = data_fim - relativedelta(months=meses)
    resultados = []
    
    for i in range(meses):
        mes_ref = data_fim - relativedelta(months=meses - i - 1)
        ano = mes_ref.year
        mes = mes_ref.month
        primeiro_dia = date(ano, mes, 1)
        if mes == 12:
            ultimo_dia = date(ano + 1, 1, 1) - timedelta(days=1)
        else:
            ultimo_dia = date(ano, mes + 1, 1) - timedelta(days=1)
        
        hoje = date.today()
        data_corte = min(ultimo_dia, hoje)
        
        # Total de alunos com inscrição ativa NAQUELE MÊS ESPECÍFICO
        # Inscrição deve ter começado antes do fim do mês E ainda estar com status 'ativa'
        # (não conta canceladas mesmo que tenham estado ativas durante o mês)
        total_alunos_ativos = db.query(func.count(func.distinct(Inscricao.id_aluno)))\
            .filter(
                Inscricao.status == 'ativa',
                Inscricao.data_inicio <= data_corte
            ).scalar() or 0
        
        # Alunos que têm pagamento vencendo neste mês E não pagaram (apenas com status ativa)
        alunos_inadimplentes = db.query(func.count(func.distinct(Inscricao.id_aluno)))\
            .join(Pagamento, Inscricao.id_inscricao == Pagamento.id_inscricao)\
            .filter(
                Inscricao.status == 'ativa',
                Inscricao.data_inicio <= data_corte,
                Pagamento.data_vencimento >= primeiro_dia,
                Pagamento.data_vencimento <= data_corte,
                Pagamento.data_pagamento.is_(None)
            ).scalar() or 0
        
        # Alunos em dia = total - inadimplentes
        alunos_em_dia = total_alunos_ativos - alunos_inadimplentes
        
        if total_alunos_ativos > 0:
            percentual_em_dia = (alunos_em_dia / total_alunos_ativos * 100)
            percentual_inadimplentes = (alunos_inadimplentes / total_alunos_ativos * 100)
        else:
            percentual_em_dia = 0
            percentual_inadimplentes = 0
        
        resultados.append({
            "mes": f"{ano}-{mes:02d}",
            "total_alunos": total_alunos_ativos,
            "alunos_pagaram": alunos_em_dia,
            "alunos_nao_pagaram": alunos_inadimplentes,
            "percentual_pagaram": round(percentual_em_dia, 2),
            "percentual_nao_pagaram": round(percentual_inadimplentes, 2)
        })
    
    return resultados

@router.get("/detalhes-pagamento-mes/{mes}", response_model=DetalhePagamentoMensal, summary="Detalhes de pagamentos de um mês específico")
async def obter_detalhes_pagamento_mes(
    mes: str,
    db: Session = Depends(get_db)
):
    """
    Retorna detalhamento completo dos pagamentos de um mês:
    - Pagamentos recebidos naquele mês (por data_pagamento)
    - Separação entre pagamentos do próprio mês e de meses anteriores
    - Quantos pagamentos do mês foram feitos no prazo vs atrasados
    """
    try:
        ano, mes_num = mes.split('-')
        ano = int(ano)
        mes_num = int(mes_num)
    except (ValueError, AttributeError):
        raise HTTPException(status_code=400, detail="Formato de mês inválido. Use YYYY-MM")
    
    # Definir período do mês
    primeiro_dia = date(ano, mes_num, 1)
    if mes_num == 12:
        ultimo_dia = date(ano + 1, 1, 1) - timedelta(days=1)
    else:
        ultimo_dia = date(ano, mes_num + 1, 1) - timedelta(days=1)
    
    # 1. Total de pagamentos RECEBIDOS neste mês (por data_pagamento)
    pagamentos_recebidos = db.query(Pagamento).filter(
        Pagamento.status == 'pago',
        Pagamento.data_pagamento >= primeiro_dia,
        Pagamento.data_pagamento <= ultimo_dia,
        Pagamento.valor_total_pago != None  # Excluir pagamentos sem valor
    ).all()
    
    total_pagamentos_recebidos = len(pagamentos_recebidos)
    receita_total = sum(float(p.valor_total_pago or 0) for p in pagamentos_recebidos)
    
    # 2. Separar pagamentos do próprio mês vs meses anteriores
    pagamentos_proprio_mes = []
    pagamentos_meses_anteriores_dict = {}
    
    for pag in pagamentos_recebidos:
        venc_ano = pag.data_vencimento.year
        venc_mes = pag.data_vencimento.month
        
        if venc_ano == ano and venc_mes == mes_num:
            # Pagamento referente ao próprio mês
            pagamentos_proprio_mes.append(pag)
        else:
            # Pagamento de mês anterior
            mes_origem = f"{venc_ano}-{str(venc_mes).zfill(2)}"
            if mes_origem not in pagamentos_meses_anteriores_dict:
                pagamentos_meses_anteriores_dict[mes_origem] = []
            pagamentos_meses_anteriores_dict[mes_origem].append(pag)
    
    # 3. Total de pagamentos que DEVERIAM ser pagos neste mês (total esperado)
    total_esperado_mes = db.query(func.count(Pagamento.id_pagamento)).filter(
        extract('year', Pagamento.data_vencimento) == ano,
        extract('month', Pagamento.data_vencimento) == mes_num
    ).scalar() or 0
    
    # 4. Pagamentos do mês: pagos no prazo (até a data de vencimento)
    pagamentos_no_prazo = db.query(func.count(Pagamento.id_pagamento)).filter(
        extract('year', Pagamento.data_vencimento) == ano,
        extract('month', Pagamento.data_vencimento) == mes_num,
        Pagamento.data_pagamento != None,
        Pagamento.data_pagamento <= Pagamento.data_vencimento
    ).scalar() or 0
    
    # 5. Pagamentos pagos ATRASADOS (após vencimento) mas DENTRO do mesmo mês de vencimento
    # Exemplo: vence 10/06, pago 12/06 ou 25/06
    pagamentos_atrasados_neste_mes = db.query(func.count(Pagamento.id_pagamento)).filter(
        extract('year', Pagamento.data_vencimento) == ano,
        extract('month', Pagamento.data_vencimento) == mes_num,
        Pagamento.data_pagamento != None,
        Pagamento.data_pagamento > Pagamento.data_vencimento,
        extract('year', Pagamento.data_pagamento) == ano,
        extract('month', Pagamento.data_pagamento) == mes_num
    ).scalar() or 0
    
    # 6. Pagamentos pagos em MESES POSTERIORES ao vencimento
    # Exemplo: vence junho, pago em novembro
    pagamentos_meses_posteriores = db.query(func.count(Pagamento.id_pagamento)).filter(
        extract('year', Pagamento.data_vencimento) == ano,
        extract('month', Pagamento.data_vencimento) == mes_num,
        Pagamento.data_pagamento != None,
        Pagamento.data_pagamento > Pagamento.data_vencimento,
        (
            (extract('year', Pagamento.data_pagamento) != ano) |
            (extract('month', Pagamento.data_pagamento) != mes_num)
        )
    ).scalar() or 0
    
    # 7. Pagamentos AINDA NÃO PAGOS (data_pagamento = NULL)
    # Inclui tanto status 'atrasado' quanto 'pendente' que não foram pagos ainda
    pagamentos_nao_pagos = db.query(func.count(Pagamento.id_pagamento)).filter(
        extract('year', Pagamento.data_vencimento) == ano,
        extract('month', Pagamento.data_vencimento) == mes_num,
        Pagamento.data_pagamento == None
    ).scalar() or 0
    
    valor_proprio_mes = sum(float(p.valor_total_pago or 0) for p in pagamentos_proprio_mes)
    valor_meses_anteriores = receita_total - valor_proprio_mes
    
    # Percentuais baseados no TOTAL ESPERADO
    percentual_no_prazo = (pagamentos_no_prazo / total_esperado_mes * 100) if total_esperado_mes > 0 else 0
    percentual_atrasados_neste_mes = (pagamentos_atrasados_neste_mes / total_esperado_mes * 100) if total_esperado_mes > 0 else 0
    percentual_meses_posteriores = (pagamentos_meses_posteriores / total_esperado_mes * 100) if total_esperado_mes > 0 else 0
    percentual_nao_pagos = (pagamentos_nao_pagos / total_esperado_mes * 100) if total_esperado_mes > 0 else 0
    
    # 6. Agrupar pagamentos de meses anteriores
    pagamentos_anteriores_lista = []
    for mes_origem, pags in sorted(pagamentos_meses_anteriores_dict.items()):
        pagamentos_anteriores_lista.append({
            "mes_origem": mes_origem,
            "quantidade": len(pags),
            "valor": sum(float(p.valor_total_pago or 0) for p in pags)
        })
    
    return {
        "mes": mes,
        "receita_total": receita_total,
        "total_pagamentos_recebidos": total_pagamentos_recebidos,
        "pagamentos_do_mes_total": total_esperado_mes,
        "pagamentos_do_mes_no_prazo": pagamentos_no_prazo,
        "pagamentos_do_mes_apos_prazo_neste_mes": pagamentos_atrasados_neste_mes,
        "pagamentos_do_mes_atrasados_posteriores": pagamentos_meses_posteriores,
        "pagamentos_do_mes_pendentes": pagamentos_nao_pagos,
        "valor_pagamentos_do_mes": valor_proprio_mes,
        "percentual_no_prazo": round(percentual_no_prazo, 2),
        "percentual_apos_prazo_neste_mes": round(percentual_atrasados_neste_mes, 2),
        "percentual_atrasados_posteriores": round(percentual_meses_posteriores, 2),
        "percentual_pendentes": round(percentual_nao_pagos, 2),
        "pagamentos_meses_anteriores": pagamentos_anteriores_lista,
        "valor_meses_anteriores": valor_meses_anteriores
    }

@router.get("/dashboard", response_model=DashboardCompleto, summary="Dashboard completo")
async def obter_dashboard_completo(
    db: Session = Depends(get_db)
):
    kpis = await obter_kpis(db)
    receita = await obter_receita_mensal(12, db)
    churn = await obter_churn_mensal(12, db)
    dist_status = await obter_distribuicao_status(db)
    dist_planos = await obter_distribuicao_planos(db)
    top_ltv = await obter_top_alunos_ltv(10, db)
    modalidades_pop = await obter_modalidades_populares(5, db)
    return {
        "kpis": kpis,
        "receita_mensal": receita,
        "churn_mensal": churn,
        "distribuicao_status": dist_status,
        "distribuicao_planos": dist_planos,
        "top_alunos_ltv": top_ltv,
        "modalidades_populares": modalidades_pop
    }
