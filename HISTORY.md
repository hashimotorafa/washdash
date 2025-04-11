# WashDash - Histórico do Projeto

## Sobre o Projeto
O WashDash é um sistema desenvolvido para gerenciar e monitorar operações de lavanderias self-service, com foco especial na integração com a rede Wash&Go. O projeto visa automatizar e otimizar processos de importação de dados, gestão de clientes e monitoramento de ciclos de lavagem/secagem.

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