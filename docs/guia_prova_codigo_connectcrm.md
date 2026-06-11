# Guia de prova do codigo - ConnectCRM

Este guia resume os pontos mais provaveis de serem cobrados em uma prova baseada no codigo do ConnectCRM.

A regra de ouro para responder qualquer pergunta:

```txt
acao do usuario -> tela/funcao -> model/repositorio -> Firebase -> atualizacao da UI
```

---

## 1. O que o projeto faz

O ConnectCRM e um app mobile de CRM feito em Flutter/Dart com Firebase.

Ele permite:

- criar conta;
- fazer login;
- recuperar senha;
- cadastrar clientes/leads;
- editar e excluir clientes;
- buscar clientes;
- acompanhar funil de vendas;
- cadastrar follow-up;
- ver lembretes;
- registrar historico de interacoes;
- separar os dados por usuario.

Resposta curta:

"E um CRM mobile com autenticacao e banco em nuvem. O usuario loga pelo Firebase Auth e seus clientes ficam salvos no Firestore em `users/{uid}/clients`."

---

## 2. Arquivos mais importantes

### `lib/main.dart`

Ponto de entrada do app.

Faz:

- prepara Flutter;
- inicializa Firebase;
- chama `runApp`.

Resposta:

"O `main.dart` inicializa o Firebase antes de abrir a interface."

### `lib/firebase_options.dart`

Configuracoes publicas do Firebase geradas pelo FlutterFire CLI.

Resposta:

"Nao e senha. Sao configuracoes publicas para o app saber em qual projeto Firebase conectar."

### `lib/app/connect_crm_app.dart`

Configura tema e decide se mostra Login ou area logada.

Ponto marcante:

```dart
FirebaseAuth.instance.userChanges()
```

Resposta:

"O app escuta o estado do Firebase Auth. Se tem usuario, abre `MainShell`; se nao tem, abre `LoginScreen`."

### `lib/features/home/main_shell.dart`

Tela base apos login.

Faz:

- cria `ClientsRepository` com `user.uid`;
- escuta clientes em tempo real;
- mostra abas Inicio, Funil e Lembretes.

Resposta:

"O `MainShell` e o centro da area logada. Ele pega o UID do usuario e carrega os clientes desse usuario."

### `lib/features/clients/data/clients_repository.dart`

Arquivo mais importante para Firestore.

Faz:

- listar clientes;
- criar cliente;
- editar cliente;
- excluir cliente;
- listar interacoes;
- criar interacoes;
- excluir interacoes.

Resposta:

"O repositorio isola o banco. As telas nao montam caminho do Firestore diretamente."

---

## 3. Fluxo de cadastro de usuario

Arquivos:

- `register_screen.dart`
- `connect_crm_app.dart`

Fluxo:

```txt
Criar conta
-> RegisterScreen
-> _createAccount()
-> valida formulario
-> FirebaseAuth.createUserWithEmailAndPassword()
-> updateDisplayName()
-> salva perfil em users/{uid}
-> AuthGate percebe usuario logado
-> MainShell
```

O que falar:

"Quando o usuario toca em cadastrar, a tela valida nome, e-mail, senha e confirmacao. Depois chama `createUserWithEmailAndPassword`. O Firebase Auth cria a conta e devolve o usuario. O app atualiza o `displayName` e tenta salvar um perfil no Firestore em `users/{uid}`. Como o Auth muda o estado para logado, o `AuthGate` abre a area principal."

Pergunta: onde fica a senha?

Resposta:

"No Firebase Authentication. Eu nao salvo senha no Firestore."

Pergunta: o que salva no Firestore no cadastro?

Resposta:

"Nome, e-mail e `createdAt` no documento `users/{uid}`."

---

## 4. Fluxo de login

Arquivo:

- `login_screen.dart`

Fluxo:

```txt
Entrar
-> _signIn()
-> valida e-mail/senha
-> FirebaseAuth.signInWithEmailAndPassword()
-> _syncUserProfile()
-> AuthGate abre MainShell
```

O que falar:

"O login usa Firebase Auth. Depois de autenticar, o app sincroniza dados basicos do perfil no Firestore, como e-mail e `lastLoginAt`."

Pergunta: por que nao navega manualmente para Home?

Resposta:

"Porque o `AuthGate` escuta `userChanges()`. Quando o Firebase informa que tem usuario logado, a UI muda automaticamente."

---

## 5. Fluxo de criar novo lead/cliente

Arquivos:

- `dashboard_screen.dart`
- `client_form_screen.dart`
- `client.dart`
- `clients_repository.dart`

Fluxo:

```txt
Botao +
-> ClientFormScreen sem cliente
-> _isEditing false
-> _save()
-> cria objeto Client
-> repository.addClient()
-> client.toCreateMap()
-> Firestore users/{uid}/clients/{clientId}
-> watchClients atualiza telas
```

O que falar:

"A Dashboard abre `ClientFormScreen` sem passar cliente. Por isso a tela entende que e cadastro novo. Ao salvar, ela monta um objeto `Client` e chama `addClient`. O repositorio salva em `users/{uid}/clients`, e o Firestore gera o ID do documento."

Pergunta: por que lead e cliente sao o mesmo model?

Resposta:

"Porque lead e um cliente em uma etapa inicial. A diferenca esta no campo `status`, que pode ser `Novo Lead`, `Negociação` ou `Fechado`."

---

## 6. Fluxo de editar cliente

Arquivos:

- `client_detail_screen.dart`
- `client_form_screen.dart`
- `clients_repository.dart`

Fluxo:

```txt
Detalhe do cliente
-> Editar
-> ClientFormScreen com cliente existente
-> initState preenche campos
-> _isEditing true
-> repository.updateClient()
-> doc(client.id).update()
```

O que falar:

"A mesma tela cria e edita. Se recebe um `client`, ela preenche os campos no `initState` e chama `updateClient` ao salvar."

---

## 7. Fluxo de excluir cliente

Arquivo:

- `clients_repository.dart`

Fluxo:

```txt
Excluir
-> confirma AlertDialog
-> repository.deleteClient()
-> tenta apagar interacoes
-> apaga cliente
```

Ponto marcante:

O metodo tenta apagar as interacoes em batch. Se falhar por regra/permissao, ele ainda tenta apagar o cliente.

Resposta:

"A exclusao tenta limpar o historico junto do cliente para nao deixar dados relacionados sobrando."

---

## 8. Firestore e estrutura dos dados

Estrutura principal:

```txt
users/{userId}
users/{userId}/clients/{clientId}
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Resposta:

"Cada usuario tem seus proprios clientes. O UID do Firebase Auth vira o documento dentro de `users`."

Campos do cliente:

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

Campos da interacao:

```txt
type
notes
createdAt
```

---

## 9. Regras de seguranca

Arquivo:

- `firestore.rules`

Regra principal:

```txt
request.auth != null && request.auth.uid == userId
```

O que significa:

- precisa estar logado;
- o UID do usuario logado precisa ser igual ao `userId` do caminho.

Resposta:

"Mesmo que alguem tente acessar pelo app modificado ou por uma chamada direta, o Firestore bloqueia no servidor se o UID nao bater."

Exemplo:

```txt
Logado como abc -> pode acessar users/abc
Logado como abc -> nao pode acessar users/xyz
```

---

## 10. Streams e atualizacao em tempo real

Ponto marcante:

```dart
snapshots()
```

Usado em:

- `watchClients`;
- `watchInteractions`.

Resposta:

"O app usa stream do Firestore. Quando um cliente muda no banco, o `StreamBuilder` recebe uma nova lista e a tela atualiza."

Diferença importante:

- `Future`: retorna uma vez.
- `Stream`: pode retornar varias vezes ao longo do tempo.

---

## 11. Model `Client`

Arquivo:

- `client.dart`

Funcoes importantes:

- `fromDocument`: Firestore -> Dart.
- `toCreateMap`: Dart -> Firestore para criar.
- `toUpdateMap`: Dart -> Firestore para editar.
- `_readDate`: converte `Timestamp` ou `String` em `DateTime`.

Resposta:

"O model evita espalhar conversao de dados pela tela. A tela trabalha com `Client`, e o model sabe ler e salvar no Firestore."

---

## 12. Funil de vendas

Arquivo:

- `sales_funnel_screen.dart`

Calculo:

```txt
conversao = clientes fechados / total de clientes * 100
```

No codigo:

```dart
final conversion = total == 0 ? 0 : (closed / total * 100).round();
```

Resposta:

"O funil nao salva dados separados. Ele calcula tudo a partir da lista real de clientes e do campo `status`."

Pergunta: por que `total == 0 ? 0`?

Resposta:

"Para evitar divisao por zero quando nao existem clientes."

---

## 13. Lembretes

Arquivo:

- `reminders_screen.dart`

Lembretes sao clientes com:

```dart
nextFollowUp != null
```

Depois ordena por data.

Resposta:

"Nao existe uma colecao separada de lembretes. Lembrete e uma visao dos clientes que tem data de follow-up."

---

## 14. Historico de interacoes

Arquivos:

- `client_detail_screen.dart`
- `client_interaction.dart`
- `clients_repository.dart`

Fluxo:

```txt
Registrar interacao
-> abre dialog
-> cria ClientInteraction
-> addInteraction()
-> tenta salvar em subcolecao interactions
-> se falhar, salva em interactionLog no cliente
```

Ponto marcante:

Foi criado fallback porque a regra publicada do Firestore poderia nao liberar a subcolecao `interactions`.

Resposta:

"O caminho principal do historico e a subcolecao `interactions`, mas o codigo tem fallback em `interactionLog` para manter a funcionalidade funcionando mesmo se a regra online estiver atrasada."

---

## 15. Android real

Arquivo:

- `android/app/src/main/AndroidManifest.xml`

Permissoes importantes:

```xml
INTERNET
ACCESS_NETWORK_STATE
```

Resposta:

"No Android real o Firebase precisa de permissao de internet. Sem isso, login e cadastro podem ficar carregando."

---

## 16. Perguntas provaveis de prova

### O que e `FirebaseAuth.instance.userChanges()`?

E um stream que avisa quando o usuario loga, desloga ou muda dados do perfil.

### O que e `StreamBuilder`?

Widget que reconstrói a interface quando recebe novos dados de uma `Stream`.

### O que e `TextEditingController`?

Objeto usado para ler/controlar texto digitado em campos.

### O que e `GlobalKey<FormState>`?

Chave usada para validar o formulario inteiro.

### O que e `async/await`?

Forma de esperar operacoes assíncronas, como Firebase, sem travar a interface.

### O que e `try/catch`?

Tratamento de erro para evitar que o app quebre em falha de rede, permissao ou Firebase.

### O que e `FieldValue.serverTimestamp()`?

Timestamp gerado pelo servidor do Firebase.

### O que e `Timestamp.fromDate()`?

Conversao de `DateTime` do Dart para `Timestamp` do Firestore.

### Por que usar repositorio?

Para separar regra de banco das telas.

### Por que usar UID no caminho?

Para separar dados por usuario e facilitar regra de seguranca.

### Qual a diferenca entre Auth e Firestore?

Auth cuida de identidade/login/senha. Firestore salva dados da aplicacao.

---

## 17. Respostas longas prontas

### Explique o fluxo de novo cadastro

"O usuario abre a tela de cadastro, preenche nome, e-mail, senha e confirmacao. Ao tocar em cadastrar, `_createAccount` valida o formulario. Depois chama `FirebaseAuth.createUserWithEmailAndPassword`. O Firebase cria a conta e devolve o usuario. O app atualiza o `displayName` com o nome digitado e tenta salvar um perfil em `users/{uid}` no Firestore. Como o Auth muda o estado do usuario, o `AuthGate` percebe pelo `userChanges()` e abre `MainShell`."

### Explique o fluxo de criar lead

"Na Dashboard, o usuario toca no `+`. A tela `ClientFormScreen` abre sem cliente, entao `_isEditing` fica falso. Ao salvar, a tela valida o formulario, cria um objeto `Client` e chama `repository.addClient`. O repositorio usa `client.toCreateMap()` e salva em `users/{uid}/clients`. Como a lista usa `snapshots()`, a Dashboard, o Funil e os Lembretes atualizam automaticamente."

### Explique seguranca dos dados

"Os dados ficam dentro de `users/{uid}`. As regras do Firestore exigem `request.auth != null` e `request.auth.uid == userId`. Entao um usuario so consegue acessar documentos cujo caminho tenha o proprio UID."

### Explique o funil

"O funil recebe a lista real de clientes, conta quantos existem em cada status e calcula conversao com fechados dividido pelo total. Ele nao salva esses numeros porque sao derivados dos clientes."

---

## 18. Decorar antes da prova

Decore estas frases:

1. "Auth guarda login e senha; Firestore guarda dados do app."
2. "O UID do usuario separa os dados em `users/{uid}`."
3. "`snapshots()` faz a tela atualizar em tempo real."
4. "`Client.fromDocument` le do Firestore; `toCreateMap` e `toUpdateMap` salvam no Firestore."
5. "Funil e lembretes sao dados derivados dos clientes."
6. "As regras do Firestore protegem no servidor, nao so na interface."
7. "O repositorio centraliza acesso ao banco."

