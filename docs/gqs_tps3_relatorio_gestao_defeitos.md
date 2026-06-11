# TPS 3 - Apresentação e Relatório da Gestão de Defeitos

## Software estudado

O software analisado foi o ConnectCRM, um aplicativo mobile desenvolvido em Flutter/Dart com Firebase Authentication e Cloud Firestore. O objetivo do app é permitir que pequenos empreendedores cadastrem clientes, acompanhem status no funil de vendas, registrem follow-ups e mantenham histórico de interações.

## Resumo executivo

No ciclo atual foram encontrados 6 defeitos. Todos foram corrigidos e retestados, resultando em 0 defeitos pendentes para a entrega. A matriz de execução terminou com 24 casos aprovados de 24, ou seja, taxa final de aprovação de 100%. Na primeira rodada, 19 casos estavam aprovados e 5 reprovados, representando 79% de aprovação inicial.

## Base teórica aplicada

- Teste de caixa preta: validação dos fluxos pelo comportamento visível do app, como login, cadastro, criação de cliente, busca, edição e exclusão.
- Teste de caixa branca: análise dos caminhos internos do código, principalmente repositório de clientes, regras de status, cálculo do funil e tratamento de erro.
- Teste de unidade e TDD: separação de regras de negócio para que funções pequenas possam ser testadas sem depender da interface.
- Teste de regressão e integração: repetição dos fluxos depois das correções para garantir que Firebase, Android e interface continuam funcionando juntos.

## Métricas de desempenho

| Métrica | Resultado |
|---|---:|
| Defeitos encontrados | 6 |
| Defeitos corrigidos | 6 |
| Defeitos pendentes | 0 |
| Casos de teste executados | 24 |
| Aprovação inicial | 79% |
| Aprovação final | 100% |

## Gravidade

| Gravidade | Quantidade | Interpretação |
|---|---:|---|
| Crítico | 1 | Impedia uso do app no Android/Firebase |
| Alto | 3 | Afetava persistência ou operações importantes |
| Médio | 2 | Afetava ambiente, apresentação ou clareza |
| Baixo | 0 | Nenhum defeito classificado como baixo |

## Matriz de execução

| Área | Casos | 1ª rodada | Após correção |
|---|---:|---|---|
| Autenticação | 5 | 4 aprovados / 1 reprovado | 5 aprovados / 0 reprovados |
| CRUD de clientes | 8 | 6 aprovados / 2 reprovados | 8 aprovados / 0 reprovados |
| Funil e lembretes | 5 | 5 aprovados / 0 reprovados | 5 aprovados / 0 reprovados |
| Histórico de interações | 4 | 2 aprovados / 2 reprovados | 4 aprovados / 0 reprovados |
| Android/Firebase | 2 | 2 aprovados / 0 reprovados | 2 aprovados / 0 reprovados |

## Detalhes dos defeitos

| ID | Descrição | Gravidade | Prioridade | Responsável | Status |
|---|---|---|---|---|---|
| D-001 | Android carregava login/cadastro sem concluir por permissão/conexão Firebase | Crítico | Bloqueante | Pedro | Fechado |
| D-002 | Cadastro podia autenticar, mas travar ao salvar dados complementares | Alto | Imediata | Pedro | Fechado |
| D-003 | Excluir cliente falhava quando havia histórico/subcoleção protegida | Alto | Imediata | Pedro | Fechado |
| D-004 | Registrar interação falhava com regras Firestore não publicadas para subcoleção | Alto | Imediata | Pedro | Fechado |
| D-005 | SDK/AVD incompleto impedia simulação Android | Médio | Alta | Pedro | Fechado |
| D-006 | Saudação inicial podia mostrar nome genérico | Médio | Normal | Pedro | Fechado |

## Evidências e automação

Foram usados comandos e verificações locais para apoiar a qualidade do projeto, principalmente análise estática do Dart, execução do app em dispositivo Android real e validação da integração com Firebase. A automação reduz erro manual porque permite repetir verificações depois de cada correção.

## Conclusão

A gestão de defeitos mostrou que o ConnectCRM evoluiu de uma aplicação funcional para uma entrega mais controlada e confiável. Os defeitos foram classificados, corrigidos e retestados. O resultado final atende ao objetivo do trabalho: apresentar uma visão executiva do ciclo, KPIs de defeitos, matriz de execução e detalhes rastreáveis dos problemas encontrados.
