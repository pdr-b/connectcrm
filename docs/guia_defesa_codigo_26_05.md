# ConnectCRM - Guia de defesa do código para 26/05/2026

## Como usar este guia

Este material é para o cenário em que o professor abre qualquer arquivo e pergunta: **"o que isso faz?"**

Não tente decorar linhas isoladas. Decore o fluxo:

1. `main.dart` inicializa o Firebase.
2. `ConnectCrmApp` cria o tema e abre o controle de autenticação.
3. `AuthGate` decide entre Login e a área principal.
4. `MainShell` controla as três abas e recebe clientes em tempo real.
5. As telas exibem e manipulam dados.
6. `ClientsRepository` conversa com o Firestore.
7. `firestore.rules` impede que um usuário acesse clientes de outro.

Frase-base para responder qualquer pergunta:

> Esta parte recebe ou controla um dado, usa esse dado para montar a interface ou chamar um serviço, e atualiza a tela quando o estado muda.

## O que é essencial para amanhã

A exigência de **26/05/2026** é:

> Todas as telas implementadas no Flutter/Dart, com navegação entre elas.

O que você deve provar primeiro:

- Login e Registro existem.
- Dashboard, Novo/Editar Cliente, Detalhe, Funil e Lembretes existem.
- Login abre Registro.
- A lista abre Detalhe.
- Detalhe abre Editar.
- Dashboard abre Novo Cliente.
- A barra inferior troca entre Início, Funil e Lembretes.

O projeto já possui Firebase Auth e Firestore real. Se isso aparecer na explicação, diga que é uma implementação adiantada da etapa seguinte, cujo prazo é **02/06/2026**.

---

# Parte 1 - Vocabulário para não travar

## `import`

Traz classes e funções de outros arquivos ou bibliotecas para serem usadas naquele arquivo.

Exemplo de resposta:

> Este `import` disponibiliza os widgets do Flutter ou a integração do Firebase que a tela precisa usar.

## `class`

Define uma estrutura. Em Flutter, a maioria das telas e componentes visuais é uma classe que herda de `StatelessWidget` ou `StatefulWidget`.

## `Widget`

É uma peça da interface. Um texto, botão, tela, campo, coluna ou cartão é um widget.

## `StatelessWidget`

É usado quando o widget não precisa guardar alterações internas durante o uso. Ele recebe dados e desenha a interface.

No projeto:

- `ConnectCrmApp`
- `AuthGate`
- `ClientDetailScreen`
- `SalesFunnelScreen`
- `RemindersScreen`
- `StatusChip`
- `GradientButton`

Resposta pronta:

> Esta tela é stateless porque ela renderiza informações recebidas; a alteração principal acontece fora dela ou por uma chamada direta ao repositório.

## `StatefulWidget`

É usado quando a tela precisa manter estado mutável, como texto digitado, carregamento ou aba atual.

No projeto:

- `LoginScreen`: mantém campos, carregamento e visibilidade da senha.
- `RegisterScreen`: mantém formulário e carregamento.
- `MainShell`: mantém qual aba está selecionada.
- `DashboardScreen`: mantém o texto da busca.
- `ClientFormScreen`: mantém os dados que estão sendo preenchidos.

## `build(BuildContext context)`

É o método que retorna a árvore visual do widget. Quando ocorre `setState`, o Flutter chama `build` novamente para redesenhar a parte necessária.

Resposta pronta:

> O método `build` descreve o que aparece na tela naquele momento, com base nos valores atuais.

## `final` e `const`

- `final`: o valor recebe uma atribuição e depois não muda naquela instância.
- `const`: o objeto é constante e pode ser criado de forma otimizada em tempo de compilação.

Resposta pronta:

> Usei `final` para propriedades recebidas e `const` em widgets fixos, reduzindo reconstruções desnecessárias e deixando a intenção do código clara.

## `_nomePrivado`

Em Dart, um nome começando por `_` é privado ao arquivo. Exemplos: `_signIn`, `_selectedIndex`, `_isSaving`.

Resposta pronta:

> Esse método ou valor é um detalhe interno da tela e não precisa ser acessado por outros arquivos.

## `async` e `await`

São usados quando uma operação leva tempo, como login, salvar no Firestore ou excluir um documento.

Resposta pronta:

> O aplicativo espera a resposta do Firebase antes de seguir, para saber se deu certo ou mostrar erro.

## `setState`

Informa ao Flutter que um valor usado na tela mudou e que ela precisa ser redesenhada.

Exemplos:

- mostrar carregamento no login;
- mostrar ou ocultar senha;
- alterar aba atual;
- alterar busca;
- selecionar status e data no formulário.

## `Navigator.push` e `Navigator.pop`

- `push`: abre uma nova tela sobre a atual.
- `pop`: fecha a tela atual e retorna à anterior.

Resposta pronta:

> Uso navegação por pilha: a nova tela é empilhada e, ao voltar, ela é removida.

## `StreamBuilder`

Observa uma fonte de dados que pode emitir novos valores ao longo do tempo. Quando chegam dados novos, ele reconstrói a interface.

No projeto:

- observa a autenticação no `AuthGate`;
- observa clientes do Firestore no `MainShell`.

---

# Parte 2 - Fluxo completo do aplicativo

## Ao abrir o app

1. O Dart começa em `main()`.
2. O Flutter prepara o ambiente.
3. O Firebase é inicializado com a configuração da plataforma.
4. O widget raiz `ConnectCrmApp` é executado.
5. O `AuthGate` verifica se há usuário autenticado e acompanha atualizações do perfil.
6. Se não houver usuário, aparece Login.
7. Se houver usuário, aparece `MainShell`.

## Ao fazer cadastro

1. Login abre Registro com `Navigator.push`.
2. O usuário preenche nome, e-mail, senha e confirmação.
3. O formulário valida os dados.
4. Firebase Auth cria o usuário com e-mail e senha.
5. O nome é salvo como `displayName` do perfil autenticado.
6. Registro fecha com `Navigator.pop`.
7. Como a autenticação mudou, `AuthGate` passa a mostrar `MainShell`.

## Ao fazer login

1. O usuário informa e-mail e senha.
2. Firebase Auth verifica as credenciais.
3. Se correto, a sessão passa a existir.
4. O `AuthGate`, que escuta a sessão e o perfil, mostra a área principal.
5. Se falhar, a tela mostra uma mensagem com `SnackBar`.

## Ao navegar pelas abas

1. `MainShell` inicia com índice `0`, a aba Início.
2. O usuário toca em Funil ou Lembretes.
3. `setState` altera `_selectedIndex`.
4. O `IndexedStack` apresenta a tela correspondente.

## Ao criar cliente

1. Dashboard abre `ClientFormScreen` sem cliente existente.
2. O formulário inicia vazio.
3. O usuário preenche os campos e salva.
4. `_isEditing` é falso, então chama `addClient`.
5. O repositório cria um documento na coleção do usuário.
6. O stream recebe a mudança e atualiza Dashboard, Funil e Lembretes.

## Ao editar cliente

1. O usuário abre o Detalhe e toca em editar.
2. `ClientFormScreen` recebe um objeto `Client`.
3. `initState` carrega os dados nos campos.
4. `_isEditing` é verdadeiro, então chama `updateClient`.
5. O documento é atualizado e o stream renova as telas.

---

# Parte 3 - Arquivo por arquivo

## `lib/main.dart`

### Responsabilidade

É o ponto inicial do aplicativo. Antes de desenhar qualquer tela, conecta o projeto ao Firebase.

### Trechos importantes

| Linhas | O que fazem |
| --- | --- |
| 1 a 5 | Importam Firebase Core, Flutter, app raiz e opções Firebase. |
| 7 | Declara `main()` como assíncrona porque a inicialização do Firebase demora. |
| 8 | `WidgetsFlutterBinding.ensureInitialized()` prepara o Flutter antes de serviços assíncronos. |
| 10 | Reserva `firebaseError` para armazenar eventual erro de configuração. |
| 12 a 18 | Tenta iniciar Firebase; se falhar, guarda o erro. |
| 20 | Executa `ConnectCrmApp`, levando o erro caso exista. |

### Se ele perguntar: "por que não chamar direto `runApp`?"

> Porque as telas dependem de Firebase Auth e Firestore. Primeiro inicializo o Firebase; depois inicio a interface sabendo se a configuração funcionou.

### Se ele perguntar: "para que serve `DefaultFirebaseOptions.currentPlatform`?"

> Ele fornece as configurações correspondentes à plataforma em execução, como web, Android ou iOS. O arquivo é gerado pelo FlutterFire.

---

## `lib/firebase_options.dart`

### Responsabilidade

Contém opções geradas automaticamente pelo FlutterFire para apontar o aplicativo ao projeto Firebase correto em cada plataforma.

### O que falar com cuidado

> Este arquivo não armazena senha de usuário. Ele contém identificadores e opções de conexão do app Firebase. A proteção dos dados acontece com autenticação e regras do Firestore.

Não precisa abrir nem ler valores deste arquivo na apresentação, a menos que o professor pergunte especificamente pela configuração Firebase.

---

## `lib/app/connect_crm_app.dart`

### Responsabilidade

Cria a aplicação visual, configura o tema global e controla se aparece Login ou a área autenticada.

### Classe `ConnectCrmApp`

| Linhas | O que fazem |
| --- | --- |
| 8 a 11 | Widget raiz; pode receber erro ocorrido ao inicializar Firebase. |
| 15 a 17 | Cria `MaterialApp`, define título e remove a faixa de debug. |
| 18 a 46 | Define tema Material 3, fundo claro, roxo/azul e estilo dos inputs. |
| 47 a 49 | Se Firebase inicializou, abre `AuthGate`; se falhou, exibe tela de configuração. |

### Classe `AuthGate`

É uma "porta" de autenticação.

| Linhas | O que fazem |
| --- | --- |
| 59 a 60 | Usa `StreamBuilder` para observar mudanças na sessão e no perfil Firebase. |
| 62 a 65 | Enquanto descobre a sessão, mostra carregamento. |
| 68 a 70 | Se há usuário, abre `MainShell` passando esse usuário. |
| 72 | Se não há usuário, abre Login. |

### Resposta principal

> O `AuthGate` evita que eu precise navegar manualmente após login ou logout. Ele usa `userChanges()`: autenticou, mostra o app; atualizou o nome, atualiza a saudação; saiu, mostra Login.

### Classe `FirebaseConfigurationScreen`

Tela de contingência. Se a conexão Firebase falhar ao iniciar o app, ela mostra uma mensagem compreensível em vez de uma tela quebrada.

---

## `lib/features/auth/login_screen.dart`

### Responsabilidade

Coleta credenciais, valida campos, chama Firebase Authentication e oferece navegação para cadastro.

### Por que é `StatefulWidget`

Porque a tela muda enquanto o usuário interage:

- conteúdo digitado nos controladores;
- senha oculta ou visível;
- botão em carregamento.

### Variáveis principais

| Variável | Significado |
| --- | --- |
| `_formKey` | Permite validar todos os campos do formulário. |
| `_emailController` | Lê o e-mail digitado. |
| `_passwordController` | Lê a senha digitada. |
| `_isLoading` | Impede ações duplicadas e mostra carregamento. |
| `_hidePassword` | Decide se a senha aparece ou fica escondida. |

### Método `_signIn()` - linhas 29 a 46

Passo a passo:

1. Valida o formulário; se estiver inválido, para.
2. Ativa carregamento com `setState`.
3. Chama `FirebaseAuth.instance.signInWithEmailAndPassword`.
4. Se o Firebase rejeitar, traduz o erro para uma mensagem amigável.
5. Ao terminar, desativa carregamento.

### Pergunta perigosa: "cadê o Navigator para ir para Home?"

Resposta certa:

> Não há navegação manual para Home dentro do login. Quando o Firebase autentica, o stream `userChanges()` do `AuthGate` detecta o usuário e troca automaticamente Login por `MainShell`.

### Métodos auxiliares

- `_showError`: apresenta mensagem em `SnackBar`.
- `_authMessage`: converte códigos técnicos Firebase em mensagens para o usuário.
- `_sendPasswordResetEmail`: envia recuperação de senha ao e-mail preenchido usando Firebase Auth.
- `_syncUserProfile`: ao entrar, cria ou atualiza o documento `users/{uid}` com dados básicos do perfil.
- `dispose`: libera os `TextEditingController` quando a tela deixa de existir.

### Navegação para Registro

Nas linhas 134 a 145, o botão `Criar uma conta` usa `Navigator.push` e abre `RegisterScreen`.

---

## `lib/features/auth/register_screen.dart`

### Responsabilidade

Cria uma nova conta no Firebase Authentication e registra o nome no perfil do usuário.

### Variáveis principais

| Variável | Significado |
| --- | --- |
| `_nameController` | Nome completo digitado. |
| `_emailController` | E-mail usado na conta. |
| `_passwordController` | Senha da conta. |
| `_confirmPasswordController` | Confirma se o usuário repetiu a senha corretamente. |
| `_hidePassword` e `_hideConfirmation` | Controlam visibilidade das senhas. |

### Método `_createAccount()` - linhas 33 a 55

1. Valida o formulário.
2. Ativa carregamento.
3. Cria a conta via `createUserWithEmailAndPassword`.
4. Salva o nome no perfil Firebase usando `updateDisplayName`.
5. Fecha a tela de Registro.
6. Se houver erro, mostra mensagem adequada.

### Onde ficam os dados de cadastro

Resposta que você deve falar exatamente:

> O e-mail e a autenticação ficam no Firebase Authentication. O nome fica no `displayName` e também existe um documento de perfil em `users/{uid}` com nome, e-mail e data. A senha é gerenciada pelo Firebase Auth e não é salva no Firestore.

### Validações visíveis

- Nome precisa ter ao menos três caracteres.
- E-mail precisa conter `@`.
- Senha precisa ter ao menos seis caracteres.
- Confirmação precisa ser igual à senha.

---

## `lib/features/home/main_shell.dart`

### Responsabilidade

É a estrutura principal depois do login: carrega clientes do usuário e contém a navegação inferior.

### Por que recebe `User user`

O usuário autenticado possui o `uid`, identificador usado para acessar apenas os clientes pertencentes àquela conta.

### Estado `_selectedIndex` - linha 20

Guarda a aba atual:

| Índice | Aba |
| --- | --- |
| 0 | Início / Dashboard |
| 1 | Funil |
| 2 | Lembretes |

### Repositório - linha 24

```dart
final repository = ClientsRepository(userId: widget.user.uid);
```

Como explicar:

> O repositório recebe o identificador do usuário logado. Assim, toda consulta e alteração de cliente ocorre dentro da coleção daquele usuário.

### Stream de clientes - linhas 26 a 31

`StreamBuilder<List<Client>>` acompanha alterações no Firestore. Ele trata:

- a lista retornada;
- carregamento inicial;
- eventual erro de leitura.

### Telas - linhas 32 a 46

A mesma lista de clientes é encaminhada para:

- Dashboard;
- Funil;
- Lembretes.

Assim, quando um cliente muda, as três abas recebem os dados atualizados.

### Barra inferior - linhas 48 a 73

- `IndexedStack` escolhe a tela que aparece.
- `NavigationBar` mostra os três destinos.
- `onDestinationSelected` altera o índice com `setState`.

### Pergunta provável: "por que não fazer três consultas?"

> Como as três abas trabalham com os mesmos clientes, faço uma leitura central no `MainShell` e distribuo a lista. Isso reduz duplicação e mantém os dados coerentes entre as telas.

---

## `lib/features/dashboard/dashboard_screen.dart`

### Responsabilidade

É a Home do CRM: mostra usuário, busca, indicadores, lista e caminhos para adicionar ou visualizar clientes.

### Dados recebidos

| Propriedade | Uso |
| --- | --- |
| `user` | Mostrar nome e realizar logout. |
| `repository` | Entregar acesso a dados às telas abertas. |
| `clients` | Mostrar e filtrar a lista. |
| `isLoading` | Mostrar progresso. |
| `hasError` | Mostrar erro de carregamento. |

### Busca - linhas 43 a 50

`_filteredClients` transforma o texto procurado em minúsculas e compara com nome e empresa também em minúsculas.

Resposta pronta:

> A busca é feita sobre a lista já recebida do Firestore, comparando nome ou empresa e ignorando diferença entre maiúsculas e minúsculas.

### Logout - linhas 52 a 54

Chama `FirebaseAuth.instance.signOut()`. Quem troca para Login é o `AuthGate`, porque a sessão muda.

### Novo cliente

Há dois acessos à mesma tela:

- botão flutuante, linhas 62 a 72;
- botão `Adicionar`, linhas 166 a 178.

Ambos abrem `ClientFormScreen(repository: widget.repository)` sem passar cliente, então é modo de criação.

### Lista e detalhes - linhas 214 a 237

Para cada cliente filtrado, constrói `ClientListTile`. Ao tocar, abre `ClientDetailScreen`, passando:

- o cliente escolhido;
- o repositório para ações posteriores.

### Estados da tela

| Condição | O que aparece |
| --- | --- |
| `isLoading` | Carregamento. |
| `hasError` | Mensagem de falha. |
| Lista vazia | Convite para cadastrar primeiro cliente. |
| Busca sem resultado | Mensagem de nenhum resultado. |
| Há clientes | Lista em cartões. |

---

## `lib/features/clients/screens/client_form_screen.dart`

### Responsabilidade

É o formulário usado tanto para criar quanto para editar clientes.

### Como sabe se está criando ou editando

```dart
bool get _isEditing => widget.client != null;
```

- Sem `client`: novo cadastro.
- Com `client`: edição.

### `initState()` - linhas 31 a 43

É executado quando a tela é criada. Se recebeu um cliente, coloca os valores existentes nos controladores, no status e na data.

Resposta pronta:

> A edição reaproveita a tela de cadastro. O `initState` preenche o formulário antes de o usuário alterar os campos.

### `_pickDate()` - linhas 55 a 65

Abre um seletor de data com `showDatePicker`, para definir o próximo follow-up.

### `_save()` - linhas 67 a 104

1. Valida os campos obrigatórios.
2. Ativa estado de salvamento.
3. Monta um objeto `Client` com os valores do formulário.
4. Se estiver editando, chama `updateClient`.
5. Se for novo, chama `addClient`.
6. Quando conclui, volta à tela anterior com `pop`.
7. Se falhar, mostra `SnackBar`.

### Campos presentes

- nome completo;
- empresa;
- telefone;
- e-mail;
- status no funil;
- próximo follow-up;
- observações.

### Status disponíveis

São definidos no modelo:

- `Novo Lead`;
- `Negociação`;
- `Fechado`.

---

## `lib/features/clients/screens/client_detail_screen.dart`

### Responsabilidade

Mostra as informações completas de um cliente e dá acesso à edição e exclusão.

### Por que é `StatelessWidget`

A tela recebe um `Client` pronto e o mostra. Ela não mantém formulário ou filtro local.

### Editar

Ao clicar no ícone ou botão de edição, abre:

```dart
ClientFormScreen(repository: repository, client: client)
```

Como passa `client`, o formulário entra no modo de edição.

### Excluir - linhas 21 a 54

1. Mostra caixa de confirmação com `showDialog`.
2. Se o usuário cancelar, não faz nada.
3. Se confirmar, chama `repository.deleteClient(client.id)`.
4. Se der certo, fecha a tela de detalhe.
5. Se falhar, mostra erro.

### Histórico de interações

A tela permite registrar e listar interações do cliente, como contato, ligação, reunião, e-mail ou proposta. Os registros ficam na subcoleção:

```text
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

O histórico é atualizado em tempo real por um `StreamBuilder` e permite excluir um registro quando necessário.

### `_DetailRow`

É um componente interno usado para evitar repetir o layout de telefone, e-mail e follow-up.

---

## `lib/features/funnel/sales_funnel_screen.dart`

### Responsabilidade

Mostra como os clientes estão distribuídos no processo de venda.

### Cálculos principais - linhas 21 a 23

```dart
final total = clients.length;
final closed = clients.where((client) => client.status == 'Fechado').length;
final conversion = total == 0 ? 0 : (closed / total * 100).round();
```

Explicação:

- `total`: quantidade de clientes no pipeline.
- `closed`: quantidade cujo status é Fechado.
- `conversion`: porcentagem de fechados sobre o total.
- Se não há clientes, retorna zero para evitar divisão por zero.

### Funções auxiliares

- `_countByStatus`: conta clientes de uma etapa.
- `_clientsByStatus`: retorna os clientes daquela etapa.

### Componentes internos

| Componente | Função |
| --- | --- |
| `_BigMetric` | Mostra Pipeline e Conversão. |
| `_StageCounter` | Mostra a quantidade em cada status. |
| `_StageSection` | Lista os clientes separados por status. |

### Pergunta provável: "se houver 2 fechados em 5 clientes?"

> A conversão será `2 / 5 * 100`, portanto `40%`.

---

## `lib/features/reminders/reminders_screen.dart`

### Responsabilidade

Lista clientes que possuem follow-up agendado, ordenados por data.

### Filtragem e ordenação - linhas 25 a 27

1. Seleciona clientes cujo `nextFollowUp` não é nulo.
2. Ordena pela data de follow-up em ordem crescente.

Resposta pronta:

> A tela não precisa de uma coleção separada de lembretes; ela deriva os lembretes dos clientes que possuem próxima data de contato.

### Navegação

Ao tocar num lembrete, abre o Detalhe do Cliente. Isso permite consultar os dados completos e editar o acompanhamento.

### `_isOverdue()`

Compara a data de follow-up com o dia atual, desconsiderando horário. Se a data já passou, muda o destaque para vermelho.

---

## `lib/features/clients/data/client.dart`

### Responsabilidade

Representa um cliente no código e converte entre objeto Dart e documento Firestore.

### Constante `clientStatuses`

Centraliza os status válidos para o dropdown e para os cálculos do funil.

### Campos da classe `Client`

| Campo | O que guarda |
| --- | --- |
| `id` | Identificador do documento Firestore. |
| `name` | Nome do cliente. |
| `company` | Empresa. |
| `phone` | Telefone. |
| `email` | E-mail. |
| `status` | Etapa do funil. |
| `nextFollowUp` | Próxima data de contato. |
| `notes` | Observações. |
| `createdAt` | Momento da criação. |
| `updatedAt` | Momento da última atualização. |

### `Client.fromDocument`

Recebe um documento do Firestore e o transforma em um objeto que as telas entendem.

### `toCreateMap`

Transforma um novo cliente em mapa para salvar no Firestore. Inclui `createdAt` e `updatedAt` definidos pelo horário do servidor.

### `toUpdateMap`

Transforma alterações em mapa para atualizar. Mantém a criação original e renova apenas `updatedAt`.

### `_readDate`

Transforma valores de data vindos do Firestore em `DateTime`, aceitando `Timestamp` ou texto quando necessário.

---

## `lib/features/clients/data/clients_repository.dart`

### Responsabilidade

Centraliza a comunicação com o Firestore. As telas não precisam conhecer detalhes de coleções ou operações.

### Construtor

Recebe `userId`. Isso é essencial para separar dados entre usuários.

### Caminho da coleção - linhas 12 a 13

```text
users/{userId}/clients/{clientId}
```

Resposta pronta:

> Cada conta possui sua própria subcoleção `clients`. O `userId` vem do usuário autenticado.

### `watchClients()` - linhas 15 a 25

1. Escuta a coleção no Firestore com `snapshots()`.
2. Converte cada documento em `Client`.
3. Ordena os clientes alfabeticamente pelo nome.
4. Entrega uma lista atualizada como `Stream`.

### Operações

| Método | Ação |
| --- | --- |
| `addClient` | Cria documento novo. |
| `updateClient` | Atualiza documento existente pelo id. |
| `deleteClient` | Exclui documento pelo id. |
| `watchInteractions` | Observa o histórico de um cliente em tempo real. |
| `addInteraction` | Registra uma interação no histórico. |
| `deleteInteraction` | Exclui uma interação registrada. |

### Por que repositório é uma boa escolha

> Ele separa a interface da persistência. Se futuramente a forma de armazenar mudar, as telas não precisam ser reescritas inteiras.

---

## `firestore.rules`

### Responsabilidade

Define segurança no banco, independentemente do que a interface tentar fazer.

### Regra implementada

O acesso a `users/{userId}/clients/{clientId}` só é permitido quando:

- existe usuário autenticado;
- o `uid` autenticado é igual ao `userId` da rota.

### Pergunta provável: "não bastava filtrar no app?"

Resposta certa:

> Não. O aplicativo no dispositivo do usuário não é uma barreira confiável de segurança. As regras do Firestore protegem os dados no servidor, mesmo que alguém tente fazer requisições fora da interface.

---

## Componentes visuais compartilhados

### `lib/shared/theme/app_colors.dart`

Centraliza as cores da identidade visual. Evita repetir códigos de cor e mantém aparência consistente.

### `lib/shared/widgets/gradient_button.dart`

Botão reutilizável com:

- gradiente roxo/azul quando habilitado;
- visual cinza quando desabilitado;
- indicador circular quando está carregando;
- ícone opcional.

Ele é usado para ações importantes, como entrar e salvar cliente.

### `lib/shared/widgets/app_card.dart`

Cartão branco reutilizável com arredondamento e sombra. Pode receber `onTap`; nesse caso, ganha interação com `InkWell`.

### `lib/shared/widgets/auth_card.dart`

Cartão específico das telas de autenticação. Limita a largura a `440`, ficando bem apresentado inclusive no navegador.

### `lib/shared/widgets/empty_state.dart`

Mostra uma mensagem amigável quando não há dados ou ocorreu uma situação vazia, como não existir nenhum cliente.

### `lib/features/clients/widgets/client_list_tile.dart`

Desenha cada cliente na lista:

- gera iniciais a partir do nome;
- mostra empresa;
- mostra status;
- recebe o toque para abrir Detalhe.

### `lib/features/clients/widgets/status_chip.dart`

Transforma status em etiquetas coloridas:

- Fechado: verde;
- Negociação: amarelo;
- Novo Lead: roxo.

---

## `test/widget_test.dart`

### Responsabilidade

É um teste de widget simples para confirmar que `GradientButton` renderiza o texto recebido.

### Como explicar

> É um teste inicial de interface. Ele cria o botão com o rótulo `Entrar` e verifica se esse texto aparece. O projeto pode evoluir para testes de navegação e formulários.

---

# Parte 4 - Se ele selecionar uma linha aleatória

## Ele aponta para `required this.clients`

> Significa que essa tela exige receber uma lista de clientes no construtor; sem essa lista ela não consegue renderizar seus dados.

## Ele aponta para `super.key`

> A `key` ajuda o Flutter a identificar widgets na árvore e preservar corretamente seu estado durante reconstruções.

## Ele aponta para `mounted` ou `context.mounted`

> Depois de uma operação assíncrona, a tela pode já ter sido fechada. Essa verificação evita tentar atualizar ou navegar usando uma tela que não existe mais.

## Ele aponta para `?.`, `??` ou `!`

- `?.`: acessa algo apenas se não for nulo.
- `??`: usa valor alternativo se o primeiro for nulo.
- `!`: informa que naquele ponto o valor não será nulo.

## Ele aponta para `where(...).toList()`

> É uma filtragem: percorre a lista, mantém só os itens que obedecem à condição e gera uma nova lista.

## Ele aponta para `map(...)`

> Converte cada item de uma coleção para outro formato; no repositório, converte documentos Firestore em objetos `Client`.

## Ele aponta para `MaterialPageRoute<void>`

> Define a rota visual Flutter que será empilhada pelo `Navigator`; o `<void>` indica que não espero receber um resultado ao fechar a tela.

## Ele aponta para `Scaffold`

> É a estrutura base de uma tela Material, que comporta corpo, barra superior, botão flutuante e barra inferior.

## Ele aponta para `SafeArea`

> Evita que o conteúdo fique escondido por recortes, barra de status ou áreas reservadas do celular.

## Ele aponta para `SingleChildScrollView` ou `CustomScrollView`

> Permite rolagem para o conteúdo caber em telas menores ou quando houver muitos clientes.

---

# Parte 5 - Perguntas de banca mais técnicas

## "Por que os clientes não ficam diretamente em uma coleção `clients`?"

> Porque a estrutura `users/{userId}/clients` deixa claro o proprietário de cada cliente e combina diretamente com a regra de segurança por usuário.

## "Se alterar um cliente, como Funil e Lembretes descobrem?"

> O `MainShell` observa a coleção com um `Stream`. Quando o Firestore emite uma nova lista, ele repassa a lista atualizada às três abas.

## "O que impede cadastro com senha diferente da confirmação?"

> O `validator` do campo de confirmação compara seu valor com `_passwordController.text` e bloqueia o envio se forem diferentes.

## "Por que o nome do usuário aparece na Home?"

> Após cadastro, o nome é salvo no `displayName` do usuário Firebase. O Dashboard recebe o usuário autenticado e usa `displayName` na saudação.

## "O que acontece se a busca estiver vazia?"

> O getter retorna todos os clientes; só aplica o filtro quando há texto digitado.

## "O que acontece com taxa de conversão sem clientes?"

> O código retorna zero antes de tentar dividir, evitando divisão por zero.

## "Qual a diferença de criar e atualizar timestamp?"

> Na criação, salvo `createdAt` e `updatedAt`. Na edição, preservo a data de criação e altero somente `updatedAt`.

## "A tela de Detalhe atualiza imediatamente depois de editar?"

> A fonte principal é atualizada em tempo real pelo stream na área principal. Como a tela de Detalhe recebeu o objeto ao ser aberta, depois de editar o caminho natural é voltar à lista atualizada; uma evolução seria fazer o detalhe observar o documento diretamente.

Esta última resposta é boa porque é honesta e mostra domínio, sem inventar comportamento.

---

# Parte 6 - Roteiro de leitura em voz alta

Use este roteiro com o VS Code aberto.

## Minuto 1: entrada e autenticação

Abra `main.dart`:

> Aqui o aplicativo inicia. Como uso Firebase Auth e Firestore, inicializo Firebase antes do `runApp`. A configuração por plataforma vem do arquivo gerado pelo FlutterFire.

Abra `connect_crm_app.dart`:

> Aqui está o tema visual e o `AuthGate`. O `AuthGate` usa `userChanges()`: sem usuário, Login; com usuário, área principal; se o nome for atualizado, a saudação também muda.

Abra `login_screen.dart` e `register_screen.dart`:

> Login chama `signInWithEmailAndPassword`. Registro chama `createUserWithEmailAndPassword` e salva o nome no perfil com `updateDisplayName`. A senha fica sob responsabilidade do Firebase Auth.

## Minuto 2: navegação

Abra `main_shell.dart`:

> Esta é a estrutura após autenticação. Ela lê a lista do usuário e controla três abas com `NavigationBar` e `IndexedStack`.

Abra `dashboard_screen.dart`:

> O Dashboard permite buscar, abrir o cadastro e abrir detalhes. Esses fluxos usam `Navigator.push`.

Abra `client_detail_screen.dart`:

> A tela de detalhes abre edição passando o cliente existente ao formulário; também possui confirmação de exclusão.

## Minuto 3: dados e funcionalidades

Abra `client_form_screen.dart`:

> O mesmo formulário cria e edita. Ele verifica se recebeu um cliente; caso receba, preenche campos e atualiza, caso contrário cria.

Abra `sales_funnel_screen.dart`:

> O funil usa a lista recebida para contar status e calcular conversão.

Abra `reminders_screen.dart`:

> Os lembretes são clientes com follow-up preenchido, ordenados por data.

Abra `clients_repository.dart` e `firestore.rules` apenas se houver tempo ou pergunta:

> Os dados ficam por usuário, e a regra garante que cada usuário só acessa sua própria coleção.

---

# Parte 7 - Plano de estudo para hoje

## Rodada 1: compreensão

Leia na ordem:

1. `main.dart`
2. `connect_crm_app.dart`
3. `main_shell.dart`
4. `dashboard_screen.dart`
5. `client_form_screen.dart`
6. `client_detail_screen.dart`
7. `sales_funnel_screen.dart`
8. `reminders_screen.dart`
9. `clients_repository.dart`
10. `firestore.rules`

Para cada arquivo, responda sem consultar:

- Qual é a responsabilidade dele?
- Que dado ele recebe?
- Que tela ou serviço ele chama?
- Que parte da apresentação ele prova?

## Rodada 2: explicar apontando

Abra qualquer função e diga:

1. qual valor entra;
2. o que a função faz;
3. qual resultado aparece na interface ou no banco.

## Rodada 3: susto de professor

Peça perguntas aleatórias e responda em no máximo 20 segundos. Se não souber, volte ao arquivo específico, explique com suas palavras e repita.

---

# Cola de emergência

| Se apontar para... | Responda... |
| --- | --- |
| `main()` | Inicializa Firebase antes de abrir o app. |
| `AuthGate` | Decide Login ou área autenticada e acompanha atualizações do perfil. |
| `signInWithEmailAndPassword` | Autentica usuário no Firebase Auth. |
| `createUserWithEmailAndPassword` | Cria conta com e-mail e senha. |
| `updateDisplayName` | Guarda nome no perfil autenticado. |
| `_selectedIndex` | Diz qual aba inferior está ativa. |
| `IndexedStack` | Troca telas das abas preservando estado. |
| `Navigator.push` | Abre nova tela. |
| `Navigator.pop` | Volta para tela anterior. |
| `ClientFormScreen` | Cria ou edita cliente conforme receba um objeto. |
| `Client.fromDocument` | Transforma Firestore em objeto Dart. |
| `ClientsRepository` | Centraliza leitura e alterações no banco. |
| `watchClients()` | Observa clientes em tempo real. |
| `users/{userId}/clients` | Separa clientes por dono. |
| `firestore.rules` | Bloqueia acesso de outro usuário. |
| `where` | Filtra lista. |
| `setState` | Redesenha após mudança local. |
| `mounted` | Confirma que a tela ainda existe após espera assíncrona. |

## Resposta final para guardar na cabeça

> O app começa inicializando o Firebase. O `AuthGate` usa `userChanges()` para observar a autenticação e mudanças do nome, direcionando Login ou a área principal com a saudação atualizada. Depois do login, o `MainShell` lê os clientes do usuário e apresenta Início, Funil e Lembretes pela barra inferior. O Dashboard navega para formulário e detalhes usando `Navigator`. O formulário cria ou edita, e o repositório centraliza a comunicação com o Firestore no caminho individual de cada usuário, protegido pelas regras do banco.
