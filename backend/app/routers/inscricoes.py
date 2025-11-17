
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from datetime import date
from dateutil.relativedelta import relativedelta
from app.core.database import get_db
from app.models.models import Inscricao, Aluno, Plano, StatusInscricaoEnum, Pagamento, StatusPagamentoEnum
from app.schemas.inscricao import (
    InscricaoCreate,
    InscricaoUpdate,
    InscricaoResponse,
    InscricaoListResponse,
    InscricaoDetalhada
)
router = APIRouter(
    prefix="/inscricoes",
    tags=["Inscrições"],
)
@router.get("/", response_model=List[InscricaoListResponse], summary="Listar inscrições")
async def listar_inscricoes(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    status_filtro: Optional[str] = Query(None, description="Filtrar por status"),
    aluno_matricula: Optional[str] = Query(None, description="Filtrar por aluno"),
    db: Session = Depends(get_db)
):
    query = db.query(Inscricao).join(Aluno).join(Plano)
    if status_filtro:
        query = query.filter(Inscricao.status == status_filtro)
    if aluno_matricula:
        query = query.filter(Inscricao.id_aluno == aluno_matricula)
    inscricoes = query.offset(skip).limit(limit).all()
    result = []
    for inscricao in inscricoes:
        result.append({
            "id_inscricao": inscricao.id_inscricao,
            "aluno_nome": inscricao.aluno.nome_completo,
            "aluno_matricula": inscricao.aluno.matricula,
            "plano_nome": inscricao.plano.nome,
            "data_inicio": inscricao.data_inicio,
            "status": inscricao.status
        })
    return result
@router.get("/{id_inscricao}", response_model=InscricaoDetalhada, summary="Buscar inscrição")
async def buscar_inscricao(
    id_inscricao: int,
    db: Session = Depends(get_db)
):
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    from app.models.models import Pagamento
    from sqlalchemy import func
    stats = db.query(
        func.count(Pagamento.id_pagamento).label("total"),
        func.coalesce(func.sum(Pagamento.valor_total_pago), 0).label("valor_pago")
    ).filter(
        Pagamento.id_inscricao == id_inscricao
    ).first()
    return {
        "id_inscricao": inscricao.id_inscricao,
        "aluno_nome": inscricao.aluno.nome_completo,
        "aluno_matricula": inscricao.aluno.matricula,
        "plano_nome": inscricao.plano.nome,
        "plano_preco": inscricao.plano.preco_mensal,
        "data_inicio": inscricao.data_inicio,
        "data_fim": inscricao.data_fim,
        "status": inscricao.status,
        "total_pagamentos": stats.total,
        "valor_pago": stats.valor_pago
    }
@router.get("/{id_inscricao}/modalidades", summary="Listar modalidades da inscrição")
async def listar_modalidades_inscricao(
    id_inscricao: int,
    db: Session = Depends(get_db)
):
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    from app.models.models import InscricaoModalidade, Modalidade
    modalidades = db.query(Modalidade).join(
        InscricaoModalidade,
        InscricaoModalidade.id_modalidade == Modalidade.id_modalidade
    ).filter(
        InscricaoModalidade.id_inscricao == id_inscricao
    ).all()
    return [{
        "id_modalidade": m.id_modalidade,
        "nome": m.nome,
        "descricao": m.descricao,
        "categoria": m.categoria
    } for m in modalidades]
@router.post("/", response_model=InscricaoResponse, status_code=status.HTTP_201_CREATED, summary="Criar inscrição")
async def criar_inscricao(
    inscricao: InscricaoCreate,
    db: Session = Depends(get_db)
):
    aluno = db.query(Aluno).filter(Aluno.matricula == inscricao.id_aluno).first()
    if not aluno:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Aluno {inscricao.id_aluno} não encontrado"
        )
    plano = db.query(Plano).filter(Plano.id_plano == inscricao.id_plano).first()
    if not plano:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Plano {inscricao.id_plano} não encontrado"
        )
    inscricao_ativa = db.query(Inscricao).filter(
        Inscricao.id_aluno == inscricao.id_aluno,
        Inscricao.status == StatusInscricaoEnum.ATIVA
    ).first()
    if inscricao_ativa:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Aluno já possui inscrição ativa (ID: {inscricao_ativa.id_inscricao})"
        )
    nova_inscricao = Inscricao(
        id_aluno=inscricao.id_aluno,
        id_plano=inscricao.id_plano,
        id_unidade=1,  # Unidade padrão (pode ser alterada depois)
        data_inicio=inscricao.data_inicio,
        status=StatusInscricaoEnum.ATIVA
    )
    db.add(nova_inscricao)
    db.commit()
    db.refresh(nova_inscricao)
    return nova_inscricao
@router.put("/{id_inscricao}", response_model=InscricaoResponse, summary="Atualizar inscrição")
async def atualizar_inscricao(
    id_inscricao: int,
    inscricao_update: InscricaoUpdate,
    db: Session = Depends(get_db)
):
    print(f" [ATUALIZAR_INSCRICAO] ID: {id_inscricao}")
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    plano_antigo_id = inscricao.id_plano
    if inscricao_update.id_plano and inscricao_update.id_plano != plano_antigo_id:
        print(f"� [ATUALIZAR_INSCRICAO] Mudança de plano: {plano_antigo_id} → {inscricao_update.id_plano}")
        plano_novo = db.query(Plano).filter(Plano.id_plano == inscricao_update.id_plano).first()
        if not plano_novo:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Plano {inscricao_update.id_plano} não encontrado"
            )
        inscricao.id_plano = inscricao_update.id_plano
        pagamentos_pendentes = db.query(Pagamento).filter(
            Pagamento.id_inscricao == id_inscricao,
            Pagamento.status == StatusPagamentoEnum.PENDENTE
        ).all()
        total_atualizados = len(pagamentos_pendentes)
        if total_atualizados > 0:
            print(f" [ATUALIZAR_INSCRICAO] Atualizando {total_atualizados} pagamentos pendentes")
            print(f" [ATUALIZAR_INSCRICAO] Valor antigo: R$ {pagamentos_pendentes[0].valor_total_devido}")
            print(f" [ATUALIZAR_INSCRICAO] Valor novo: R$ {plano_novo.preco_mensal}")
            for pagamento in pagamentos_pendentes:
                pagamento.valor_total_devido = plano_novo.preco_mensal
            print(f" [ATUALIZAR_INSCRICAO] {total_atualizados} pagamentos atualizados com sucesso!")
        else:
            print(f" [ATUALIZAR_INSCRICAO] Nenhum pagamento pendente encontrado para atualizar")
    if inscricao_update.status:
        print(f"� [ATUALIZAR_INSCRICAO] Mudança de status: {inscricao.status} → {inscricao_update.status}")
        if inscricao.status == StatusInscricaoEnum.CANCELADA and inscricao_update.status == StatusInscricaoEnum.ATIVA:
            print(f"� [REATIVACAO] Tentando reativar inscrição cancelada {id_inscricao}")
            pagamentos_nao_pagos = db.query(func.count(Pagamento.id_pagamento))\
                .filter(
                    Pagamento.id_inscricao == id_inscricao,
                    Pagamento.status != StatusPagamentoEnum.PAGO
                ).scalar()
            if pagamentos_nao_pagos > 0:
                print(f" [REATIVACAO] Bloqueado! Existem {pagamentos_nao_pagos} pagamentos não pagos")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Não é possível reativar a inscrição. Existem {pagamentos_nao_pagos} mensalidades não pagas (pendentes ou atrasadas)."
                )
            print(f" [REATIVACAO] Todas as mensalidades estão pagas! Reativando...")
            inscricao.status = StatusInscricaoEnum.ATIVA
            inscricao.data_fim = None
            plano_atual = db.query(Plano).filter(Plano.id_plano == inscricao.id_plano).first()
            if not plano_atual:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Plano {inscricao.id_plano} não encontrado"
                )
            ultimo_pagamento = db.query(Pagamento).filter(
                Pagamento.id_inscricao == id_inscricao
            ).order_by(Pagamento.data_vencimento.desc()).first()
            if ultimo_pagamento:
                proxima_data_vencimento = ultimo_pagamento.data_vencimento + relativedelta(months=1)
                print(f" [REATIVACAO] Último pagamento: {ultimo_pagamento.data_vencimento.strftime('%m/%Y')} ({ultimo_pagamento.status})")
                print(f" [REATIVACAO] Próximo vencimento calculado: {proxima_data_vencimento.strftime('%m/%Y')}")
            else:
                proxima_data_vencimento = date.today() + relativedelta(months=1)
                proxima_data_vencimento = proxima_data_vencimento.replace(day=10)
                print(f" [REATIVACAO] Nenhum pagamento encontrado. Usando próximo mês: {proxima_data_vencimento.strftime('%m/%Y')}")
            pagamento_pendente_existente = db.query(Pagamento).filter(
                Pagamento.id_inscricao == id_inscricao,
                Pagamento.status == StatusPagamentoEnum.PENDENTE,
                func.extract('year', Pagamento.data_vencimento) == proxima_data_vencimento.year,
                func.extract('month', Pagamento.data_vencimento) == proxima_data_vencimento.month
            ).first()
            if not pagamento_pendente_existente:
                novo_pagamento = Pagamento(
                    id_inscricao=id_inscricao,
                    data_vencimento=proxima_data_vencimento,
                    valor_total_devido=plano_atual.preco_mensal,
                    status=StatusPagamentoEnum.PENDENTE,
                    data_pagamento=None,
                    valor_total_pago=None
                )
                db.add(novo_pagamento)
                print(f" [REATIVACAO] Novo pagamento pendente gerado: {proxima_data_vencimento.strftime('%m/%Y')} - R$ {plano_atual.preco_mensal}")
            else:
                print(f" [REATIVACAO] Pagamento pendente para {proxima_data_vencimento.strftime('%m/%Y')} já existe")
        else:
            inscricao.status = inscricao_update.status
            if inscricao_update.status == StatusInscricaoEnum.PAUSADA:
                inscricao.data_fim = None
                print(f" [PAUSAR] Inscrição pausada (temporariamente). data_fim removida.")
            elif inscricao_update.status == StatusInscricaoEnum.CANCELADA:
                if not inscricao_update.data_fim and not inscricao.data_fim:
                    inscricao.data_fim = date.today()
                print(f" [CANCELAR] Inscrição cancelada definitivamente. data_fim: {inscricao.data_fim}")
            elif inscricao_update.status == StatusInscricaoEnum.ATIVA:
                inscricao.data_fim = None
                print(f" [ATIVAR] Inscrição ativa. data_fim removida.")
    if inscricao_update.data_fim:
        if inscricao.status == StatusInscricaoEnum.CANCELADA:
            inscricao.data_fim = inscricao_update.data_fim
        else:
            print(f" [ATUALIZAR_INSCRICAO] Tentativa de definir data_fim para status {inscricao.status} ignorada")
    db.commit()
    db.refresh(inscricao)
    print(f" [ATUALIZAR_INSCRICAO] Inscrição {id_inscricao} atualizada com sucesso!")
    return inscricao
@router.delete("/{id_inscricao}/cancelar", summary="Cancelar inscrição (mantém débitos atrasados)")
async def cancelar_inscricao(
    id_inscricao: int,
    db: Session = Depends(get_db)
):
    from app.models.models import Pagamento, StatusPagamentoEnum
    from datetime import date
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    pagamentos_pendentes = db.query(Pagamento).filter(
        Pagamento.id_inscricao == id_inscricao,
        Pagamento.status == StatusPagamentoEnum.PENDENTE
    ).all()
    boletos_destruidos = len(pagamentos_pendentes)
    print(f" Destruindo {boletos_destruidos} boletos pendentes da inscrição {id_inscricao}...")
    for pagamento in pagamentos_pendentes:
        db.delete(pagamento)
    boletos_atrasados = db.query(Pagamento).filter(
        Pagamento.id_inscricao == id_inscricao,
        Pagamento.status == StatusPagamentoEnum.ATRASADO
    ).count()
    print(f" Mantendo {boletos_atrasados} boletos atrasados como débito...")
    inscricao.status = StatusInscricaoEnum.CANCELADA
    inscricao.data_fim = date.today()
    db.commit()
    print(f" Inscrição {id_inscricao} cancelada. Status: CANCELADA, data_fim: {inscricao.data_fim}")
    return {
        "mensagem": "Inscrição cancelada com sucesso",
        "boletos_pendentes_destruidos": boletos_destruidos,
        "boletos_atrasados_mantidos": boletos_atrasados
    }
@router.delete("/{id_inscricao}", status_code=status.HTTP_204_NO_CONTENT, summary="Excluir inscrição")
async def excluir_inscricao(
    id_inscricao: int,
    db: Session = Depends(get_db)
):
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    db.delete(inscricao)
    db.commit()
    return None
@router.post("/{id_inscricao}/modalidades/{id_modalidade}", status_code=status.HTTP_201_CREATED, summary="Adicionar modalidade à inscrição")
async def adicionar_modalidade_inscricao(
    id_inscricao: int,
    id_modalidade: int,
    db: Session = Depends(get_db)
):
    from app.models.models import InscricaoModalidade, Modalidade
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    modalidade = db.query(Modalidade).filter(
        Modalidade.id_modalidade == id_modalidade
    ).first()
    if not modalidade:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Modalidade {id_modalidade} não encontrada"
        )
    existe = db.query(InscricaoModalidade).filter(
        InscricaoModalidade.id_inscricao == id_inscricao,
        InscricaoModalidade.id_modalidade == id_modalidade
    ).first()
    if existe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Modalidade já está associada a esta inscrição"
        )
    nova_inscricao_modalidade = InscricaoModalidade(
        id_inscricao=id_inscricao,
        id_modalidade=id_modalidade
    )
    db.add(nova_inscricao_modalidade)
    db.commit()
    return {"message": "Modalidade adicionada com sucesso"}
@router.delete("/{id_inscricao}/modalidades/{id_modalidade}", status_code=status.HTTP_204_NO_CONTENT, summary="Remover modalidade da inscrição")
async def remover_modalidade_inscricao(
    id_inscricao: int,
    id_modalidade: int,
    db: Session = Depends(get_db)
):
    from app.models.models import InscricaoModalidade
    inscricao_modalidade = db.query(InscricaoModalidade).filter(
        InscricaoModalidade.id_inscricao == id_inscricao,
        InscricaoModalidade.id_modalidade == id_modalidade
    ).first()
    if not inscricao_modalidade:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Modalidade {id_modalidade} não encontrada na inscrição {id_inscricao}"
        )
    db.delete(inscricao_modalidade)
    db.commit()
    return None
@router.put("/{id_inscricao}/modalidades", summary="Atualizar modalidades da inscrição")
async def atualizar_modalidades_inscricao(
    id_inscricao: int,
    modalidades_ids: list[int],
    db: Session = Depends(get_db)
):
    from app.models.models import InscricaoModalidade, Modalidade
    inscricao = db.query(Inscricao).filter(
        Inscricao.id_inscricao == id_inscricao
    ).first()
    if not inscricao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inscrição {id_inscricao} não encontrada"
        )
    db.query(InscricaoModalidade).filter(
        InscricaoModalidade.id_inscricao == id_inscricao
    ).delete()
    for id_modalidade in modalidades_ids:
        modalidade = db.query(Modalidade).filter(
            Modalidade.id_modalidade == id_modalidade
        ).first()
        if not modalidade:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Modalidade {id_modalidade} não encontrada"
            )
        nova = InscricaoModalidade(
            id_inscricao=id_inscricao,
            id_modalidade=id_modalidade
        )
        db.add(nova)
    db.commit()
    return {"message": f"Modalidades atualizadas: {len(modalidades_ids)} modalidades ativas"}
    return {"message": f"Modalidades atualizadas: {len(modalidades_ids)} modalidades ativas"}
