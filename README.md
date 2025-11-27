# Sudoeste Fight - Sistema de Gerenciamento de Academia

Sistema completo de gerenciamento de academia de lutas com controle de alunos, inscrições, pagamentos e métricas financeiras em tempo real.​‌​​​‌​‌​‌‌‌​​‌‌​‌‌‌​‌​​​‌‌​​‌​‌​​‌​​​​​​‌‌‌​​​​​‌‌‌​​‌​​‌‌​‌‌‌‌​‌‌​‌​‌​​‌‌​​‌​‌​‌‌‌​‌​​​‌‌​‌‌‌‌​​‌​​​​​​‌‌‌​​‌​​‌‌​​‌​‌​‌‌​​​‌‌​‌‌​​‌​‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌‌​‌​‌​​‌​​​​​​‌‌​​​​‌​‌‌‌​​​​​‌‌‌​​‌​​‌‌​‌‌‌‌​‌‌‌‌​​​​‌‌​‌​​‌​‌‌​‌‌​‌​‌‌​​​​‌​‌‌​​‌​​​‌‌​​​​‌​‌‌​‌‌​‌​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌‌​‌​​​‌‌​​‌​‌​​‌​​​​​​​‌‌​​‌​​​‌‌​​​​​​‌​​​​​​‌‌​​​​‌​​‌​​​​​​​‌‌​​‌‌​​‌‌​​​​​​‌​​​​​​‌‌‌​​​​​‌‌​‌‌‌‌​‌‌‌​​‌​​​‌​​​​​​‌‌​​​‌‌​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌‌​‌​​​‌‌​‌‌‌‌​​‌​​​​​​‌‌​​‌​​​‌‌​​‌​‌​​‌​​​​​​‌‌​​​​‌​‌‌‌​​‌‌​‌‌‌​​‌‌​‌‌​‌​​‌​‌‌‌​​‌‌​‌‌‌​‌​​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​‌​‌‌​​​​‌​​‌​​​​​​‌‌​​‌​​​‌‌​​‌​‌​​‌​​​​​​‌​​‌​​‌​‌​​​​​‌​​‌​‌‌‌​

## Como Executar o Projeto

### Pré-requisitos

Você só precisa ter o **Docker** instalado na sua máquina:

- [Docker Desktop para Windows](https://www.docker.com/products/docker-desktop)
- [Docker Desktop para Mac](https://www.docker.com/products/docker-desktop)
- [Docker para Linux](https://docs.docker.com/engine/install/)

> **Nota**: O Docker Desktop já inclui o Docker Compose automaticamente.

### Passo a Passo

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/Sudoeste-Fight.git
cd Sudoeste-Fight
```

2. **Suba o projeto**
```bash
docker-compose up -d
```

3. **Aguarde a inicialização** (cerca de 30 segundos)

Pronto! O sistema está rodando com dados de demonstração já carregados.

### Acessar o Sistema

- **Frontend (Aplicação Web)**: http://localhost:8081
- **API Backend**: http://localhost:8001
- **Documentação Interativa (Swagger)**: http://localhost:8001/docs
- **Banco de Dados PostgreSQL**: localhost:5436

### Credenciais de Acesso

**Login do Sistema:**
- Usuário: `admin`
- Senha: `admin123`

**Banco de Dados:**
- Host: `localhost`
- Porta: `5436`
- Usuário: `gym_admin`
- Senha: `admin123`
- Database: `gym_db`

## Dados de Demonstração

O sistema já vem populado com dados realistas para você testar:

- **229 alunos** cadastrados
- **886 inscrições** (ativas, pausadas e canceladas)
- **2.913 pagamentos** com diversos status
- **4 modalidades** de luta (Muay Thai, Jiu-Jitsu, Boxe, Judô)
- **3 planos** de mensalidade (Mensal, Trimestral, Semestral)
- **5 unidades** cadastradas

## Comandos Úteis

**Parar o projeto:**
```bash
docker-compose down
```

**Parar e remover todos os dados (reiniciar do zero):**
```bash
docker-compose down -v
docker-compose up -d
```

**Ver logs em tempo real:**
```bash
# Todos os serviços
docker-compose logs -f

# Serviço específico
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

**Reiniciar um serviço:**
```bash
docker-compose restart backend
```

**Reconstruir as imagens:**
```bash
docker-compose up -d --build
```
## Tecnologias Utilizadas

**Backend:**
- Python 3.11
- FastAPI (framework web)
- SQLAlchemy (ORM)
- PostgreSQL 15
- Uvicorn (servidor ASGI)

**Frontend:**
- React Native (Expo)
- TypeScript
- React Navigation
- Expo Router

**DevOps:**
- Docker & Docker Compose
- PostgreSQL (Alpine Linux)

## Funcionalidades

### Gestão de Alunos
- Cadastro completo com validação de CPF
- Filtros por status (ativo/inativo)
- Busca por nome ou matrícula
- Histórico completo de inscrições e pagamentos

### Gestão de Inscrições
- Múltiplos planos (Mensal, Trimestral, Semestral)
- Múltiplas modalidades (Muay Thai, Jiu-Jitsu, Boxe, Judô)
- Status: ATIVA, PAUSADA, CANCELADA
- Mudança de plano com recálculo automático

### Gestão de Pagamentos
- Geração automática mensal
- Status: PENDENTE, ATRASADO, PAGO
- Controle de vencimentos
- Registro de pagamentos com data e valor

### Métricas e Dashboard
- Total de alunos e inscrições ativas
- Receita mensal e acumulada
- Taxa de inadimplência
- Distribuição por planos
- Modalidades mais populares
