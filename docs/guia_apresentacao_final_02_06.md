# ConnectCRM - Guia de apresentacao final

## Resumo em 30 segundos

O ConnectCRM e um aplicativo mobile de CRM feito em Flutter/Dart com Firebase. Ele permite criar conta, fazer login, cadastrar clientes, editar, excluir, acompanhar status no funil de vendas, ver lembretes de follow-up e registrar historico de interacoes.

Os dados ficam no Firebase:

- Login e senha: Firebase Authentication.
- Perfil, clientes e historico: Cloud Firestore.
- Estrutura principal: `users/{userId}/clients/{clientId}`.

## Onde comecar se o professor pedir para explicar o projeto

Abra estes arquivos nesta ordem:

1. `lib/main.dart`
2. `lib/firebase_options.dart`
3. `lib/app/connect_crm_app.dart`
4. `lib/features/auth/login_screen.dart`
5. `lib/features/auth/register_screen.dart`
6. `lib/features/home/main_shell.dart`
7. `lib/features/clients/data/clients_repository.dart`
8. `lib/features/clients/data/client.dart`
9. `lib/features/clients/screens/client_form_screen.dart`
10. `lib/features/clients/screens/client_detail_screen.dart`
11. `lib/features/dashboard/dashboard_screen.dart`
12. `lib/features/funnel/sales_funnel_screen.dart`
13. `lib/features/reminders/reminders_screen.dart`
14. `firestore.rules`

## Arquitetura geral

O projeto esta separado por funcionalidades:

- `app`: configuracao principal do app e controle de usuario logado.
- `auth`: telas de login, cadastro e recuperacao de senha.
- `home`: tela base com navegacao inferior.
- `dashboard`: pagina inicial com busca, metricas e lista de clientes.
- `clients`: modelo, repositorio, formularios, detalhes e widgets dos clientes.
- `funnel`: funil de vendas.
- `reminders`: lembretes de follow-up.
- `shared`: cores e componentes reaproveitados.

Resposta boa:

"Eu separei por feature para cada parte do app ficar facil de encontrar. A regra e: tela fica em `screens`, dados ficam em `data`, componentes reaproveitaveis ficam em `widgets` ou `shared`."

## Fluxo de inicializacao

Arquivo: `lib/main.dart`

O app chama `WidgetsFlutterBinding.ensureInitialized()` e depois inicializa o Firebase com:

```dart
Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
)
```

Resposta boa:

"Antes de abrir a interface, eu garanto que o Flutter esteja pronto e inicializo o Firebase. As opcoes mudam conforme a plataforma, Android, iOS ou Web."

## Fluxo completo: novo cadastro de usuario

Arquivos envolvidos:

- `lib/features/auth/register_screen.dart`
- `lib/app/connect_crm_app.dart`
- `lib/features/home/main_shell.dart`
- `lib/firebase_options.dart`

Passo a passo:

1. O usuario entra na tela de Login e toca em `Criar uma conta`.
2. O `Navigator` abre `RegisterScreen`.
3. O usuario preenche:
   - nome completo;
   - e-mail;
   - senha;
   - confirmacao de senha.
4. Quando toca em `Cadastrar`, a funcao `_createAccount()` e executada.
5. Antes de falar com Firebase, o formulario valida os campos com `_formKey.currentState!.validate()`.
6. Se tiver erro, o Flutter mostra a mensagem embaixo do campo e nao continua.
7. Se estiver tudo certo, `_isLoading` vira `true`, e o botao entra em estado de carregamento.
8. O app chama:

```dart
FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text,
)
```

9. O Firebase Authentication cria o usuario e devolve um `UserCredential`.
10. O app pega o `credential.user` e atualiza o nome com:

```dart
credential.user?.updateDisplayName(_nameController.text.trim())
```

11. Depois o app tenta salvar um perfil no Firestore em:

```txt
users/{uid}
```

Com os campos:

```txt
name
email
createdAt
```

12. Esse salvamento do perfil fica dentro de `_saveUserProfile(user)`.
13. O salvamento tem `timeout` e `try/catch`; se o Firestore demorar, o cadastro nao fica preso para sempre.
14. Quando o Firebase Auth reconhece o usuario logado, `AuthGate` em `connect_crm_app.dart` recebe essa mudanca pelo `userChanges()`.
15. Como agora existe usuario, o app sai da tela de autentificacao e mostra `MainShell`.
16. `MainShell` recebe o `User` logado e passa o `uid` para o repositorio de clientes.

Resposta se ele perguntar "onde a senha e salva?":

"Eu nao salvo a senha. O app envia a senha para o Firebase Auth pelo metodo `createUserWithEmailAndPassword`. Quem armazena e protege a senha e o Firebase. No Firestore eu salvo apenas dados de perfil, como nome e e-mail."

Resposta se ele perguntar "por que tem timeout?":

"Coloquei timeout porque em celular real, se a internet ou o Firestore travar, o usuario nao pode ficar infinitamente no loading. Assim o app volta com uma mensagem controlada."

Resposta se ele perguntar "o que acontece se o Firestore falhar ao salvar o perfil?":

"A conta ainda pode ser criada no Auth. O perfil no Firestore e complementar. Isso evita perder o cadastro por uma falha secundaria. Depois, no login, o app tambem tenta sincronizar o perfil."

Fluxo mental para decorar:

```txt
Botao Cadastrar
-> _createAccount
-> valida formulario
-> Firebase Auth cria usuario
-> updateDisplayName salva nome no Auth
-> Firestore salva perfil em users/{uid}
-> AuthGate percebe usuario logado
-> abre MainShell
```

## Configuracao do Firebase

Arquivo: `lib/firebase_options.dart`

Esse arquivo foi gerado pelo FlutterFire CLI. Ele guarda as configuracoes publicas do projeto Firebase para cada plataforma.

Importante:

- `projectId`: `connectcrm-5899e`
- Android usa o app registrado com package `br.com.connectcrm.connectcrm`.
- Web, Android e iOS tem configuracoes separadas.

Resposta boa:

"Esse arquivo nao guarda senha do usuario. Ele guarda chaves publicas de configuracao do Firebase, geradas pelo FlutterFire, para o app saber em qual projeto Firebase conectar."

## Controle de usuario logado

Arquivo: `lib/app/connect_crm_app.dart`

A classe `AuthGate` usa:

```dart
FirebaseAuth.instance.userChanges()
```

Se existe usuario logado, abre `MainShell`. Se nao existe, abre `LoginScreen`.

Resposta boa:

"O app nao decide manualmente se esta logado. Ele escuta o estado do Firebase Auth. Quando o Firebase informa que existe usuario, o app vai para a area principal."

## Login

Arquivo: `lib/features/auth/login_screen.dart`

Funcao principal:

```dart
signInWithEmailAndPassword
```

O login:

- valida e-mail e senha;
- chama Firebase Auth;
- sincroniza `name`, `email` e `lastLoginAt` no Firestore;
- tem recuperacao de senha por e-mail;
- mostra mensagens de erro amigaveis.

Resposta boa:

"A senha nao fica no meu Firestore. Ela e tratada pelo Firebase Authentication. No Firestore eu salvo apenas informacoes de perfil, como nome e e-mail."

## Cadastro

Arquivo: `lib/features/auth/register_screen.dart`

Funcao principal:

```dart
createUserWithEmailAndPassword
```

O cadastro:

- valida nome, e-mail, senha e confirmacao;
- cria o usuario no Firebase Auth;
- atualiza o `displayName`;
- tenta salvar perfil em `users/{uid}`;
- usa timeout para nao ficar carregando infinito se a conexao ou Firestore travar.

Resposta boa:

"O cadastro depende do Firebase Auth. O Firestore entra depois para salvar o perfil. Eu deixei o salvamento do perfil tolerante a erro para o usuario nao ficar preso se o banco demorar."

## Fluxo completo: login de usuario existente

Arquivos envolvidos:

- `lib/features/auth/login_screen.dart`
- `lib/app/connect_crm_app.dart`
- `lib/features/home/main_shell.dart`

Passo a passo:

1. O usuario preenche e-mail e senha.
2. Ao tocar em `Entrar`, roda `_signIn()`.
3. O formulario valida:
   - e-mail nao pode estar vazio;
   - e-mail precisa conter `@`;
   - senha nao pode estar vazia.
4. Se a validacao passa, `_isLoading` vira `true`.
5. O app chama:

```dart
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text,
)
```

6. Se o Firebase aprovar, ele devolve um `UserCredential`.
7. O app chama `_syncUserProfile(credential.user)`.
8. Essa sincronizacao grava ou atualiza em `users/{uid}`:

```txt
name
email
lastLoginAt
```

9. O `AuthGate`, que escuta `FirebaseAuth.instance.userChanges()`, percebe que agora existe usuario logado.
10. O app mostra `MainShell`.
11. Se der erro de Firebase, `_authMessage()` traduz o codigo tecnico para mensagem amigavel.

Exemplos de erros tratados:

- `invalid-email`: e-mail invalido.
- `user-disabled`: conta desativada.
- `user-not-found`: usuario nao encontrado.
- `wrong-password`: senha incorreta.
- `invalid-credential`: e-mail ou senha invalidos.
- `operation-not-allowed`: metodo E-mail/Senha nao ativado no Firebase.

Resposta boa:

"O login e controlado pelo Firebase Auth. Depois de autenticar, eu sincronizo informacoes basicas do usuario no Firestore, mas a decisao de estar logado vem do stream `userChanges()`."

Fluxo mental para decorar:

```txt
Botao Entrar
-> _signIn
-> valida formulario
-> Firebase Auth autentica
-> sincroniza perfil no Firestore
-> AuthGate escuta userChanges
-> abre MainShell
```

## Onde ficam login, nome, e-mail e senha

- Senha: Firebase Authentication, protegida pelo Firebase, nao aparece no app e nao aparece no Firestore.
- E-mail do login: Firebase Authentication.
- Nome do usuario: `displayName` no Auth e tambem no documento `users/{uid}`.
- Perfil do usuario: Firestore em `users/{userId}`.

Resposta boa:

"A senha nunca e salva por mim. Quem gerencia credenciais e o Firebase Auth. No Firestore ficam dados de aplicacao."

## Navegacao principal

Arquivo: `lib/features/home/main_shell.dart`

Usa `NavigationBar` com:

- Inicio
- Funil
- Lembretes

As telas ficam dentro de um `IndexedStack`.

Resposta boa:

"Usei `IndexedStack` para manter as telas vivas ao trocar de aba. Assim a navegacao inferior nao recria tudo toda hora."

## Fonte unica dos clientes

Arquivo: `lib/features/home/main_shell.dart`

O `MainShell` cria:

```dart
ClientsRepository(userId: widget.user.uid)
```

E usa:

```dart
repository.watchClients()
```

Esses clientes sao passados para Dashboard, Funil e Lembretes.

Resposta boa:

"As tres telas principais usam a mesma lista em tempo real vinda do Firestore. Quando muda um cliente, o Dashboard, o Funil e os Lembretes se atualizam."

## Modelo do cliente

Arquivo: `lib/features/clients/data/client.dart`

Campos principais:

- `id`
- `name`
- `company`
- `phone`
- `email`
- `status`
- `nextFollowUp`
- `notes`
- `createdAt`
- `updatedAt`

Status possiveis:

- Novo Lead
- Negociacao
- Fechado

Resposta boa:

"O model transforma documento do Firestore em objeto Dart e tambem transforma objeto Dart em map para salvar no banco."

## Repositorio de clientes

Arquivo: `lib/features/clients/data/clients_repository.dart`

Responsavel por isolar Firestore do resto do app.

Metodos:

- `watchClients`: lista clientes em tempo real.
- `addClient`: cria cliente.
- `updateClient`: edita cliente.
- `deleteClient`: exclui cliente e historico em batch.
- `watchInteractions`: lista historico.
- `addInteraction`: adiciona interacao.
- `deleteInteraction`: exclui interacao.

Resposta boa:

"Eu concentrei o acesso ao Firestore no repositorio. As telas nao precisam saber montar caminho do banco toda hora."

## Fluxo completo: criar novo lead/cliente no CRM

Arquivos envolvidos:

- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/clients/screens/client_form_screen.dart`
- `lib/features/clients/data/client.dart`
- `lib/features/clients/data/clients_repository.dart`
- `lib/features/home/main_shell.dart`

Passo a passo:

1. O usuario ja esta logado e esta dentro do `MainShell`.
2. `MainShell` cria um repositorio com o UID do usuario:

```dart
ClientsRepository(userId: widget.user.uid)
```

3. Na Home/Dashboard, o usuario toca no botao `+` ou no botao `Adicionar`.
4. O `DashboardScreen` abre a tela `ClientFormScreen` usando `Navigator.push`.
5. Como nenhum `client` e passado para a tela, ela entende que e um novo cadastro:

```dart
bool get _isEditing => widget.client != null;
```

Nesse caso `_isEditing` fica `false`.

6. O usuario preenche:
   - nome completo;
   - empresa;
   - telefone;
   - e-mail;
   - status no funil;
   - proximo follow-up;
   - observacoes.
7. O status inicial, se o usuario nao mudar, e:

```dart
clientStatuses.first
```

Que corresponde a:

```txt
Novo Lead
```

8. Quando toca em `Salvar cliente`, roda `_save()`.
9. Primeiro o formulario valida os campos. O nome precisa ter pelo menos 2 caracteres.
10. Depois o app monta um objeto `Client` em memoria:

```dart
final client = Client(
  id: widget.client?.id ?? '',
  name: _nameController.text.trim(),
  company: _companyController.text.trim(),
  phone: _phoneController.text.trim(),
  email: _emailController.text.trim(),
  status: _status,
  nextFollowUp: _nextFollowUp,
  notes: _notesController.text.trim(),
)
```

11. Como `_isEditing` e `false`, o app chama:

```dart
widget.repository.addClient(client)
```

12. Dentro de `ClientsRepository`, `addClient` faz:

```dart
_collection.add(client.toCreateMap())
```

13. A propriedade `_collection` aponta para:

```txt
users/{userId}/clients
```

14. O `toCreateMap()` converte o objeto Dart para um mapa que o Firestore entende.
15. `createdAt` e `updatedAt` usam:

```dart
FieldValue.serverTimestamp()
```

Assim o horario vem do servidor do Firebase, nao do celular.

16. Se tiver `nextFollowUp`, ele vira:

```dart
Timestamp.fromDate(nextFollowUp!)
```

17. O Firestore cria um documento com ID automatico em:

```txt
users/{uid}/clients/{clientId}
```

18. Depois de salvar, a tela fecha com:

```dart
Navigator.of(context).pop()
```

19. A lista da Home atualiza sozinha porque `MainShell` esta escutando:

```dart
repository.watchClients()
```

20. Como `watchClients()` usa `snapshots()`, qualquer mudanca no Firestore chega em tempo real.

Resposta se ele perguntar "por que lead e cliente usam a mesma tela?":

"Porque no CRM o lead tambem e um cliente em potencial. A diferenca esta no campo `status`. Se o status e `Novo Lead`, ele aparece como lead no funil."

Resposta se ele perguntar "onde aparece no Firebase?":

"Aparece em Firestore, dentro de `users`, no documento do UID do usuario logado, na subcolecao `clients`."

Resposta se ele perguntar "por que nao tem uma colecao global clients?":

"Porque separar por usuario deixa a seguranca mais simples. Cada usuario tem `users/{uid}/clients`, e a regra compara o UID logado com o UID do caminho."

Fluxo mental para decorar:

```txt
Botao +
-> ClientFormScreen sem client
-> _isEditing false
-> usuario preenche dados
-> _save valida
-> cria objeto Client
-> repository.addClient
-> client.toCreateMap
-> Firestore users/{uid}/clients
-> snapshots atualiza Dashboard/Funil/Lembretes
```

## Fluxo completo: editar cliente

Arquivos envolvidos:

- `lib/features/clients/screens/client_detail_screen.dart`
- `lib/features/clients/screens/client_form_screen.dart`
- `lib/features/clients/data/clients_repository.dart`
- `lib/features/clients/data/client.dart`

Passo a passo:

1. O usuario toca em um cliente na lista.
2. `DashboardScreen` abre `ClientDetailScreen` passando:
   - o `client`;
   - o `repository`.
3. Na tela de detalhe, o usuario toca no icone de editar ou no botao `Editar cliente`.
4. O app abre `ClientFormScreen`, agora passando o `client` existente.
5. No `initState()`, os controllers recebem os dados atuais:
   - nome;
   - empresa;
   - telefone;
   - e-mail;
   - observacoes;
   - status;
   - follow-up.
6. Como `widget.client != null`, `_isEditing` fica `true`.
7. Quando o usuario salva, o app monta um novo objeto `Client` com o mesmo `id`.
8. Como e edicao, chama:

```dart
widget.repository.updateClient(client)
```

9. O repositorio executa:

```dart
_collection.doc(client.id).update(client.toUpdateMap())
```

10. `toUpdateMap()` atualiza os campos e coloca novo `updatedAt`.
11. O Firestore muda o documento existente.
12. Como a lista esta sendo escutada por `snapshots()`, as telas refletem a alteracao.

Resposta boa:

"Editar nao cria outro documento. Ele usa o `id` do cliente e chama `update` no documento existente."

Fluxo mental:

```txt
Detalhe
-> Editar
-> ClientFormScreen com client
-> initState preenche campos
-> _isEditing true
-> updateClient
-> doc(client.id).update
```

## Fluxo completo: excluir cliente

Arquivo principal:

- `lib/features/clients/data/clients_repository.dart`

Passo a passo:

1. O usuario abre o detalhe do cliente.
2. Toca no icone de excluir.
3. O app mostra um `AlertDialog` pedindo confirmacao.
4. Se confirmar, chama:

```dart
repository.deleteClient(client.id)
```

5. O repositorio primeiro busca as interacoes desse cliente:

```dart
final interactions = await _interactions(clientId).get()
```

6. Depois cria um batch:

```dart
final batch = _firestore.batch()
```

7. Para cada interacao, adiciona uma exclusao no batch.
8. Depois adiciona a exclusao do cliente.
9. Por fim executa:

```dart
await batch.commit()
```

Resposta boa:

"Eu apago primeiro as subcolecoes de historico e depois o cliente, usando batch. Isso evita deixar interacoes orfas dentro de um cliente apagado."

Fluxo mental:

```txt
Excluir cliente
-> confirma dialog
-> busca interactions
-> batch delete interactions
-> batch delete client
-> commit
```

## Caminho dos dados no Firestore

Estrutura:

```txt
users/{userId}
users/{userId}/clients/{clientId}
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Resposta boa:

"Cada usuario tem sua propria subcolecao de clientes. Isso evita misturar clientes de usuarios diferentes."

## Criar e editar cliente

Arquivo: `lib/features/clients/screens/client_form_screen.dart`

A mesma tela serve para criar e editar.

Ela decide pelo valor:

```dart
widget.client != null
```

Se tem cliente, e edicao. Se nao tem, e novo cadastro.

Resposta boa:

"Reaproveitei a mesma tela para novo e editar. Quando vem um cliente preenchido, os campos carregam os dados existentes."

## Detalhe do cliente

Arquivo: `lib/features/clients/screens/client_detail_screen.dart`

Mostra:

- nome;
- empresa;
- telefone;
- e-mail;
- proximo follow-up;
- observacoes;
- status;
- historico de interacoes.

Permite:

- editar;
- excluir;
- registrar interacao;
- excluir interacao.

Resposta boa:

"A tela de detalhe e onde o usuario ve a ficha completa do cliente e consegue manter o historico de contatos."

## Historico de interacoes

Arquivos:

- `lib/features/clients/data/client_interaction.dart`
- `lib/features/clients/screens/client_detail_screen.dart`

Tipos:

- Contato
- Ligacao
- Reuniao
- E-mail
- Proposta

Caminho:

```txt
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Resposta boa:

"O historico fica dentro do cliente, como subcolecao. Isso deixa claro que cada interacao pertence a um cliente especifico."

## Fluxo completo: registrar interacao no historico

Arquivos envolvidos:

- `lib/features/clients/screens/client_detail_screen.dart`
- `lib/features/clients/data/client_interaction.dart`
- `lib/features/clients/data/clients_repository.dart`

Passo a passo:

1. O usuario abre o detalhe de um cliente.
2. Toca em `Registrar interação`.
3. O app abre um dialog para escolher o tipo e escrever uma observacao.
4. O dialog devolve um objeto `ClientInteraction`.
5. A tela chama:

```dart
repository.addInteraction(client.id, interaction)
```

6. O repositorio monta o caminho:

```txt
users/{userId}/clients/{clientId}/interactions
```

7. O metodo `toCreateMap()` salva:

```txt
type
notes
createdAt
```

8. `createdAt` usa `FieldValue.serverTimestamp()`.
9. A lista do historico esta dentro de um `StreamBuilder`.
10. Esse `StreamBuilder` escuta:

```dart
repository.watchInteractions(clientId)
```

11. Como usa `snapshots()`, a nova interacao aparece na tela sem precisar recarregar manualmente.

Resposta boa:

"O historico e reativo. Quando uma interacao e criada no Firestore, o stream atualiza a lista automaticamente."

Fluxo mental:

```txt
Registrar interacao
-> abre dialog
-> cria ClientInteraction
-> addInteraction
-> users/{uid}/clients/{clientId}/interactions
-> StreamBuilder atualiza historico
```

## Dashboard

Arquivo: `lib/features/dashboard/dashboard_screen.dart`

Tem:

- saudacao com nome do usuario;
- busca por nome ou empresa;
- total de clientes;
- total de fechados;
- lista de clientes;
- botao de adicionar cliente;
- logout.

Busca:

```dart
client.name.toLowerCase().contains(query) ||
client.company.toLowerCase().contains(query)
```

Resposta boa:

"A busca e local sobre a lista ja carregada do Firestore. Como e um app pequeno de CRM, isso deixa a interface simples e rapida."

## Funil de vendas

Arquivo: `lib/features/funnel/sales_funnel_screen.dart`

Calcula:

```txt
conversao = fechados / total * 100
```

Mostra:

- total no pipeline;
- taxa de conversao;
- contagem por status;
- clientes separados em Novo Lead, Negociacao e Fechado.

Resposta boa:

"O funil nao salva dados separados. Ele calcula tudo a partir dos clientes reais, usando o campo `status`."

## Fluxo completo: como o funil atualiza

Arquivos envolvidos:

- `lib/features/home/main_shell.dart`
- `lib/features/funnel/sales_funnel_screen.dart`
- `lib/features/clients/data/client.dart`

Passo a passo:

1. `MainShell` escuta todos os clientes do usuario com `watchClients()`.
2. A lista `clients` e passada para `SalesFunnelScreen`.
3. O funil calcula o total:

```dart
final total = clients.length;
```

4. Calcula quantos estao fechados:

```dart
final closed = clients.where((client) => client.status == 'Fechado').length;
```

5. Calcula a taxa de conversao:

```dart
final conversion = total == 0 ? 0 : (closed / total * 100).round();
```

6. Conta cada etapa usando `_countByStatus(status)`.
7. Separa os clientes por etapa usando `_clientsByStatus(status)`.
8. Quando o usuario edita um cliente e muda o status, o Firestore atualiza o documento.
9. O stream em `MainShell` recebe a lista nova.
10. O `SalesFunnelScreen` reconstrói com os novos valores.

Resposta se ele perguntar "onde a conversao e salva?":

"Ela nao e salva. Ela e calculada na hora a partir dos clientes reais. Isso evita duplicar informacao e evita dado inconsistente."

Resposta se ele perguntar "por que total zero vira conversao zero?":

"Para evitar divisao por zero. Se nao ha clientes, nao existe conversao calculavel, entao a interface mostra 0%."

Fluxo mental:

```txt
Clientes do Firestore
-> MainShell recebe stream
-> passa lista para Funil
-> conta por status
-> calcula fechados / total * 100
```

## Lembretes

Arquivo: `lib/features/reminders/reminders_screen.dart`

Filtra clientes com:

```dart
client.nextFollowUp != null
```

Depois ordena por data.

Tambem identifica follow-up atrasado comparando a data com o dia atual.

Resposta boa:

"A tela de lembretes nao tem uma colecao propria. Ela usa os clientes que possuem data de proximo follow-up."

## Fluxo completo: como os lembretes funcionam

Arquivos envolvidos:

- `lib/features/reminders/reminders_screen.dart`
- `lib/features/clients/screens/client_form_screen.dart`
- `lib/features/clients/data/client.dart`

Passo a passo:

1. No cadastro ou edicao do cliente, o usuario escolhe uma data em `Selecionar proximo follow-up`.
2. A tela usa `showDatePicker`.
3. A data escolhida fica em `_nextFollowUp`.
4. Ao salvar, o `Client` recebe esse valor em `nextFollowUp`.
5. No `toCreateMap()` ou `toUpdateMap()`, essa data vira `Timestamp` do Firestore.
6. A tela `RemindersScreen` recebe a mesma lista de clientes do `MainShell`.
7. Ela filtra apenas clientes com follow-up:

```dart
clients.where((client) => client.nextFollowUp != null)
```

8. Depois ordena por data:

```dart
sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!))
```

9. Para saber se esta atrasado, compara a data do follow-up com o dia atual, ignorando hora.
10. Se estiver atrasado, mostra cor vermelha. Se nao, mostra azul.

Resposta se ele perguntar "existe colecao reminders?":

"Nao. Lembrete e uma visao derivada dos clientes que tem `nextFollowUp`. Isso evita duplicar dados."

Resposta se ele perguntar "como identifica atrasado?":

"Eu comparo a data do follow-up com a data de hoje, normalizando para ano, mes e dia. Assim a comparacao nao depende da hora."

Fluxo mental:

```txt
Cliente tem nextFollowUp
-> Firestore salva Timestamp
-> Reminders filtra nextFollowUp != null
-> ordena por data
-> marca atrasado se for antes de hoje
```

## Regras de seguranca

Arquivo: `firestore.rules`

Regra principal:

```txt
request.auth != null && request.auth.uid == userId
```

Isso significa:

- precisa estar logado;
- so pode acessar dados cujo `userId` seja igual ao UID do usuario logado.

Resposta boa:

"Mesmo que alguem tente acessar outro caminho manualmente, a regra compara o UID autenticado com o ID do documento do usuario."

## Fluxo completo: seguranca do usuario no Firestore

Arquivo:

- `firestore.rules`

Estrutura protegida:

```txt
users/{userId}
users/{userId}/clients/{clientId}
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Regra:

```txt
request.auth != null && request.auth.uid == userId
```

Como pensar:

1. `request.auth != null` verifica se existe usuario autenticado.
2. `request.auth.uid` e o UID real do usuario logado no Firebase Auth.
3. `userId` vem do caminho do documento no Firestore.
4. A regra so libera se os dois forem iguais.

Exemplo permitido:

```txt
Usuario logado: abc123
Caminho acessado: users/abc123/clients/cliente1
Resultado: permitido
```

Exemplo bloqueado:

```txt
Usuario logado: abc123
Caminho acessado: users/xyz999/clients/cliente1
Resultado: negado
```

Resposta se ele perguntar "e se alguem mudar o caminho pelo console ou por request?":

"A regra roda no servidor do Firebase, nao no app. Mesmo que alguem altere o app ou tente chamar direto, o Firestore compara o UID autenticado e bloqueia."

Resposta se ele perguntar "por que usa subcolecao dentro de users?":

"Porque a estrutura do banco ja carrega o dono do dado no caminho. Isso facilita tanto consulta quanto regra de seguranca."

Fluxo mental:

```txt
App pede dado
-> Firebase Auth envia UID
-> Firestore olha caminho users/{userId}
-> regra compara request.auth.uid == userId
-> libera ou bloqueia
```

## Android real

Arquivos importantes:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/google-services.json`
- `android/app/build.gradle.kts`

O Manifest tem permissoes:

```xml
INTERNET
ACCESS_NETWORK_STATE
```

Isso permite Firebase Auth e Firestore funcionarem no celular fisico.

Resposta boa:

"No Android precisei declarar permissao de internet. Sem isso o app abre, mas chamadas ao Firebase podem ficar presas ou falhar."

## O que mostrar ao vivo

Ordem recomendada:

1. Abrir app no celular.
2. Fazer logout se ja estiver logado.
3. Criar uma conta nova.
4. Mostrar no Firebase Authentication que o usuario apareceu.
5. Adicionar um cliente.
6. Mostrar no Firestore em `users/{uid}/clients`.
7. Editar status para `Negociacao`.
8. Mostrar Funil atualizando.
9. Adicionar follow-up.
10. Mostrar Lembretes.
11. Abrir detalhe e registrar uma interacao.
12. Mostrar historico no app e no Firestore.

## Perguntas provaveis

### Por que Flutter?

"Porque o projeto precisava ser mobile e Flutter permite criar uma interface nativa para Android e iOS usando uma unica base em Dart."

### Por que Firebase?

"Porque o Firebase ja fornece autenticacao e banco em nuvem, entao nao precisei criar backend proprio."

### Por que Firestore e nao Realtime Database?

"Firestore organiza melhor os dados em colecoes e documentos, o que combina com usuarios, clientes e interacoes."

### Como separa dados de usuarios?

"Cada usuario usa o proprio UID como documento em `users/{uid}`. Os clientes ficam dentro desse documento."

### Como evita que um usuario veja cliente do outro?

"Pelas regras do Firestore. A regra exige que `request.auth.uid` seja igual ao `userId` do caminho."

### Onde esta o CRUD?

"No repositorio `clients_repository.dart`. As telas chamam esse repositorio para criar, listar, editar e excluir."

### O que acontece quando cria cliente?

"A tela monta um objeto `Client`, chama `addClient`, e o repositorio salva em `users/{uid}/clients` no Firestore."

### O que acontece quando edita cliente?

"A tela recebe o cliente existente, preenche os campos, e depois chama `updateClient` no documento daquele cliente."

### O que acontece quando exclui cliente?

"O repositorio busca as interacoes daquele cliente, apaga tudo em batch e depois apaga o cliente."

### Onde esta a taxa de conversao?

"Em `sales_funnel_screen.dart`. Ela e calculada com clientes fechados dividido pelo total de clientes."

### O app tem backend proprio?

"Nao. O backend usado e Firebase Auth mais Firestore."

### A senha fica salva onde?

"No Firebase Authentication. Eu nao salvo senha em codigo nem no Firestore."

### O que tem no Firestore?

"Perfil do usuario, clientes, dados do funil por status e historico de interacoes."

### O que voce faria se tivesse mais tempo?

"Melhoraria a validacao dos campos, colocaria notificacoes reais para follow-up, criaria testes automatizados para repositorio e melhoraria regras com validacao de campos."

## Frase final boa

"O projeto atende a proposta porque e um CRM mobile em Flutter/Dart, com autenticacao real, banco em nuvem, CRUD de clientes, funil, lembretes e separacao de dados por usuario usando Firebase."
