
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from typing import List, Optional
from datetime import date
from dateutil.relativedelta import relativedelta
from app.core.database import get_db
from app.models.models import (
    Pagamento,
    ItemPagamento,
    Inscricao,
    Aluno,
    Plano,
    StatusPagamentoEnum,
    StatusInscricaoEnum
)
from app.schemas.pagamento import (
    PagamentoCreate,
    PagamentoUpdate,
    PagamentoResponse,
    PagamentoListResponse
)
router = APIRouter(
    prefix="/pagamentos",
    tags=["Pagamentos"],
)
@router.get("/", response_model=List[PagamentoListResponse], summary="Listar pagamentos")
async def listar_pagamentos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    status_filtro: Optional[str] = Query(None, description="Filtrar por status"),
    inscricao_id: Optional[int] = Query(None, description="Filtrar por inscrição"),
    db: Session = Depends(get_db)
):
    query = db.query(Pagamento).join(Inscricao)
    if status_filtro:
        query = query.filter(Pagamento.status == status_filtro)
    if inscricao_id:
        query = query.filter(Pagamento.id_inscricao == inscricao_id)
    pagamentos = query.order_by(Pagamento.data_vencimento.desc()).offset(skip).limit(limit).all()
    result = []
    for pagamento in pagamentos:
        result.append({
            "id_pagamento": pagamento.id_pagamento,
            "id_inscricao": pagamento.id_inscricao,
            "aluno_nome": pagamento.inscricao.aluno.nome_completo,
            "data_vencimento": pagamento.data_vencimento,
            "data_pagamento": pagamento.data_pagamento,
            "valor_total_devido": pagamento.valor_total_devido,
            "valor_total_pago": pagamento.valor_total_pago,
            "status": pagamento.status
        })
    return result
@router.get("/atrasados/count", summary="Contar pagamentos atrasados")
async def contar_pagamentos_atrasados(
    nome: Optional[str] = Query(None, description="Buscar por nome ou matrícula do aluno"),
    db: Session = Depends(get_db)
):
    query = db.query(Pagamento)\
        .join(Inscricao)\
        .join(Aluno)\
        .filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)
    if nome:
        search_term = f"%{nome}%"
        query = query.filter(
            (Aluno.nome_completo.ilike(search_term)) |
            (Aluno.matricula.ilike(search_term))
        )
    total = query.count()
    return {"total": total}
@router.get("/atrasados", response_model=List[PagamentoListResponse], summary="Listar pagamentos atrasados")
async def listar_pagamentos_atrasados(
    skip: int = Query(0, ge=0),
    limit: int = Query(1000, ge=1, le=5000),
    nome: Optional[str] = Query(None, description="Buscar por nome ou matrícula do aluno"),
    db: Session = Depends(get_db)
):
    query = db.query(Pagamento)\
        .join(Inscricao)\
        .join(Aluno)\
        .filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)
    if nome:
        search_term = f"%{nome}%"
        query = query.filter(
            (Aluno.nome_completo.ilike(search_term)) |
            (Aluno.matricula.ilike(search_term))
        )
    pagamentos = query\
        .order_by(Pagamento.data_vencimento.asc())\
        .offset(skip)\
        .limit(limit)\
        .all()
    result = []
    for pagamento in pagamentos:
        result.append({
            "id_pagamento": pagamento.id_pagamento,
            "id_inscricao": pagamento.id_inscricao,
            "aluno_nome": pagamento.inscricao.aluno.nome_completo,
            "aluno_matricula": pagamento.inscricao.aluno.matricula,
            "data_vencimento": pagamento.data_vencimento,
            "data_pagamento": pagamento.data_pagamento,
            "valor_total_devido": pagamento.valor_total_devido,
            "valor_total_pago": pagamento.valor_total_pago,
            "status": pagamento.status
        })
    return result
@router.get("/pendentes-atrasados/count", summary="Contar pagamentos pendentes e atrasados")
async def contar_pagamentos_pendentes_atrasados(
    status_filter: Optional[str] = Query(None, description="Filtro: 'pendente', 'atrasado' ou None para ambos"),
    nome: Optional[str] = Query(None, description="Buscar por nome ou matrícula do aluno"),
    mes: Optional[str] = Query(None, description="Filtrar por mês de vencimento (formato: YYYY-MM)"),
    db: Session = Depends(get_db)
):
    query = db.query(Pagamento)\
        .join(Inscricao)\
        .join(Aluno)
    
    if status_filter == 'pendente':
        query = query.filter(Pagamento.status == StatusPagamentoEnum.PENDENTE)
    elif status_filter == 'atrasado':
        query = query.filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)
    else:
        query = query.filter(
            (Pagamento.status == StatusPagamentoEnum.PENDENTE) |
            (Pagamento.status == StatusPagamentoEnum.ATRASADO)
        )
    
    if nome:
        search_term = f"%{nome}%"
        query = query.filter(
            (Aluno.nome_completo.ilike(search_term)) |
            (Aluno.matricula.ilike(search_term))
        )
    
    if mes:
        # Filtrar por mês/ano de vencimento (formato: YYYY-MM)
        try:
            ano, mes_num = mes.split('-')
            ano = int(ano)
            mes_num = int(mes_num)
            query = query.filter(
                extract('year', Pagamento.data_vencimento) == ano,
                extract('month', Pagamento.data_vencimento) == mes_num
            )
        except (ValueError, AttributeError):
            pass  # Se formato inválido, ignora o filtro
    
    total = query.count()
    return {"total": total}
@router.get("/pendentes-atrasados", response_model=List[PagamentoListResponse], summary="Listar pagamentos pendentes e atrasados")
async def listar_pagamentos_pendentes_atrasados(
    skip: int = Query(0, ge=0),
    limit: int = Query(1000, ge=1, le=5000),
    status_filter: Optional[str] = Query(None, description="Filtro: 'pendente', 'atrasado' ou None para ambos"),
    nome: Optional[str] = Query(None, description="Buscar por nome ou matrícula do aluno"),
    mes: Optional[str] = Query(None, description="Filtrar por mês de vencimento (formato: YYYY-MM)"),
    db: Session = Depends(get_db)
):
    query = db.query(Pagamento)\
        .join(Inscricao)\
        .join(Aluno)
    
    if status_filter == 'pendente':
        query = query.filter(Pagamento.status == StatusPagamentoEnum.PENDENTE)
    elif status_filter == 'atrasado':
        query = query.filter(Pagamento.status == StatusPagamentoEnum.ATRASADO)
    else:
        query = query.filter(
            (Pagamento.status == StatusPagamentoEnum.PENDENTE) |
            (Pagamento.status == StatusPagamentoEnum.ATRASADO)
        )
    
    if nome:
        search_term = f"%{nome}%"
        query = query.filter(
            (Aluno.nome_completo.ilike(search_term)) |
            (Aluno.matricula.ilike(search_term))
        )
    
    if mes:
        # Filtrar por mês/ano de vencimento (formato: YYYY-MM)
        try:
            ano, mes_num = mes.split('-')
            ano = int(ano)
            mes_num = int(mes_num)
            query = query.filter(
                extract('year', Pagamento.data_vencimento) == ano,
                extract('month', Pagamento.data_vencimento) == mes_num
            )
        except (ValueError, AttributeError):
            pass  # Se formato inválido, ignora o filtro
    
    pagamentos = query\
        .order_by(
            Pagamento.status.desc(),  # ATRASADO antes de PENDENTE
            Pagamento.data_vencimento.asc()
        )\
        .offset(skip)\
        .limit(limit)\
        .all()
    result = []
    for pagamento in pagamentos:
        result.append({
            "id_pagamento": pagamento.id_pagamento,
            "id_inscricao": pagamento.id_inscricao,
            "aluno_nome": pagamento.inscricao.aluno.nome_completo,
            "aluno_matricula": pagamento.inscricao.aluno.matricula,
            "data_vencimento": pagamento.data_vencimento,
            "data_pagamento": pagamento.data_pagamento,
            "valor_total_devido": pagamento.valor_total_devido,
            "valor_total_pago": pagamento.valor_total_pago,
            "status": pagamento.status
        })
    return result
@router.get("/{id_pagamento}", summary="Buscar pagamento")
async def buscar_pagamento(
    id_pagamento: int,
    db: Session = Depends(get_db)
):
    pagamento = db.query(Pagamento).filter(
        Pagamento.id_pagamento == id_pagamento
    ).first()
    if not pagamento:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pagamento {id_pagamento} não encontrado"
        )
    itens_formatados = []
    for item in pagamento.itens:
        itens_formatados.append({
            "id_item": item.id_item,
            "id_pagamento": item.id_pagamento,
            "id_tipo_transacao": item.id_tipo_transacao,
            "descricao": item.descricao,
            "valor": item.valor
        })
    return {
        "id_pagamento": pagamento.id_pagamento,
        "id_inscricao": pagamento.id_inscricao,
        "data_vencimento": pagamento.data_vencimento,
        "valor_total_devido": pagamento.valor_total_devido,
        "data_pagamento": pagamento.data_pagamento,
        "valor_total_pago": pagamento.valor_total_pago,
        "status": pagamento.status,
        "itens": itens_formatados,
        "aluno_nome": pagamento.inscricao.aluno.nome_completo,
        "aluno_matricula": pagamento.inscricao.aluno.matricula,
        "plano_nome": pagamento.inscricao.plano.nome
    }
@router.post("/", response_model=PagamentoResponse, status_code=status.HTTP_201_CREATED, summary="Criar pagamento")
async def criar_pagamento(
    pagamento: PagamentoCreate,
    db: Session = Depends(get_db)
):
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == pagamento.id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {pagamento.id_inscricao} não encontrada"
        )
    novo_pagamento = Pagamento(
        id_inscricao=pagamento.id_inscricao,
        data_vencimento=pagamento.data_vencimento,
        valor_total_devido=pagamento.valor_total_devido,
        status=StatusPagamentoEnum.PENDENTE
    )
    db.add(novo_pagamento)
    db.flush()  # Para obter o ID
    for item in pagamento.itens:
        novo_item = ItemPagamento(
            id_pagamento=novo_pagamento.id_pagamento,
            id_tipo_transacao=item.id_tipo_transacao,
            descricao_item=item.descricao,
            valor=item.valor
        )
        db.add(novo_item)
    db.commit()
    db.refresh(novo_pagamento)
    return novo_pagamento
@router.put("/{id_pagamento}/pagar", response_model=PagamentoResponse, summary="Registrar pagamento")
async def registrar_pagamento(
    id_pagamento: int,
    pagamento_update: PagamentoUpdate,
    db: Session = Depends(get_db)
):
    pagamento = db.query(Pagamento).filter(
        Pagamento.id_pagamento == id_pagamento
    ).first()
    if not pagamento:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pagamento {id_pagamento} não encontrado"
        )
    if pagamento.status == StatusPagamentoEnum.PAGO:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Pagamento já foi registrado como pago"
        )
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == pagamento.id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inscrição não encontrada"
        )
    plano = db.query(Plano).filter(Plano.id_plano == inscricao.id_plano).first()
    if not plano:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plano não encontrado"
        )
    status_anterior = pagamento.status
    pagamento.data_pagamento = pagamento_update.data_pagamento
    pagamento.valor_total_pago = pagamento_update.valor_total_pago
    pagamento.status = pagamento_update.status
    if inscricao.status == StatusInscricaoEnum.PAUSADA:
        pagamentos_pendentes = db.query(func.count(Pagamento.id_pagamento))\
            .filter(
                Pagamento.id_inscricao == inscricao.id_inscricao,
                Pagamento.status != StatusPagamentoEnum.PAGO,
                Pagamento.id_pagamento != id_pagamento  # Excluir o pagamento atual que acabou de ser pago
            ).scalar()
        print(f" [PAGAR] Pagamentos pendentes/atrasados restantes (excluindo o atual): {pagamentos_pendentes}")
        if pagamentos_pendentes == 0:
            inscricao.status = StatusInscricaoEnum.ATIVA
            inscricao.data_fim = None
            ultimo_pagamento = db.query(Pagamento).filter(
                Pagamento.id_inscricao == inscricao.id_inscricao
            ).order_by(Pagamento.data_vencimento.desc()).first()
            if ultimo_pagamento:
                proxima_data_vencimento = ultimo_pagamento.data_vencimento + relativedelta(months=1)
                print(f" [PAGAR] Último pagamento: {ultimo_pagamento.data_vencimento.strftime('%m/%Y')}")
                print(f" [PAGAR] Próximo vencimento: {proxima_data_vencimento.strftime('%m/%Y')}")
            else:
                proxima_data_vencimento = date.today() + relativedelta(months=1)
                proxima_data_vencimento = proxima_data_vencimento.replace(day=10)
                print(f" [PAGAR] Nenhum pagamento encontrado. Usando próximo mês: {proxima_data_vencimento.strftime('%m/%Y')}")
            pagamento_pendente_existente = db.query(Pagamento).filter(
                Pagamento.id_inscricao == inscricao.id_inscricao,
                Pagamento.status == StatusPagamentoEnum.PENDENTE,
                func.extract('year', Pagamento.data_vencimento) == proxima_data_vencimento.year,
                func.extract('month', Pagamento.data_vencimento) == proxima_data_vencimento.month
            ).first()
            if not pagamento_pendente_existente:
                print(f" [PAGAR] Gerando mensalidade pendente para {proxima_data_vencimento.strftime('%m/%Y')}")
                novo_pagamento = Pagamento(
                    id_inscricao=inscricao.id_inscricao,
                    data_vencimento=proxima_data_vencimento,
                    valor_total_devido=plano.preco_mensal,
                    status=StatusPagamentoEnum.PENDENTE
                )
                db.add(novo_pagamento)
                db.flush()
                item_pagamento = ItemPagamento(
                    id_pagamento=novo_pagamento.id_pagamento,
                    id_tipo_transacao=1,  # Mensalidade
                    valor=plano.preco_mensal,
                    descricao_item=f"Mensalidade {plano.nome} - {proxima_data_vencimento.strftime('%m/%Y')}"
                )
                db.add(item_pagamento)
            else:
                print(f" [PAGAR] Pagamento pendente para {proxima_data_vencimento.strftime('%m/%Y')} já existe. Apenas reativando inscrição.")
    elif status_anterior == StatusPagamentoEnum.PENDENTE and inscricao.status == StatusInscricaoEnum.ATIVA:
        proxima_data_vencimento = pagamento.data_vencimento + relativedelta(months=1)
        proxima_data_vencimento = proxima_data_vencimento.replace(day=10)
        pagamento_existente = db.query(Pagamento).filter(
            Pagamento.id_inscricao == inscricao.id_inscricao,
            Pagamento.data_vencimento == proxima_data_vencimento
        ).first()
        if not pagamento_existente:
            print(f" [PAGAR] Criando mensalidade para {proxima_data_vencimento.strftime('%m/%Y')}")
            novo_pagamento = Pagamento(
                id_inscricao=inscricao.id_inscricao,
                data_vencimento=proxima_data_vencimento,
                valor_total_devido=plano.preco_mensal,
                status=StatusPagamentoEnum.PENDENTE
            )
            db.add(novo_pagamento)
            db.flush()
            item_pagamento = ItemPagamento(
                id_pagamento=novo_pagamento.id_pagamento,
                id_tipo_transacao=1,  # Mensalidade
                valor=plano.preco_mensal,
                descricao_item=f"Mensalidade {plano.nome} - {proxima_data_vencimento.strftime('%m/%Y')}"
            )
            db.add(item_pagamento)
        else:
            print(f" [PAGAR] Já existe pagamento para {proxima_data_vencimento.strftime('%m/%Y')}")
    db.commit()
    db.refresh(pagamento)
    return pagamento
@router.delete("/{id_pagamento}", status_code=status.HTTP_204_NO_CONTENT, summary="Excluir pagamento")
async def excluir_pagamento(
    id_pagamento: int,
    db: Session = Depends(get_db)
):
    pagamento = db.query(Pagamento).filter(
        Pagamento.id_pagamento == id_pagamento
    ).first()
    if not pagamento:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pagamento {id_pagamento} não encontrado"
        )
    db.delete(pagamento)
    db.commit()
    return None
