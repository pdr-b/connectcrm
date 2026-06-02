# Dossie tecnico completo - ConnectCRM

Este arquivo foi feito para ser enviado ao NotebookLM e servir como base de estudo para a apresentacao final do ConnectCRM.

O objetivo aqui nao e apenas dizer o que o app faz, mas explicar como o app funciona por dentro: fluxo de telas, Firebase Auth, Firestore, modelos de dados, repositorio, regras de seguranca, Android, navegacao e respostas para perguntas tecnicas.

---

## 1. Visao geral do projeto

O ConnectCRM e um aplicativo mobile de CRM simples, desenvolvido em Flutter/Dart, conectado ao Firebase.

CRM significa Customer Relationship Management, ou gerenciamento de relacionamento com clientes. A ideia do app e ajudar pequenos empreendedores, vendedores, autonomos e pequenas empresas a organizar seus contatos comerciais.

O app permite:

- criar conta;
- fazer login;
- recuperar senha por e-mail;
- cadastrar clientes/leads;
- editar clientes;
- excluir clientes;
- listar clientes;
- buscar clientes por nome ou empresa;
- acompanhar o status dos clientes em um funil de vendas;
- cadastrar data de proximo follow-up;
- visualizar lembretes de follow-up;
- registrar historico de interacoes com cada cliente;
- separar os dados por usuario logado.

O projeto final usa:

- Flutter;
- Dart;
- Firebase Authentication;
- Cloud Firestore;
- Material Design;
- navegacao com `Navigator`;
- Android real via USB para demonstracao.

O app nao usa backend proprio. O backend usado e o Firebase.

---

## 2. Frase curta para abrir a apresentacao

"O ConnectCRM e um aplicativo mobile feito em Flutter/Dart com Firebase Auth e Cloud Firestore. Ele permite que cada usuario crie sua conta, cadastre seus proprios clientes, acompanhe o funil de vendas, veja lembretes de follow-up e registre historico de interacoes. Os dados de cada usuario ficam separados em `users/{uid}/clients`, e as regras do Firestore impedem que um usuario acesse os dados de outro."

---

## 3. Tecnologias e responsabilidades

### Flutter

Flutter e o framework usado para construir a interface mobile. Ele controla as telas, formularios, botoes, navegacao, layout e componentes visuais.

No projeto, Flutter aparece principalmente em:

- `Scaffold`;
- `AppBar`;
- `TextFormField`;
- `NavigationBar`;
- `StreamBuilder`;
- `Future`;
- `Navigator`;
- `MaterialPageRoute`;
- `AlertDialog`;
- `showDatePicker`.

### Dart

Dart e a linguagem usada no projeto. Ela cria as classes, funcoes, modelos de dados, listas, validacoes e chamadas assíncronas.

Conceitos usados:

- classes;
- construtores;
- `StatefulWidget`;
- `StatelessWidget`;
- `Future`;
- `Stream`;
- `async` e `await`;
- `try/catch`;
- listas;
- filtros com `where`;
- ordenacao com `sort`;
- conversao de dados com `Map<String, dynamic>`.

### Firebase Authentication

Responsavel por login, cadastro, senha e sessao do usuario.

Usado para:

- criar usuario com e-mail e senha;
- autenticar usuario existente;
- recuperar senha por e-mail;
- saber se existe usuario logado;
- obter o `uid` do usuario;
- fazer logout.

### Cloud Firestore

Banco de dados em nuvem usado para salvar dados da aplicacao.

Usado para:

- perfil do usuario;
- clientes;
- historico de interacoes;
- datas de follow-up;
- status no funil.

### Material Design

Usado para criar interface padronizada e moderna:

- campos de texto;
- botoes;
- cards;
- icones;
- barra de navegacao inferior;
- dialogos;
- feedback visual.

---

## 4. Estrutura de pastas

Principais pastas:

```txt
lib/
  app/
  features/
    auth/
    clients/
    dashboard/
    funnel/
    home/
    reminders/
  shared/
  firebase_options.dart
  main.dart
```

### `lib/app`

Contem a configuracao principal do aplicativo e a decisao entre mostrar login ou area logada.

Arquivo principal:

- `connect_crm_app.dart`

### `lib/features/auth`

Contem telas e logicas de autenticacao.

Arquivos:

- `login_screen.dart`
- `register_screen.dart`

### `lib/features/home`

Contem a tela base apos login, com bottom navigation.

Arquivo:

- `main_shell.dart`

### `lib/features/dashboard`

Contem a tela inicial do CRM.

Arquivo:

- `dashboard_screen.dart`

### `lib/features/clients`

Contem tudo sobre clientes:

- modelo de cliente;
- modelo de interacao;
- repositorio do Firestore;
- tela de formulario;
- tela de detalhe;
- widgets da lista;
- chip de status.

Arquivos:

- `data/client.dart`
- `data/client_interaction.dart`
- `data/clients_repository.dart`
- `screens/client_form_screen.dart`
- `screens/client_detail_screen.dart`
- `widgets/client_list_tile.dart`
- `widgets/status_chip.dart`

### `lib/features/funnel`

Contem a tela de funil de vendas.

Arquivo:

- `sales_funnel_screen.dart`

### `lib/features/reminders`

Contem a tela de lembretes.

Arquivo:

- `reminders_screen.dart`

### `lib/shared`

Contem componentes e estilos reaproveitados.

Arquivos:

- `theme/app_colors.dart`
- `widgets/app_card.dart`
- `widgets/auth_card.dart`
- `widgets/empty_state.dart`
- `widgets/gradient_button.dart`

---

## 5. Fluxo macro do aplicativo

Fluxo geral:

```txt
main.dart
-> inicializa Firebase
-> ConnectCrmApp
-> AuthGate
-> verifica usuario logado
-> se nao logado: LoginScreen
-> se logado: MainShell
-> MainShell carrega clientes do Firestore
-> Dashboard / Funil / Lembretes
```

Explicacao:

1. O app inicia em `main.dart`.
2. O Firebase e inicializado com as configuracoes de `firebase_options.dart`.
3. O app abre `ConnectCrmApp`.
4. Dentro dele, `AuthGate` escuta o estado de autenticacao.
5. Se nao existe usuario logado, aparece `LoginScreen`.
6. Se existe usuario logado, aparece `MainShell`.
7. O `MainShell` cria um `ClientsRepository` usando o UID do usuario.
8. O repositorio escuta os clientes do Firestore em tempo real.
9. A mesma lista de clientes alimenta Dashboard, Funil e Lembretes.

---

## 6. Arquivo `main.dart`

Responsabilidade:

Inicializar o Flutter, inicializar o Firebase e abrir o app.

Fluxo:

```txt
WidgetsFlutterBinding.ensureInitialized()
-> Firebase.initializeApp()
-> runApp(ConnectCrmApp())
```

Explicacao:

`WidgetsFlutterBinding.ensureInitialized()` garante que o Flutter esteja pronto antes de qualquer chamada nativa ou Firebase.

`Firebase.initializeApp()` conecta o app ao Firebase usando:

```dart
DefaultFirebaseOptions.currentPlatform
```

Esse valor vem de `firebase_options.dart` e muda conforme a plataforma, por exemplo Android ou Web.

O `try/catch` em volta da inicializacao captura erro de configuracao Firebase. Se der erro, o app abre uma tela informando que o Firebase nao foi configurado corretamente.

Resposta se o professor perguntar:

"O `main.dart` e o ponto de entrada. Ele prepara o Flutter, conecta o Firebase e depois chama `runApp`. Sem inicializar o Firebase antes, Auth e Firestore nao funcionariam."

---

## 7. Arquivo `firebase_options.dart`

Responsabilidade:

Guardar as configuracoes publicas do Firebase para cada plataforma.

Esse arquivo foi gerado pelo FlutterFire CLI.

Ele contem configuracoes para:

- Web;
- Android;
- iOS.

Campos importantes:

- `apiKey`;
- `appId`;
- `messagingSenderId`;
- `projectId`;
- `storageBucket`;
- `authDomain` no caso Web;
- `iosBundleId` no caso iOS.

Project ID:

```txt
connectcrm-5899e
```

Resposta se o professor perguntar se isso e senha:

"Nao. O `firebase_options.dart` nao guarda senha de usuario. Ele guarda configuracoes publicas do app Firebase. A seguranca real vem do Firebase Auth e das regras do Firestore."

---

## 8. Arquivo `connect_crm_app.dart`

Responsabilidade:

Configurar o `MaterialApp`, tema visual e decidir qual tela mostrar conforme o usuario esta logado ou nao.

Componentes principais:

- `ConnectCrmApp`;
- `AuthGate`;
- `FirebaseConfigurationScreen`.

### `ConnectCrmApp`

Cria o `MaterialApp`.

Define:

- titulo `ConnectCRM`;
- remove banner de debug;
- tema Material 3;
- cor de fundo clara;
- cores roxo e azul;
- estilo dos campos de formulario.

### `AuthGate`

Esse e um dos pontos mais importantes do projeto.

Ele usa:

```dart
FirebaseAuth.instance.userChanges()
```

Esse stream informa sempre que o estado do usuario muda.

Se estiver carregando:

```txt
CircularProgressIndicator
```

Se existe usuario:

```txt
MainShell(user: snapshot.data!)
```

Se nao existe usuario:

```txt
LoginScreen
```

Resposta boa:

"O app nao navega manualmente depois do login. Ele escuta o estado do Firebase Auth. Quando o usuario loga ou cadastra, o stream atualiza e o `AuthGate` troca a tela para a area principal."

### Por que `userChanges()` e nao apenas `authStateChanges()`?

`userChanges()` tambem percebe atualizacoes no usuario, como `displayName`. Isso ajuda quando o cadastro atualiza o nome do usuario.

Resposta:

"Usei `userChanges()` porque alem de login/logout ele tambem reflete mudancas no perfil do usuario, como o nome exibido."

---

## 9. Fluxo completo de novo cadastro de usuario

Arquivo principal:

- `lib/features/auth/register_screen.dart`

Arquivos relacionados:

- `lib/app/connect_crm_app.dart`
- `lib/features/home/main_shell.dart`
- `lib/firebase_options.dart`

### Fluxo narrado

1. O usuario esta na tela de login.
2. Ele toca em `Criar uma conta`.
3. O app usa `Navigator.push` para abrir `RegisterScreen`.
4. Na tela de cadastro, o usuario preenche:
   - nome completo;
   - e-mail;
   - senha;
   - confirmar senha.
5. Cada campo usa `TextEditingController` para guardar o texto digitado.
6. Quando o usuario toca em `Cadastrar`, executa `_createAccount()`.
7. A primeira linha importante e:

```dart
if (!_formKey.currentState!.validate()) return;
```

8. Isso roda os validadores dos campos.
9. Se o nome for curto, e-mail invalido ou senhas diferentes, o app mostra erro e para.
10. Se a validacao passa, `_isLoading` vira `true`.
11. O botao mostra carregamento e evita clique duplicado.
12. O app chama o Firebase Authentication:

```dart
FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text,
)
```

13. `trim()` remove espacos antes e depois do e-mail.
14. Se o Firebase aprovar, ele cria a conta e retorna um `UserCredential`.
15. O app atualiza o nome do usuario no Auth:

```dart
credential.user?.updateDisplayName(_nameController.text.trim())
```

16. Depois tenta salvar perfil no Firestore com `_saveUserProfile(user)`.
17. O perfil e salvo em:

```txt
users/{uid}
```

18. Campos salvos:

```txt
name
email
createdAt
```

19. `createdAt` usa `FieldValue.serverTimestamp()`, ou seja, horario do servidor.
20. O salvamento do perfil tem `try/catch` e `timeout`.
21. Isso evita que o cadastro fique travado se o Firestore demorar.
22. Quando o usuario e criado, o Firebase Auth ja considera ele logado.
23. `AuthGate` detecta isso pelo `userChanges()`.
24. O app abre a area principal (`MainShell`).

### Fluxo em setas

```txt
Botao Criar uma conta
-> RegisterScreen
-> usuario preenche formulario
-> botao Cadastrar
-> _createAccount()
-> validate()
-> FirebaseAuth.createUserWithEmailAndPassword()
-> updateDisplayName()
-> Firestore users/{uid}
-> AuthGate percebe usuario logado
-> MainShell
```

### Respostas prontas

Pergunta: onde a senha e salva?

Resposta:

"A senha nao e salva por mim no Firestore. Ela e enviada ao Firebase Auth, e o Firebase gerencia a credencial com seguranca. No Firestore eu salvo apenas perfil, como nome e e-mail."

Pergunta: por que salvar nome tambem no Firestore?

Resposta:

"O Auth guarda o `displayName`, mas o Firestore permite consultar dados de perfil junto com dados do app. Entao mantenho um documento `users/{uid}` para informacoes da aplicacao."

Pergunta: por que o cadastro tem timeout?

Resposta:

"Porque no celular real, se a rede ou o Firestore travar, o loading nao pode ficar infinito. O timeout devolve controle para o usuario."

Pergunta: se o Firestore falhar, o usuario perde o cadastro?

Resposta:

"Nao necessariamente. O cadastro principal e no Firebase Auth. O salvamento de perfil e complementar e esta protegido com try/catch."

---

## 10. Fluxo completo de login

Arquivo:

- `lib/features/auth/login_screen.dart`

### Fluxo narrado

1. O usuario abre o app.
2. `AuthGate` percebe que nao ha usuario logado.
3. O app mostra `LoginScreen`.
4. O usuario digita e-mail e senha.
5. Os valores ficam em:
   - `_emailController`;
   - `_passwordController`.
6. Ao tocar em `Entrar`, roda `_signIn()`.
7. O formulario valida:
   - e-mail preenchido;
   - e-mail com `@`;
   - senha preenchida.
8. Se passar, `_isLoading` vira `true`.
9. O app chama:

```dart
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text,
)
```

10. Se o Firebase confirmar, retorna `UserCredential`.
11. O app chama `_syncUserProfile(credential.user)`.
12. Essa funcao atualiza em `users/{uid}`:
   - `name`;
   - `email`;
   - `lastLoginAt`.
13. O `SetOptions(merge: true)` permite atualizar sem apagar outros campos.
14. O `AuthGate` recebe a mudanca do Firebase Auth.
15. O app passa para `MainShell`.

### Fluxo em setas

```txt
LoginScreen
-> botao Entrar
-> _signIn()
-> validate()
-> signInWithEmailAndPassword()
-> _syncUserProfile()
-> AuthGate detecta usuario
-> MainShell
```

### Tratamento de erros

`_authMessage()` transforma codigos tecnicos em mensagens amigaveis.

Exemplos:

- `invalid-email`: e-mail invalido.
- `user-disabled`: conta desativada.
- `user-not-found`: usuario nao encontrado.
- `wrong-password`: senha incorreta.
- `invalid-credential`: e-mail ou senha invalidos.
- `operation-not-allowed`: login por e-mail/senha nao ativado no Firebase.

Resposta pronta:

"Eu nao deixo o erro bruto do Firebase aparecer para o usuario. Eu traduzo os codigos de erro para mensagens mais simples."

---

## 11. Fluxo de recuperacao de senha

Arquivo:

- `lib/features/auth/login_screen.dart`

Fluxo:

1. Usuario digita o e-mail.
2. Toca em `Esqueci minha senha`.
3. Roda `_sendPasswordResetEmail()`.
4. O app valida se o e-mail nao esta vazio e contem `@`.
5. Chama:

```dart
FirebaseAuth.instance.sendPasswordResetEmail(email: email)
```

6. O Firebase envia e-mail de recuperacao.
7. O app mostra `SnackBar` informando que o e-mail foi enviado.

Resposta:

"A recuperacao tambem e do Firebase Auth. O app so solicita o envio do e-mail; quem gera o link seguro e o Firebase."

---

## 12. MainShell e navegacao principal

Arquivo:

- `lib/features/home/main_shell.dart`

Responsabilidade:

Ser a tela principal apos login.

Ela contem:

- Dashboard;
- Funil;
- Lembretes;
- barra de navegacao inferior.

### Como funciona

`MainShell` recebe:

```dart
final User user;
```

Depois cria:

```dart
final repository = ClientsRepository(userId: widget.user.uid);
```

Isso e fundamental: o repositorio ja nasce sabendo qual usuario esta logado.

Depois usa:

```dart
StreamBuilder<List<Client>>(
  stream: repository.watchClients(),
)
```

Esse stream escuta os clientes do usuario no Firestore.

As telas recebem a mesma lista:

```txt
DashboardScreen
SalesFunnelScreen
RemindersScreen
```

### Por que `IndexedStack`?

O corpo da tela usa:

```dart
IndexedStack(index: _selectedIndex, children: screens)
```

Isso mantem as telas montadas mesmo quando troca de aba.

Resposta:

"Usei `IndexedStack` para preservar o estado das abas. Assim, ao trocar entre Inicio, Funil e Lembretes, as telas nao precisam ser recriadas do zero."

---

## 13. Modelo `Client`

Arquivo:

- `lib/features/clients/data/client.dart`

Responsabilidade:

Representar um cliente dentro do app.

Campos:

```txt
id
name
company
phone
email
status
nextFollowUp
notes
createdAt
updatedAt
```

Status possiveis:

```txt
Novo Lead
Negociação
Fechado
```

### `Client.fromDocument`

Transforma um documento do Firestore em objeto Dart.

Entrada:

```txt
DocumentSnapshot<Map<String, dynamic>>
```

Saida:

```txt
Client
```

Ele pega:

- `document.id` como `id`;
- campos do documento como `name`, `company`, etc.;
- datas convertidas por `_readDate`.

### `toCreateMap`

Transforma um `Client` em `Map<String, dynamic>` para criar no Firestore.

Inclui:

- `createdAt`;
- `updatedAt`;
- todos os dados principais.

### `toUpdateMap`

Transforma um `Client` em mapa para editar no Firestore.

Nao altera `createdAt`, apenas `updatedAt`.

### `_readDate`

Aceita:

- `Timestamp` do Firestore;
- `String` com data;
- `null`.

Isso deixa a leitura mais tolerante.

Resposta pronta:

"O model isola a conversao entre Firestore e Dart. A tela trabalha com objeto `Client`, e o model sabe transformar esse objeto em mapa para o banco."

---

## 14. Modelo `ClientInteraction`

Arquivo:

- `lib/features/clients/data/client_interaction.dart`

Responsabilidade:

Representar uma interacao no historico do cliente.

Campos:

```txt
id
type
notes
createdAt
```

Tipos:

```txt
Contato
Ligação
Reunião
E-mail
Proposta
```

Caminho no Firestore:

```txt
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Resposta pronta:

"A interacao fica dentro do cliente porque ela so faz sentido ligada a um cliente especifico."

---

## 15. Repositorio `ClientsRepository`

Arquivo:

- `lib/features/clients/data/clients_repository.dart`

Responsabilidade:

Centralizar o acesso ao Firestore.

As telas nao acessam diretamente caminhos do banco. Elas chamam o repositorio.

### Construtor

```dart
ClientsRepository({required this.userId, FirebaseFirestore? firestore})
```

Recebe `userId`, que vem do UID do usuario logado.

### Caminho principal

```dart
_firestore.collection('users').doc(userId).collection('clients')
```

Equivale a:

```txt
users/{userId}/clients
```

### Metodos

#### `watchClients`

Escuta clientes em tempo real:

```dart
_collection.orderBy('createdAt', descending: true).snapshots()
```

Depois converte documentos em `Client`.

Tambem ordena por nome:

```dart
clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()))
```

Resposta:

"Esse metodo usa stream do Firestore. Por isso, quando o banco muda, a interface atualiza automaticamente."

#### `addClient`

Cria cliente:

```dart
_collection.add(client.toCreateMap())
```

O Firestore gera um ID automatico.

#### `updateClient`

Atualiza cliente:

```dart
_collection.doc(client.id).update(client.toUpdateMap())
```

#### `watchInteractions`

Escuta historico de interacoes de um cliente.

#### `addInteraction`

Adiciona nova interacao em:

```txt
users/{userId}/clients/{clientId}/interactions
```

#### `deleteInteraction`

Exclui uma interacao especifica.

#### `deleteClient`

Exclui cliente e interacoes.

Ele:

1. busca as interacoes;
2. cria um batch;
3. adiciona exclusao de cada interacao;
4. adiciona exclusao do cliente;
5. executa `batch.commit()`.

Resposta:

"Usei batch para apagar o cliente junto com suas interacoes e evitar historico solto."

---

## 16. Fluxo completo: criar novo lead/cliente

Arquivos:

- `dashboard_screen.dart`
- `client_form_screen.dart`
- `client.dart`
- `clients_repository.dart`
- `main_shell.dart`

### Fluxo narrado

1. Usuario esta logado.
2. `MainShell` criou um `ClientsRepository` com o UID do usuario.
3. Usuario toca no botao `+` da Dashboard.
4. `DashboardScreen` abre `ClientFormScreen`.
5. A tela e aberta sem passar um cliente existente.
6. Portanto:

```dart
widget.client == null
```

7. Logo:

```dart
_isEditing == false
```

8. A tela mostra formulario de novo cliente.
9. O usuario preenche nome, empresa, telefone, e-mail, status, follow-up e observacoes.
10. Status inicial:

```txt
Novo Lead
```

11. Ao tocar `Salvar cliente`, roda `_save()`.
12. `_save()` valida o formulario.
13. O app cria um objeto `Client`.
14. Como `_isEditing` e falso, chama:

```dart
widget.repository.addClient(client)
```

15. O repositorio chama:

```dart
_collection.add(client.toCreateMap())
```

16. `_collection` aponta para:

```txt
users/{uid}/clients
```

17. O Firestore cria:

```txt
users/{uid}/clients/{clientId}
```

18. Depois a tela fecha.
19. `watchClients()` recebe o novo documento.
20. Dashboard, Funil e Lembretes recebem a lista atualizada.

### Fluxo em setas

```txt
Dashboard
-> botao +
-> ClientFormScreen sem cliente
-> _isEditing false
-> usuario preenche dados
-> _save()
-> cria objeto Client
-> addClient()
-> toCreateMap()
-> Firestore users/{uid}/clients/{clientId}
-> watchClients atualiza telas
```

### Resposta pronta

"Lead e cliente usam o mesmo model. O que diferencia um lead e o campo `status`. Quando o status e `Novo Lead`, ele aparece nessa etapa do funil."

---

## 17. Fluxo completo: editar cliente

Arquivos:

- `client_detail_screen.dart`
- `client_form_screen.dart`
- `clients_repository.dart`

Fluxo:

```txt
Usuario toca em cliente
-> abre ClientDetailScreen
-> toca editar
-> abre ClientFormScreen com client preenchido
-> initState copia dados para controllers
-> _isEditing true
-> usuario altera campos
-> _save()
-> updateClient()
-> doc(client.id).update()
-> Firestore atualiza documento
-> stream atualiza telas
```

Explicacao:

Quando `ClientFormScreen` recebe um `client`, ela usa `initState()` para preencher os controllers.

Isso reaproveita a mesma tela para criar e editar.

Resposta:

"A edicao nao cria novo documento. Ela usa o mesmo ID e chama `update` no documento existente."

---

## 18. Fluxo completo: excluir cliente

Arquivo:

- `client_detail_screen.dart`
- `clients_repository.dart`

Fluxo:

1. Usuario abre detalhe.
2. Toca no icone de lixeira.
3. App mostra dialogo de confirmacao.
4. Se confirmar, chama:

```dart
repository.deleteClient(client.id)
```

5. Repositorio busca interacoes.
6. Cria batch.
7. Apaga interacoes.
8. Apaga cliente.
9. Executa commit.
10. Tela fecha.
11. Lista atualiza via stream.

Resposta:

"Antes de apagar o cliente, eu apago as interacoes dele em batch. Assim nao deixo dados relacionados sobrando."

---

## 19. Dashboard

Arquivo:

- `lib/features/dashboard/dashboard_screen.dart`

Responsabilidades:

- mostrar saudacao;
- listar clientes;
- buscar clientes;
- mostrar metricas;
- adicionar cliente;
- abrir detalhe;
- logout.

### Saudacao

Usa:

```dart
widget.user.displayName
```

Se nao tiver nome, mostra:

```txt
usuário
```

### Busca

A busca usa `_query`.

Filtra por:

```dart
client.name.toLowerCase().contains(query)
client.company.toLowerCase().contains(query)
```

Ou seja, busca por nome ou empresa.

### Metricas

Mostra:

- total de clientes;
- total de fechados.

### Logout

Chama:

```dart
FirebaseAuth.instance.signOut()
```

Depois o `AuthGate` percebe que nao existe usuario e volta para login.

Resposta:

"O logout nao precisa de Navigator manual. Ao chamar `signOut`, o stream do Firebase Auth muda e o `AuthGate` volta para a tela de Login."

---

## 20. Tela de detalhe do cliente

Arquivo:

- `client_detail_screen.dart`

Mostra:

- status;
- nome;
- empresa;
- telefone;
- e-mail;
- proximo follow-up;
- observacoes;
- historico de interacoes.

Acoes:

- editar cliente;
- excluir cliente;
- registrar interacao;
- excluir interacao.

### Detalhe importante

Campos vazios aparecem como:

```txt
Não informado
```

Isso e feito em `_DetailRow`.

Resposta:

"A tela de detalhe funciona como ficha completa do cliente. E nela que o usuario ve informacoes, edita, exclui e registra contato."

---

## 21. Fluxo completo: registrar historico de interacao

Arquivos:

- `client_detail_screen.dart`
- `client_interaction.dart`
- `clients_repository.dart`

Fluxo:

```txt
Detalhe do cliente
-> Registrar interação
-> abre AlertDialog
-> usuario escolhe tipo e escreve descricao
-> cria ClientInteraction
-> repository.addInteraction(client.id, interaction)
-> Firestore users/{uid}/clients/{clientId}/interactions
-> StreamBuilder atualiza historico
```

Explicacao:

O dialogo nao salva diretamente no banco. Ele devolve um objeto `ClientInteraction` para a tela. A tela chama o repositorio, e o repositorio salva no Firestore.

Resposta:

"A interacao fica numa subcolecao do cliente, porque pertence diretamente a ele. Isso deixa o historico organizado e facil de carregar no detalhe."

---

## 22. Funil de vendas

Arquivo:

- `sales_funnel_screen.dart`

Responsabilidades:

- contar total de clientes;
- calcular conversao;
- contar clientes por status;
- listar clientes separados por etapa.

### Calculo da conversao

```dart
final total = clients.length;
final closed = clients.where((client) => client.status == 'Fechado').length;
final conversion = total == 0 ? 0 : (closed / total * 100).round();
```

Formula:

```txt
clientes fechados / total de clientes * 100
```

### Por que nao salva conversao no Firestore?

Porque conversao e dado derivado.

Resposta:

"Eu calculo a conversao na tela a partir dos clientes reais. Se eu salvasse a conversao, poderia ficar inconsistente quando um cliente mudasse de status."

### Fluxo de atualizacao do funil

```txt
Usuario edita status do cliente
-> Firestore atualiza campo status
-> watchClients recebe lista nova
-> MainShell passa lista para SalesFunnelScreen
-> Funil recalcula contagens e conversao
```

---

## 23. Lembretes

Arquivo:

- `reminders_screen.dart`

Responsabilidade:

Mostrar clientes que possuem `nextFollowUp`.

### Como filtra

```dart
clients.where((client) => client.nextFollowUp != null)
```

### Como ordena

```dart
sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!))
```

### Como identifica atrasado

Compara a data do follow-up com a data atual normalizada para dia, mes e ano.

Resposta:

"Nao existe uma colecao separada de lembretes. Lembrete e uma visao dos clientes que possuem data de follow-up."

---

## 24. Firestore - estrutura de dados

Estrutura principal:

```txt
users/{userId}
users/{userId}/clients/{clientId}
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

### Documento do usuario

Caminho:

```txt
users/{uid}
```

Campos:

```txt
name
email
createdAt
lastLoginAt
```

### Documento do cliente

Caminho:

```txt
users/{uid}/clients/{clientId}
```

Campos:

```txt
name
company
phone
email
status
nextFollowUp
notes
createdAt
updatedAt
```

### Documento de interacao

Caminho:

```txt
users/{uid}/clients/{clientId}/interactions/{interactionId}
```

Campos:

```txt
type
notes
createdAt
```

Resposta:

"A estrutura reflete a relacao dos dados: usuario tem clientes, cliente tem interacoes."

---

## 25. Regras de seguranca do Firestore

Arquivo:

- `firestore.rules`

Regra principal:

```txt
request.auth != null && request.auth.uid == userId
```

Significado:

- `request.auth != null`: precisa estar logado;
- `request.auth.uid`: UID real do usuario autenticado;
- `userId`: ID que aparece no caminho do Firestore;
- so libera se forem iguais.

### Exemplo permitido

```txt
Usuario logado: abc123
Caminho: users/abc123/clients/cliente1
Resultado: permitido
```

### Exemplo bloqueado

```txt
Usuario logado: abc123
Caminho: users/outroUsuario/clients/cliente1
Resultado: bloqueado
```

Resposta:

"A seguranca nao depende da interface. Mesmo se alguem tentar chamar o Firestore por fora do app, a regra roda no servidor e compara o UID autenticado."

---

## 26. Android real

Arquivos:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/google-services.json`
- `android/app/build.gradle.kts`

### AndroidManifest

Permissoes adicionadas:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Motivo:

Firebase Auth e Firestore precisam de internet no celular fisico.

Resposta:

"No navegador funcionava, mas no Android real precisei declarar permissao de internet. Sem ela o app abre, mas chamadas ao Firebase podem ficar carregando."

### `google-services.json`

Arquivo nativo Android gerado pelo Firebase/FlutterFire.

Ele conecta o app Android ao projeto Firebase correto.

### `build.gradle.kts`

Inclui plugin:

```txt
com.google.gms.google-services
```

Esse plugin processa `google-services.json`.

Resposta:

"No Android, alem do `firebase_options.dart`, existe o `google-services.json` e o plugin do Google Services para ligar o app nativo ao Firebase."

---

## 27. Visual e componentes compartilhados

### `AppColors`

Arquivo:

- `shared/theme/app_colors.dart`

Centraliza cores:

- fundo claro;
- texto escuro;
- cinza;
- borda;
- roxo;
- azul;
- verde;
- amarelo.

Resposta:

"Centralizar cor evita repetir valores e mantem identidade visual consistente."

### `GradientButton`

Arquivo:

- `shared/widgets/gradient_button.dart`

Botao com:

- gradiente roxo para azul;
- loading;
- icone opcional;
- estado desabilitado.

### `AppCard`

Arquivo:

- `shared/widgets/app_card.dart`

Card branco com:

- sombra leve;
- borda arredondada;
- clique opcional.

### `EmptyState`

Arquivo:

- `shared/widgets/empty_state.dart`

Usado quando nao ha clientes, lembretes ou resultados.

### `StatusChip`

Arquivo:

- `clients/widgets/status_chip.dart`

Mostra status com cor:

- `Fechado`: verde;
- `Negociação`: amarelo;
- outros: roxo.

---

## 28. O que mostrar ao vivo

Roteiro recomendado:

1. Abrir o app no celular Android real.
2. Fazer logout, se ja estiver logado.
3. Criar uma nova conta.
4. Mostrar no Firebase Authentication que o usuario foi criado.
5. Entrar no app.
6. Criar um cliente com status `Novo Lead`.
7. Mostrar no Firestore o documento em `users/{uid}/clients`.
8. Editar o cliente e mudar status para `Negociação`.
9. Mostrar que o Funil atualizou.
10. Editar e colocar data de follow-up.
11. Mostrar em Lembretes.
12. Abrir detalhe.
13. Registrar uma interacao.
14. Mostrar o historico no app.
15. Mostrar a subcolecao `interactions` no Firestore.
16. Fazer logout.

---

## 29. Perguntas tecnicas provaveis e respostas

### O que e o ConnectCRM?

"E um CRM mobile simples feito em Flutter/Dart com Firebase, para cadastrar clientes, acompanhar status no funil e controlar follow-ups."

### Qual e o backend?

"Nao tem backend proprio. Uso Firebase Auth para autenticacao e Cloud Firestore como banco."

### Onde o login acontece?

"Em `login_screen.dart`, com `FirebaseAuth.instance.signInWithEmailAndPassword`."

### Onde o cadastro acontece?

"Em `register_screen.dart`, com `createUserWithEmailAndPassword`."

### Onde a senha fica?

"No Firebase Authentication. Eu nao salvo senha no Firestore nem no codigo."

### Onde o nome do usuario fica?

"No `displayName` do Auth e tambem no Firestore em `users/{uid}`."

### Como o app sabe se o usuario esta logado?

"O `AuthGate` escuta `FirebaseAuth.instance.userChanges()`."

### Como os dados de usuarios diferentes ficam separados?

"O UID do usuario e usado no caminho `users/{uid}`. Cada usuario tem sua propria subcolecao `clients`."

### Como impede acesso a dados de outro usuario?

"Com as regras do Firestore, comparando `request.auth.uid` com `userId` do caminho."

### Onde esta o CRUD?

"O CRUD esta centralizado em `clients_repository.dart`."

### Como cria cliente?

"A tela `ClientFormScreen` monta um `Client`, chama `addClient`, e o repositorio salva em `users/{uid}/clients`."

### Como edita cliente?

"A mesma tela recebe um cliente existente, preenche os campos e chama `updateClient` com o ID do documento."

### Como exclui cliente?

"No detalhe, depois de confirmacao, chama `deleteClient`. O repositorio apaga interacoes e cliente em batch."

### Por que usar repositorio?

"Para separar tela de banco. A tela chama metodos como `addClient`, e o repositorio cuida do Firestore."

### Como a lista atualiza sozinha?

"Com `snapshots()` do Firestore dentro de `watchClients()`, consumido por `StreamBuilder`."

### Como o funil calcula conversao?

"Clientes fechados dividido pelo total de clientes, multiplicado por 100."

### Por que o funil nao salva dados no Firestore?

"Porque e uma informacao derivada dos clientes. Se salvar separado, pode ficar inconsistente."

### Como os lembretes funcionam?

"Eles filtram clientes que tem `nextFollowUp` e ordenam por data."

### Existe colecao de lembretes?

"Nao. Lembretes sao derivados dos clientes."

### Como registra historico?

"No detalhe do cliente, abre um dialogo, cria um `ClientInteraction` e salva na subcolecao `interactions` do cliente."

### O que e `FieldValue.serverTimestamp()`?

"E um timestamp gerado pelo servidor do Firebase, mais confiavel que o horario local do celular."

### O que e `Timestamp.fromDate()`?

"Converte um `DateTime` do Dart para um formato de data que o Firestore entende."

### Por que usa `try/catch`?

"Para tratar falhas de rede, Firebase ou permissao e mostrar mensagem ao usuario sem quebrar o app."

### Por que usa `mounted`?

"Para verificar se a tela ainda existe antes de chamar `setState`, `Navigator` ou `SnackBar` depois de uma operacao assíncrona."

### Por que `TextEditingController`?

"Para ler e controlar o texto digitado nos campos do formulario."

### Por que `StatefulWidget` em formularios?

"Porque a tela precisa guardar estado: loading, senha visivel ou oculta, status escolhido e data de follow-up."

### Por que algumas telas sao `StatelessWidget`?

"Porque recebem dados prontos e apenas renderizam, sem manter estado interno complexo."

### O que foi necessario para rodar no Android fisico?

"Instalar SDK, aceitar depuracao USB, configurar AndroidManifest com permissao de internet e rodar `flutter run -d ID_DO_CELULAR`."

---

## 30. Perguntas de fluxo com respostas longas

### Explique o fluxo de criacao de novo cadastro no app

"O usuario entra pela tela de login e toca em criar conta. O app abre `RegisterScreen` com `Navigator`. Ele preenche nome, e-mail, senha e confirmacao. Quando toca em cadastrar, roda `_createAccount()`. Primeiro o formulario valida os campos usando `_formKey.currentState!.validate()`. Se estiver tudo certo, o app chama `FirebaseAuth.instance.createUserWithEmailAndPassword`, passando e-mail e senha. O Firebase Auth cria a credencial e devolve um `UserCredential`. Depois o app atualiza o `displayName` com o nome digitado e tenta salvar um perfil em `users/{uid}` no Firestore com nome, e-mail e `createdAt`. Como o Firebase Auth ja muda o estado do usuario para logado, o `AuthGate`, que escuta `userChanges()`, percebe isso e abre a `MainShell`."

### Explique o fluxo de criacao de um novo lead dentro do CRM

"Dentro do app logado, o `MainShell` cria um `ClientsRepository` com o UID do usuario. Na Dashboard, quando o usuario toca no botao `+`, o app abre `ClientFormScreen` sem passar cliente. Como `widget.client` e nulo, `_isEditing` fica falso, entao a tela funciona como cadastro novo. O usuario preenche os campos, e o status inicial e `Novo Lead`. Ao salvar, `_save()` valida o formulario, monta um objeto `Client` e chama `repository.addClient(client)`. O repositorio converte o objeto com `client.toCreateMap()` e salva em `users/{uid}/clients` no Firestore. O Firestore cria um ID automatico. Como a lista principal usa `watchClients()` com `snapshots()`, a Home, o Funil e os Lembretes recebem a lista nova automaticamente."

### Explique como o funil muda quando edita o status

"Quando o usuario edita um cliente e muda o status, `ClientFormScreen` chama `repository.updateClient(client)`. O repositorio atualiza o documento no Firestore usando `doc(client.id).update(client.toUpdateMap())`. O `MainShell` esta ouvindo a colecao de clientes com `snapshots()`, entao recebe a mudanca. Ele passa a lista atualizada para `SalesFunnelScreen`, que recalcula total, fechados, conversao e contagem por status. O funil nao precisa salvar nada proprio."

### Explique como os lembretes aparecem

"O lembrete nasce no formulario do cliente, quando o usuario escolhe uma data em `showDatePicker`. Essa data fica em `nextFollowUp` no objeto `Client` e e salva no Firestore como `Timestamp`. A tela de lembretes recebe a lista de clientes do `MainShell`, filtra somente os clientes com `nextFollowUp != null`, ordena pela data e mostra na tela. Se a data for anterior ao dia atual, aparece como atrasada."

### Explique como o historico funciona

"O historico fica dentro da tela de detalhe do cliente. Quando o usuario toca em registrar interacao, o app abre um `AlertDialog`, o usuario escolhe o tipo e descreve a interacao. O dialogo retorna um objeto `ClientInteraction`. A tela chama `repository.addInteraction(client.id, interaction)`, e o repositorio salva em `users/{uid}/clients/{clientId}/interactions`. A tela tambem usa `StreamBuilder` com `watchInteractions`, entao quando a interacao e criada, o historico atualiza automaticamente."

---

## 31. Pontos de defesa se o professor apertar

### "Por que nao criou backend proprio?"

"Porque a proposta permite Firebase, e Firebase ja entrega autenticacao e banco em nuvem. Criar backend proprio aumentaria escopo sem necessidade para este projeto."

### "Por que Firestore e nao salvar local?"

"Porque o objetivo e ter dados associados ao usuario e persistidos em nuvem. Assim o usuario pode autenticar e acessar os dados pelo Firebase."

### "Por que nao criou uma colecao global `clients`?"

"Porque separando em `users/{uid}/clients`, a estrutura fica mais segura e direta para regras. Cada usuario acessa apenas sua propria area."

### "Como sabe que os dados sao do usuario certo?"

"O repositorio e criado com `user.uid`, vindo do Firebase Auth. Todos os caminhos do Firestore usam esse UID."

### "E se alguem alterar o app?"

"Mesmo alterando o app, as regras do Firestore continuam rodando no servidor. A regra exige que o UID autenticado seja igual ao UID do caminho."

### "Por que salvar datas como Timestamp?"

"Porque Firestore trabalha bem com `Timestamp`, permitindo ordenar e comparar datas de forma correta."

### "Qual parte e reativa?"

"A listagem de clientes e o historico usam streams do Firestore com `snapshots()`. Quando o banco muda, a interface recebe nova lista."

### "Tem alguma limitacao?"

"Sim. O app ainda poderia ter validacoes mais fortes de telefone/e-mail, notificacoes reais de follow-up e testes automatizados mais completos. Mas o fluxo principal de Auth, CRUD, funil, lembretes e historico esta implementado."

---

## 32. Arquivos que devem estar abertos no VS Code

Para apresentacao, deixe abertos:

1. `lib/main.dart`
2. `lib/app/connect_crm_app.dart`
3. `lib/features/auth/login_screen.dart`
4. `lib/features/auth/register_screen.dart`
5. `lib/features/home/main_shell.dart`
6. `lib/features/clients/data/client.dart`
7. `lib/features/clients/data/clients_repository.dart`
8. `lib/features/clients/screens/client_form_screen.dart`
9. `lib/features/clients/screens/client_detail_screen.dart`
10. `lib/features/dashboard/dashboard_screen.dart`
11. `lib/features/funnel/sales_funnel_screen.dart`
12. `lib/features/reminders/reminders_screen.dart`
13. `firestore.rules`
14. `android/app/src/main/AndroidManifest.xml`

---

## 33. Comandos uteis

Rodar no celular fisico:

```sh
flutter run -d RQ8M308H0EX
```

Listar dispositivos:

```sh
flutter devices
```

Ver dispositivos ADB:

```sh
/Users/pedro/Library/Android/sdk/platform-tools/adb devices
```

Publicar regras do Firestore, se necessario:

```sh
firebase deploy --only firestore:rules
```

Analisar Dart:

```sh
dart analyze lib
```

---

## 34. Mapa mental final

```txt
Firebase Auth
  -> cria usuario
  -> faz login
  -> recupera senha
  -> fornece UID

UID
  -> usado pelo ClientsRepository
  -> monta caminho users/{uid}
  -> separa dados por usuario

Firestore
  -> users/{uid}
  -> users/{uid}/clients/{clientId}
  -> users/{uid}/clients/{clientId}/interactions/{interactionId}

MainShell
  -> escuta clients com snapshots()
  -> envia lista para Dashboard
  -> envia lista para Funil
  -> envia lista para Lembretes

Dashboard
  -> busca
  -> lista
  -> adiciona cliente

ClientForm
  -> cria ou edita
  -> monta Client
  -> chama repository

ClientDetail
  -> mostra ficha
  -> edita
  -> exclui
  -> historico

Funil
  -> calcula por status
  -> calcula conversao

Lembretes
  -> filtra nextFollowUp
  -> ordena por data
```

---

## 35. Resposta final se perguntarem "defenda seu projeto"

"O ConnectCRM entrega um fluxo completo de CRM mobile. Ele tem autenticacao real com Firebase Auth, persistencia em nuvem com Firestore, CRUD completo de clientes, separacao de dados por usuario, funil de vendas calculado a partir dos dados reais, lembretes baseados em follow-up e historico de interacoes por cliente. A arquitetura foi separada por funcionalidades, com repositorio isolando o acesso ao banco, models fazendo conversao entre Firestore e Dart, e telas consumindo dados de forma reativa com streams."

