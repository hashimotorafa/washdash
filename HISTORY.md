# WashDash - Histórico do Projeto

## Sobre o Projeto
O WashDash é um sistema desenvolvido para gerenciar e monitorar operações de lavanderias self-service, com foco especial na integração com a rede Wash&Go. O projeto visa automatizar e otimizar processos de importação de dados, gestão de clientes e monitoramento de ciclos de lavagem e secagem.

## Padrões de Código

### Estrutura do Projeto
- Organização modular com namespaces claros (ex: `DataImporters::WashAndGo`)
- Separação de responsabilidades em serviços específicos
- Utilização de módulos para agrupar funcionalidades relacionadas
- Estrutura de views aninhadas com partials reutilizáveis

### Convenções de Nomenclatura
- Classes em PascalCase (ex: `IncomeStatement`)
- Métodos em snake_case (ex: `find_or_initialize_customer`)
- Constantes em UPPER_SNAKE_CASE
- Partials com prefixo underscore (ex: `_form.html.erb`)

### Padrões de Implementação
1. **Importação de Dados**
   - Uso da gem `roo` para processamento de arquivos Excel
   - Implementação de importação em lote com `upsert_all`
   - Tratamento de erros com blocos `rescue`

2. **Gestão de Clientes**
   - Padrão de busca ou inicialização com `find_or_initialize_by`
   - Validação de dados antes da persistência
   - Logging de erros para debugging

3. **Processamento de Dados**
   - Extração de dados estruturados de linhas do Excel
   - Normalização de dados (ex: separação de área de código e número de telefone)
   - Conversão de tipos de dados apropriada

4. **Interface do Usuário**
   - Uso do CoreUI para layout responsivo e componentes
   - Modais para ações CRUD
   - Turbo Frames para atualizações dinâmicas
   - Flash messages para feedback ao usuário
   - Design system consistente seguindo padrões do CoreUI

### Boas Práticas
- Documentação clara com comentários explicativos
- Métodos privados para encapsulamento de lógica interna
- Tratamento de casos especiais e erros
- Uso de constantes para valores fixos
- Validação de dados antes do processamento
- Organização de formulários em layouts intuitivos
- Feedback visual para ações do usuário
- Consistência visual usando componentes CoreUI

## Evolução do Projeto

### Funcionalidades Implementadas
1. **Gestão Financeira**
   - Demonstração de Resultados (DRE)
   - Controle de custos e despesas
   - Importação de relatórios financeiros
   - Métricas de desempenho

2. **Interface do Usuário**
   - Layout responsivo com CoreUI
   - Componentes modernos do CoreUI
   - Modais para formulários
   - Atualizações dinâmicas com Turbo
   - Mensagens de feedback
   - Design system padronizado

### Próximos Passos
O projeto está estruturado para permitir:
- Integração com outras redes de lavanderias
- Expansão de funcionalidades
- Manutenção e escalabilidade do código
- Melhorias contínuas na experiência do usuário
- Evolução do design system

## Tecnologias Principais
- Ruby on Rails
- Hotwire (Turbo e Stimulus)
- CoreUI
- PostgreSQL (banco de dados)
- Roo (processamento de Excel)
- Chartkick (visualização de dados e gráficos)
- Groupdate (agrupamento e análise temporal de dados)

## Estrutura do Banco de Dados

### Tabelas Principais

1. **Stores (Lojas)**
   - Representa as unidades de lavanderia
   - Campos principais: nome, endereço, CNPJ, configurações
   - Relacionamentos:
     - has_many :customers (clientes)
     - has_many :cycles (ciclos)
     - has_many :costs (custos)
     - has_many :transactions (transações)

2. **Customers (Clientes)**
   - Armazena informações dos clientes
   - Campos principais: nome, email, telefone, status
   - Relacionamentos:
     - belongs_to :store (loja)
     - has_many :cycles (ciclos)
     - has_many :transactions (transações)

3. **Cycles (Ciclos)**
   - Registra cada ciclo de operação (lavagem ou secagem)
   - Campos principais:
     - machine_type (tipo de máquina: lavadora/secadora)
     - status (pendente, em_andamento, concluído, cancelado)
     - price (preço)
     - started_at (início)
     - finished_at (término)
   - Relacionamentos:
     - belongs_to :store (loja)
     - belongs_to :customer (cliente)
     - has_one :transaction (transação)

4. **Transactions (Transações)**
   - Controla as transações financeiras
   - Campos principais: valor, data, tipo, status
   - Relacionamentos:
     - belongs_to :store (loja)
     - belongs_to :customer (cliente)
     - belongs_to :cycle (ciclo)

5. **Costs (Custos)**
   - Gerencia custos e despesas da operação
   - Campos principais: descrição, valor, categoria, data
   - Relacionamentos:
     - belongs_to :store (loja)
     - belongs_to :cost_category (categoria)

### Tabelas de Suporte

1. **CostCategories (Categorias de Custo)**
   - Categorização dos custos e despesas
   - Campos principais: nome, descrição, tipo
   - Relacionamentos:
     - has_many :costs (custos)

2. **Settings (Configurações)**
   - Configurações específicas por loja
   - Campos principais: chave, valor, tipo
   - Relacionamentos:
     - belongs_to :store (loja)

### Características do Schema

1. **Índices Otimizados**
   - Índices em chaves estrangeiras
   - Índices compostos para buscas frequentes
   - Índices para campos de ordenação comum

2. **Constraints de Integridade**
   - Chaves estrangeiras com delete cascade quando apropriado
   - Validações de unicidade
   - Checks para valores válidos

3. **Campos Temporais**
   - Timestamps padrão (created_at, updated_at)
   - Campos específicos para datas de negócio
   - Suporte a timezone

### Gems para Análise de Dados
1. **Chartkick**
   - Geração de gráficos interativos
   - Integração com JavaScript moderno
   - Suporte a diversos tipos de visualizações
   - Customização flexível de aparência

2. **Groupdate**
   - Agrupamento inteligente de dados por períodos
   - Suporte a diferentes granularidades (hora, dia, semana, mês)
   - Tratamento automático de fusos horários
   - Otimização de queries no PostgreSQL

# Histórico de Alterações

### Adicionado
- Implementação inicial do sistema de lavanderia
- Funcionalidades básicas de gerenciamento de ciclos
- Interface de usuário com CoreUI
- Autenticação de usuários
- Relatórios e métricas básicas

### Melhorias
- Otimização de consultas no banco de dados
- Melhoria na performance das views
- Refatoração de código para melhor manutenibilidade
- Adição de testes automatizados
- Implementação de boas práticas de desenvolvimento

### Observações
- É recomendado utilizar scopes ao invés de escrever queries Active Record diretamente nos controllers para melhor organização e reutilização do código

## 📈 Métricas de Negócio Relevantes - WashDash

Estas métricas foram definidas para apoiar decisões estratégicas baseadas em dados e garantir a prosperidade das lavanderias self-service integradas ao WashDash. Elas estão organizadas em três categorias principais:

### 💰 Financeiras
- **Faturamento Mensal por Loja**: Total de transações concluídas por loja/mês.
- **Lucro Operacional (DRE)**: Faturamento menos custos fixos e variáveis.
- **Ticket Médio por Cliente**: Valor médio gasto por cliente.
- **Custo por Ciclo**: Custo total dividido pelo número de ciclos executados.
- **Taxa de Estorno**: Proporção de transações canceladas ou estornadas.

### ⚙️ Operacionais
- **Ciclos por Máquina por Dia**: Volume de uso diário por tipo de máquina.
- **Tempo Médio de Ciclo**: Tempo médio de execução dos ciclos.
- **Taxa de Ocupação por Máquina**: Proporção de tempo que a máquina esteve em uso.
- **Ciclos Cancelados vs Concluídos**: Indicador de falhas operacionais.
- **Custos por Categoria**: Agrupamento dos custos por tipo (água, energia, manutenção etc).

### 👥 Relacionamento com o Cliente
- **Clientes Ativos por Mês**: Clientes que utilizaram ao menos um ciclo no mês.
- **Frequência Média por Cliente**: Número médio de ciclos por cliente/mês.
- **Tempo Médio desde Último Uso**: Identificação de clientes inativos.
- **Churn de Clientes**: Percentual de clientes que não retornam após certo período.
- **Clientes por Código de Área**: Distribuição geográfica da base de clientes.

### 🎯 Uso Estratégico
Essas métricas permitem:
- Identificar gargalos operacionais e oportunidades de otimização
- Monitorar saúde financeira das lojas
- Melhorar a retenção e engajamento dos clientes
- Guiar ações promocionais e decisões de expansão

# Histórico de Versões

## [0.1.0] - 2024-03-19

### Adicionado
- Implementação inicial do sistema
- Estrutura básica do projeto
- Configuração do ambiente de desenvolvimento
- Sistema de autenticação básico
- Sistema de busca de clientes
- Gráficos de métricas de clientes
- Filtros por período
- Ordenação de resultados
- Paginação de resultados
- Importação automática de dados do Wash&Go
- Pesquisa por data de cadastro (first_cycle_date)
- Pesquisa por período de uso

### Modificado
- Melhorias na interface de usuário
- Otimização de queries
- Refatoração de código
- Melhorias na performance
- Atualização de dependências

### Corrigido
- Correção de bugs
- Correção de vulnerabilidades
- Correção de problemas de performance
- Correção de problemas de usabilidade

### Removido
- Código obsoleto
- Dependências não utilizadas
- Funcionalidades descontinuadas

### Notas Técnicas
- O sistema utiliza uma estrutura onde usuários (customers) e lojas (stores) são relacionados exclusivamente através da tabela de ciclos (cycles)
- Um mesmo usuário pode ter ciclos em múltiplas lojas diferentes
- A data de "cadastro" de um usuário em cada loja é determinada pelo primeiro ciclo registrado
- Todas as queries e métricas são sempre no contexto de uma loja específica
- Não há relação direta entre usuários e lojas, apenas através dos ciclos
- Essa estrutura permite que um usuário ter diferentes padrões de uso e histórico em cada loja
- As métricas e estatísticas são calculadas considerando apenas os ciclos da loja em questão
- O sistema foi projetado para lidar com essa relação muitos-para-muitos entre usuários e lojas
- Os dados de clientes, ciclos e transações são importados automaticamente do sistema Wash&Go
- Não há interface para criação ou edição manual desses dados

### Funcionalidades Pendentes
- Gestão financeira completa
- Sistema de relatórios detalhados
- Integração com outras redes de lavanderias

### TODO
- Adicionar índices compostos para otimização de queries:
  - (customer_id, store_id, created_at) na tabela cycles
  - (store_id, created_at) na tabela cycles
  - Índices para campos frequentemente usados em buscas

### Design System - Store Area

#### Layout e Estrutura
- Container fluido para conteúdo principal (`container-fluid`)
- Sistema de grid responsivo com Bootstrap
- Sidebar responsiva com largura de 16rem (`--cui-sidebar-width: 16rem`)
- Cards sem borda por padrão (`border-0`)
- Sombras suaves em cards (`shadow-sm`)

#### Componentes
1. **Cards**
   - Cabeçalho transparente (`bg-transparent`)
   - Sem bordas por padrão (`border-0`)
   - Efeito hover com sombra suave
   - Transição suave em interações (`transition: all 0.2s ease-in-out`)

2. **Formulários**
   - Labels flutuantes com estilo personalizado
   - Foco sem outline padrão (`box-shadow: none`)
   - Background light no foco (`background-color: var(--bs-light)`)
   - Cores de texto em cinza médio (`var(--bs-gray-500)`)

3. **Navegação**
   - Sidebar com links flexbox alinhados
   - Ícones com margem direita (`margin-right: 0.5rem`)
   - Estados hover e active com background semi-transparente
   - Agrupamento de itens com indentação

4. **Botões**
   - Grupo de botões para ações relacionadas
   - Tooltips em botões de ação
   - Ícones com classes Font Awesome e CoreUI Icons
   - Variantes: primary, secondary, outline, danger

5. **Tabelas**
   - Responsivas com scroll horizontal
   - Bordas suaves
   - Striped rows para melhor legibilidade
   - Alinhamento de ações à direita

6. **Gráficos e Métricas**
   - Cards dedicados para visualizações
   - Altura fixa para gráficos (300px)
   - Cores consistentes para diferentes tipos de dados
   - Layout flexbox para métricas com ícones

7. **Modais**
   - Cabeçalho com fundo light
   - Ícones nos títulos
   - Botões de ação alinhados à direita
   - Formulários com espaçamento consistente

#### Cores e Tipografia
- Uso de variáveis CSS do Bootstrap
- Texto em cinza médio para labels e descrições
- Ícones com cores semânticas (success, primary, warning, danger)
- Títulos com pesos e tamanhos consistentes

#### Interatividade
- Transições suaves em hover states
- Feedback visual em interações
- Tooltips para ações secundárias
- Confirmações para ações destrutivas