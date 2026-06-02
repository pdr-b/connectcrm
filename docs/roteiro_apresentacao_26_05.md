# ConnectCRM - Roteiro para a entrega de 26/05/2026

## O que sera cobrado amanha

Segundo o cronograma, a entrega de **26/05/2026** pede:

> Todas as telas implementadas no Flutter/Dart, com navegacao entre elas.

O projeto local ja atende essa entrega e esta adiantado em relacao a proxima etapa:

- Todas as telas principais existem em Flutter/Dart.
- Ha navegacao entre Login, Registro, Dashboard, Novo/Editar Cliente e Detalhe.
- Ha navegacao inferior entre Inicio, Funil e Lembretes.
- Login e Registro ja funcionam com Firebase Authentication.
- Os clientes ja usam Firebase Firestore, embora o CRUD seja exigido apenas em 02/06.

Na apresentacao, a prioridade e provar **telas e navegacao**. O Firestore deve aparecer como um avanco, nao como o assunto principal da entrega.

## Fala inicial pronta

Use esta fala como abertura:

> O ConnectCRM e um aplicativo de CRM feito totalmente em Flutter e Dart, usando componentes Material. Para a entrega de hoje, implementei todas as telas principais e a navegacao entre elas. O usuario entra ou cria uma conta, acessa o Dashboard e pode navegar pelas areas de Inicio, Funil e Lembretes. Tambem consegue abrir cadastro, detalhes e edicao de clientes. Alem do solicitado para esta data, o aplicativo ja esta integrado ao Firebase para autenticacao e persistencia dos clientes.

## Demonstracao em ordem segura

Antes de apresentar, deixe preparado um usuario de teste e pelo menos dois clientes: um `Novo Lead` com follow-up e um `Fechado`.

1. Abra a tela de Login e mostre que o app tem identidade visual consistente.
2. Clique em `Criar uma conta` para provar a navegacao para Registro.
3. Volte para Login e entre com um usuario existente.
4. No Dashboard, mostre saudacao, busca, indicadores e lista de clientes.
5. Use a barra inferior para alternar entre `Inicio`, `Funil` e `Lembretes`.
6. Volte ao Inicio e clique em `Adicionar` ou no botao `+`.
7. Mostre a tela `Novo cliente`, seus campos, status e data de follow-up.
8. Salve um cliente ou volte, conforme o tempo disponivel.
9. Clique em um cliente para abrir `Detalhe do cliente`.
10. Clique em editar para demonstrar que o formulario e reutilizado com os dados preenchidos.

Para a entrega de 26/05, nao e necessario excluir um cliente ao vivo. A exclusao ja existe, mas pode ser mostrada apenas se o professor perguntar sobre CRUD.

## Mapa das telas

| Tela | O que mostra | Como chega nela |
| --- | --- | --- |
| Login | E-mail, senha, entrar e criar conta | Tela inicial para usuario deslogado |
| Registro | Nome, e-mail, senha e confirmacao | Botao `Criar uma conta` no Login |
| Dashboard / Inicio | Busca, totais, lista e adicionar cliente | Login realizado ou aba `Inicio` |
| Novo Cliente | Formulario vazio | Botao `+` ou `Adicionar` no Dashboard |
| Editar Cliente | Mesmo formulario preenchido | Botao editar no Detalhe |
| Detalhe do Cliente | Informacoes completas do cliente | Toque em um cliente da lista |
| Funil de Vendas | Totais e clientes por status | Aba `Funil` |
| Lembretes | Follow-ups organizados por data | Aba `Lembretes` |

## Como a navegacao funciona

Existem dois tipos de navegacao no aplicativo.

### 1. Troca de telas em sequencia

Para ir de uma tela para outra, o projeto usa `Navigator.of(context).push(...)` com `MaterialPageRoute`. Isso empilha uma nova tela; ao usar `Navigator.of(context).pop()`, o usuario retorna para a anterior.

Exemplos:

- Login abre Registro.
- Dashboard abre Novo Cliente.
- Dashboard abre Detalhe do Cliente.
- Detalhe abre Editar Cliente.

### 2. Abas principais

Depois do login, a classe `MainShell` controla a barra inferior. Ela possui a variavel `_selectedIndex`, que indica a aba selecionada:

- indice `0`: Dashboard / Inicio;
- indice `1`: Funil;
- indice `2`: Lembretes.

As telas ficam dentro de um `IndexedStack`. Assim, a troca de aba muda o conteudo visivel sem criar uma rota nova a cada clique e preserva o estado das abas.

## Arquivos que voce deve abrir no VS Code

Abra estes arquivos nesta ordem durante uma explicacao tecnica:

| Arquivo | O que provar nele |
| --- | --- |
| `lib/main.dart` | O Firebase e inicializado antes de executar o app. |
| `lib/app/connect_crm_app.dart` | Tema global e decisao entre Login e area autenticada. |
| `lib/features/home/main_shell.dart` | Barra inferior, abas e lista recebida em tempo real. |
| `lib/features/dashboard/dashboard_screen.dart` | Tela inicial, busca e navegacao para cadastro/detalhes. |
| `lib/features/clients/screens/client_form_screen.dart` | Uma mesma tela serve para criar e editar. |
| `lib/features/clients/screens/client_detail_screen.dart` | Detalhes e botoes de editar/excluir. |
| `lib/features/funnel/sales_funnel_screen.dart` | Indicadores e separacao por status. |
| `lib/features/reminders/reminders_screen.dart` | Follow-ups filtrados e ordenados por data. |

Se ele perguntar sobre Firebase ou seguranca, abra tambem:

| Arquivo | O que provar nele |
| --- | --- |
| `lib/features/auth/login_screen.dart` | Login usando `signInWithEmailAndPassword`. |
| `lib/features/auth/register_screen.dart` | Cadastro usando `createUserWithEmailAndPassword`. |
| `lib/features/clients/data/clients_repository.dart` | Caminho dos clientes por usuario e operacoes no Firestore. |
| `firestore.rules` | Um usuario so le e altera seus proprios clientes. |

## Pontos exatos do codigo para mostrar

### Inicializacao e sessao

- `lib/main.dart`, linhas 7 a 20: inicializa o Firebase e inicia o aplicativo.
- `lib/app/connect_crm_app.dart`, linhas 15 a 50: configura o tema e abre o `AuthGate`.
- `lib/app/connect_crm_app.dart`, linhas 54 a 75: observa a sessao e atualizacoes do perfil com `userChanges()`.

Como explicar:

> O aplicativo nao precisa mandar manualmente o usuario para a Home depois do login. O Firebase informa que a sessao ou o perfil mudou; o `AuthGate` escuta essa mudanca e passa a exibir a area autenticada com o nome atualizado.

### Navegacao inferior

- `lib/features/home/main_shell.dart`, linhas 19 a 20: guarda a aba selecionada.
- `lib/features/home/main_shell.dart`, linhas 32 a 46: define Dashboard, Funil e Lembretes.
- `lib/features/home/main_shell.dart`, linhas 48 a 73: usa `IndexedStack` e `NavigationBar`.

Como explicar:

> A barra inferior organiza as tres areas principais. O indice muda com `setState`, e o `IndexedStack` apresenta a tela escolhida.

### Navegacao para cadastro e detalhes

- `lib/features/dashboard/dashboard_screen.dart`, linhas 62 a 72: botao flutuante abre Novo Cliente.
- `lib/features/dashboard/dashboard_screen.dart`, linhas 166 a 178: botao `Adicionar` abre o mesmo formulario.
- `lib/features/dashboard/dashboard_screen.dart`, linhas 220 a 234: toque em cliente abre Detalhe.
- `lib/features/clients/screens/client_detail_screen.dart`, linhas 63 a 80 e 166 a 179: abre Edicao e possui Exclusao.

### Criar e editar reutilizando a mesma tela

- `lib/features/clients/screens/client_form_screen.dart`, linhas 8 a 29: recebe opcionalmente um cliente; se existir, esta editando.
- `lib/features/clients/screens/client_form_screen.dart`, linhas 31 a 43: preenche os campos na edicao.
- `lib/features/clients/screens/client_form_screen.dart`, linhas 67 a 103: decide entre adicionar ou atualizar.

Como explicar:

> Em vez de duplicar duas telas quase iguais, usei um formulario unico. Sem cliente recebido, ele cria; com um cliente recebido, ele preenche os campos e atualiza.

### Telas de Funil e Lembretes

- `lib/features/funnel/sales_funnel_screen.dart`: calcula total, fechados e taxa de conversao, alem de separar a lista por status.
- `lib/features/reminders/reminders_screen.dart`, linhas 23 a 27: pega apenas clientes com follow-up e ordena por data.
- `lib/features/reminders/reminders_screen.dart`, linhas 121 a 130: um lembrete tambem navega para o detalhe do cliente.

### Dados reais e seguranca, caso perguntem

- `lib/features/clients/data/clients_repository.dart`, linhas 12 a 13: dados ficam em `users/{userId}/clients`.
- `lib/features/clients/data/clients_repository.dart`, linhas 15 a 37: listar, criar, atualizar e excluir.
- `firestore.rules`, linhas 5 a 8: somente o usuario autenticado com o mesmo `uid` acessa seus clientes.

Como explicar:

> Cada usuario tem sua propria subcolecao de clientes. O codigo monta o caminho com o `uid` da sessao, e a regra do Firestore impede acesso a dados de outro usuario.

## Conceitos tecnicos para dominar

### Flutter e Dart

- **Flutter** e o framework usado para construir a interface em multiplas plataformas.
- **Dart** e a linguagem em que todo o aplicativo foi escrito.
- **Widget** e a unidade visual do Flutter: tela, botao, campo, texto e layout sao widgets.
- **Material Design / Material 3** fornece componentes e comportamento visual consistente.

### `StatelessWidget` e `StatefulWidget`

- `StatelessWidget` e adequado quando a tela apenas apresenta dados recebidos e nao controla mudancas internas importantes.
- `StatefulWidget` e usado quando o componente precisa mudar durante o uso.

No ConnectCRM:

- Login e Registro sao `StatefulWidget` porque controlam campos, senha visivel e carregamento.
- Dashboard e `StatefulWidget` porque a busca altera a lista exibida.
- `MainShell` e `StatefulWidget` porque altera a aba selecionada.
- Detalhe e Lembretes podem ser `StatelessWidget` porque apresentam dados recebidos.

### Firebase Authentication

- O Firebase Auth e responsavel pelas contas e sessoes.
- Registro chama `createUserWithEmailAndPassword`.
- Login chama `signInWithEmailAndPassword`.
- Logout chama `signOut`.
- A senha nao e guardada no Firestore pelo aplicativo; ela e tratada com seguranca pelo Firebase Authentication.
- O nome do usuario e salvo no perfil autenticado por `updateDisplayName`.

### Firebase Firestore

- Firestore e o banco de dados usado para clientes.
- O caminho atual e `users/{userId}/clients/{clientId}`.
- O repositorio separa a logica de banco da interface.
- Um `Stream` atualiza a tela quando os documentos mudam.

## Perguntas provaveis e respostas curtas

**1. O que era exigido para esta entrega?**  
Todas as telas principais implementadas em Flutter/Dart e navegacao entre elas. O projeto cumpre isso por meio de rotas com `Navigator` e abas com `NavigationBar`.

**2. Quais telas foram implementadas?**  
Login, Registro, Dashboard, Novo/Editar Cliente, Detalhe do Cliente, Funil de Vendas e Lembretes.

**3. Como voce navega entre as telas?**  
Uso `Navigator.push` para abrir cadastro, detalhe, edicao e registro; uso `Navigator.pop` para retornar. Nas areas principais, uso `NavigationBar` com `IndexedStack`.

**4. Por que usar uma barra inferior?**  
Porque Inicio, Funil e Lembretes sao areas principais acessadas frequentemente; a navegacao fica rapida e previsivel.

**5. Por que `IndexedStack`?**  
Porque ele troca a aba visivel mantendo as telas montadas, evitando perder estado ao alternar entre areas.

**6. O projeto foi feito em React, Vite ou Figma?**  
Nao. O aplicativo executavel foi implementado totalmente em Flutter/Dart.

**7. O login e real?**  
Sim. Ele usa Firebase Authentication com e-mail e senha.

**8. Onde ficam nome, e-mail e senha do usuario?**  
E-mail e autenticacao ficam no Firebase Authentication. O nome e atualizado no perfil do usuario autenticado. A senha nao e salva no Firestore pelo aplicativo.

**9. Como o app decide mostrar Login ou Dashboard?**  
O `AuthGate` escuta `FirebaseAuth.instance.userChanges()`. Sem usuario mostra Login; com usuario mostra `MainShell`, incluindo atualizacoes do nome do perfil.

**10. O que acontece ao sair?**  
O Dashboard chama `FirebaseAuth.instance.signOut()`. A sessao some, o `AuthGate` recebe a mudanca e exibe Login novamente.

**11. Como funciona Novo Cliente e Editar Cliente?**  
E uma unica tela. Quando nao recebe um cliente, cria um novo registro; quando recebe, carrega os dados existentes e atualiza.

**12. Como funciona a busca?**  
A busca filtra a lista atual procurando o texto digitado no nome ou na empresa, sem diferenciar maiusculas e minusculas.

**13. Como funciona o funil?**  
Ele separa clientes pelos status `Novo Lead`, `Negociacao` e `Fechado`, conta cada grupo e calcula conversao como fechados dividido pelo total vezes cem.

**14. Como funcionam os lembretes?**  
A tela seleciona clientes que possuem data de follow-up e os ordena da data mais proxima para a mais distante.

**15. O Firestore ja faz parte desta entrega?**  
O CRUD no Firestore esta previsto para 02/06, mas ja foi adiantado no projeto. Para 26/05, o foco da demonstracao e tela e navegacao.

**16. Onde os clientes ficam salvos?**  
Em `users/{userId}/clients/{clientId}`, separando os registros por usuario logado.

**17. Outro usuario consegue acessar os clientes?**  
Nao deveria conseguir. As regras do Firestore exigem autenticacao e verificam se o `uid` corresponde ao `userId` do caminho.

**18. Por que existe uma classe `ClientsRepository`?**  
Para concentrar as operacoes de banco em um lugar e evitar misturar acesso ao Firestore com o desenho das telas.

**19. O que e `firebase_options.dart`?**  
E um arquivo gerado pelo FlutterFire com as configuracoes publicas para conectar o aplicativo ao projeto Firebase em cada plataforma. Ele nao guarda senha de usuario.

**20. O que ainda poderia ser aprimorado?**  
Validacoes mais completas, testes adicionais e melhorias de experiencia, sem alterar a arquitetura principal. O historico de interacoes ja foi implementado como evolucao posterior.

## Nao confunda estes pontos

- Nao diga que a senha fica no Firestore. Ela fica sob responsabilidade do Firebase Authentication.
- Nao diga que o app ainda usa dados mockados. O codigo local ja usa Firestore real.
- Nao diga que a barra inferior abre rotas novas. Ela troca o indice no `IndexedStack`.
- Nao diga que o CRUD e obrigatorio para 26/05. Ele e um avanco para a entrega de 02/06.
- O historico de interacoes ja existe, mas apresente-o como evolucao extra, pois nao era o foco exigido para 26/05.

## Simulado rapido

Treine respondendo sem ler; depois confira as respostas acima.

1. Qual e a diferenca entre Firebase Auth e Firestore no seu app?
2. Como o aplicativo sabe que o usuario terminou o login?
3. Onde no codigo aparece a navegacao inferior?
4. Como voce prova que todas as telas estao conectadas?
5. Por que o formulario serve tanto para novo cliente quanto para edicao?
6. Qual e o caminho de armazenamento dos clientes?
7. Como a regra impede que um usuario veja os dados de outro?
8. Como a taxa de conversao do funil e calculada?
9. Como os lembretes sao escolhidos e ordenados?
10. O que foi feito alem do exigido para 26/05?

## Checklist antes de sair para apresentar

- Conseguir entrar com um usuario de teste.
- Manter pelo menos dois clientes cadastrados para o Funil nao ficar vazio.
- Manter um cliente com follow-up para a tela de Lembretes ter conteudo.
- Abrir previamente no VS Code: `main.dart`, `connect_crm_app.dart`, `main_shell.dart`, `dashboard_screen.dart` e `client_form_screen.dart`.
- Saber de memoria: `Navigator`, `NavigationBar`, `IndexedStack`, `AuthGate`, `Firebase Auth` e `users/{userId}/clients/{clientId}`.

## Resumo de 20 segundos

> A entrega pede todas as telas e navegacao em Flutter/Dart. O ConnectCRM possui Login, Registro, Dashboard, cadastro e edicao, detalhes, Funil e Lembretes. As telas de fluxo usam `Navigator`, as tres areas principais usam `NavigationBar` com `IndexedStack`, e o aplicativo ainda esta adiantado com Firebase Auth e Firestore por usuario.
