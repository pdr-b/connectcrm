# Explicação técnica: Login, Registro e Firebase Auth

Este documento serve como roteiro para explicar a parte de autenticação do ConnectCRM. Os arquivos principais são:

- `lib/main.dart`
- `lib/firebase_options.dart`
- `lib/app/connect_crm_app.dart`
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`

## Visão geral

O ConnectCRM foi desenvolvido em Flutter/Dart e usa Firebase para autenticação. A autenticação não foi implementada manualmente com backend próprio. O app usa o serviço Firebase Authentication, que cuida da criação de conta, login, sessão do usuário e logout.

No fluxo atual, o usuário pode:

- Criar uma conta com nome, e-mail e senha.
- Entrar usando e-mail e senha.
- Permanecer logado enquanto a sessão do Firebase estiver ativa.
- Sair da conta usando logout.

O e-mail e a senha são gerenciados pelo Firebase Authentication. A senha não fica visível no app, no código nem no Firestore. O Firebase armazena essa informação de forma segura. O nome informado no cadastro é salvo no perfil do usuário como `displayName`.

## 1. Inicialização do Firebase

Arquivo:

```txt
lib/main.dart
```

Esse é o ponto de entrada do app. Antes de renderizar a interface, o Flutter precisa garantir que os bindings estejam prontos:

```dart
WidgetsFlutterBinding.ensureInitialized();
```

Depois disso, o Firebase é inicializado:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Essa linha conecta o app Flutter ao projeto Firebase correto. O parâmetro `DefaultFirebaseOptions.currentPlatform` escolhe automaticamente as configurações adequadas para Web, Android ou iOS.

O código também captura erro de configuração:

```dart
Object? firebaseError;
```

Se a inicialização falhar, o erro é enviado para `ConnectCrmApp`. Assim, o app pode mostrar uma tela informando que o Firebase ainda não foi configurado corretamente.

Resumo para falar:

> No `main.dart`, eu inicializo o Firebase antes de abrir o app. Isso garante que o Firebase Auth esteja disponível quando as telas de login e registro forem usadas.

## 2. Configurações do Firebase

Arquivo:

```txt
lib/firebase_options.dart
```

Esse arquivo foi gerado automaticamente pelo FlutterFire CLI. Ele contém as opções de configuração do Firebase para cada plataforma:

- Web
- Android
- iOS

O método principal é:

```dart
DefaultFirebaseOptions.currentPlatform
```

Ele verifica se o app está rodando na Web ou em alguma plataforma específica e retorna as credenciais corretas.

Exemplo:

```dart
if (kIsWeb) {
  return web;
}
```

E para mobile:

```dart
case TargetPlatform.android:
  return android;
case TargetPlatform.iOS:
  return ios;
```

Resumo para falar:

> O `firebase_options.dart` é o arquivo de configuração gerado pelo FlutterFire. Ele permite que o mesmo código Flutter funcione em Web, Android e iOS usando o mesmo projeto Firebase.

## 3. Estrutura principal do app e controle de sessão

Arquivo:

```txt
lib/app/connect_crm_app.dart
```

Esse arquivo define o `MaterialApp`, o tema visual do app e o controle de autenticação.

O app usa:

```dart
MaterialApp(
  title: 'ConnectCRM',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(...),
)
```

Também existe uma classe muito importante chamada `AuthGate`.

O `AuthGate` usa:

```dart
FirebaseAuth.instance.userChanges()
```

Esse método retorna um stream que avisa automaticamente quando o estado de autenticação ou os dados do perfil, como o nome, mudam.

O funcionamento é:

- Se estiver carregando, mostra `CircularProgressIndicator`.
- Se existir usuário logado, abre a tela principal do app.
- Se não existir usuário logado, abre a tela de login.

Trecho principal:

```dart
if (snapshot.hasData) {
  return MainShell(user: snapshot.data!);
}

return const LoginScreen();
```

Isso significa que a navegação depende do estado real do Firebase Auth. Quando o usuário faz login, o stream atualiza e o app entra. Quando o nome do perfil é atualizado, a saudação também atualiza. Quando o usuário faz logout, o app volta para login.

Resumo para falar:

> O `AuthGate` é o controle de sessão e perfil do app. Ele escuta o Firebase Auth em tempo real. Se tem usuário logado, mostra o app e o nome atualizado; se não tem, mostra Login.

## 4. Tela de Login

Arquivo:

```txt
lib/features/auth/login_screen.dart
```

Essa tela possui dois campos principais:

- E-mail
- Senha

Os dados digitados são controlados por:

```dart
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
```

Antes de tentar login, o app valida o formulário:

```dart
if (!_formKey.currentState!.validate()) return;
```

A autenticação acontece neste método:

```dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text,
);
```

Aqui o app envia e-mail e senha para o Firebase Authentication. O app não verifica a senha manualmente. Quem valida é o Firebase.

O `trim()` no e-mail remove espaços antes ou depois:

```dart
email: _emailController.text.trim()
```

Isso evita erro se o usuário digitar um espaço sem querer.

A tela também trata erros específicos usando `FirebaseAuthException`. Exemplos:

```dart
'invalid-email' => 'Informe um e-mail valido.'
'user-not-found' => 'Nenhuma conta encontrada com este e-mail.'
'wrong-password' => 'Senha incorreta.'
'invalid-credential' => 'E-mail ou senha invalidos.'
```

Se o método de e-mail/senha não estiver habilitado no Firebase Console, o app informa:

```dart
'operation-not-allowed' =>
  'Ative o login por E-mail/Senha no Firebase Authentication.'
```

Resumo para falar:

> Na tela de login, eu uso `signInWithEmailAndPassword`. O Firebase recebe o e-mail e a senha, valida os dados e, se estiver correto, cria uma sessão para o usuário.

## 5. Tela de Registro

Arquivo:

```txt
lib/features/auth/register_screen.dart
```

Essa tela possui quatro campos:

- Nome completo
- E-mail
- Senha
- Confirmar senha

Cada campo tem um `TextEditingController`, por exemplo:

```dart
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
```

O cadastro só continua se o formulário for válido:

```dart
if (!_formKey.currentState!.validate()) return;
```

A senha precisa ter pelo menos 6 caracteres:

```dart
if ((value ?? '').length < 6) {
  return 'Use pelo menos 6 caracteres.';
}
```

E a confirmação precisa ser igual à senha:

```dart
if (value != _passwordController.text) {
  return 'As senhas precisam ser iguais.';
}
```

A conta é criada com:

```dart
final credential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
```

Depois disso, o nome é salvo no perfil do usuário:

```dart
await credential.user?.updateDisplayName(_nameController.text.trim());
```

Esse nome não é salvo no Firestore nessa parte. Ele fica no perfil do usuário dentro do Firebase Auth como `displayName`.

Depois de cadastrar, a tela volta para Login:

```dart
if (mounted) Navigator.of(context).pop();
```

Como o Firebase Auth já criou a sessão, o `AuthGate` detecta o usuário logado e pode levar o usuário para a área principal do app.

Resumo para falar:

> No registro, eu uso `createUserWithEmailAndPassword` para criar a conta no Firebase Auth. Depois uso `updateDisplayName` para salvar o nome no perfil do usuário.

## 6. Onde os dados aparecem no Firebase

As contas criadas aparecem em:

```txt
Firebase Console > Authentication > Users
```

Lá aparecem informações como:

- UID do usuário
- E-mail
- Data de criação
- Último login

A senha não aparece no painel.

Os clientes do CRM aparecem no Firestore, neste caminho:

```txt
users/{userId}/clients/{clientId}
```

Esse `userId` é o UID do usuário autenticado pelo Firebase Auth.

Resumo para falar:

> Usuários ficam no Firebase Authentication. Dados do CRM ficam no Firestore. Eu uso o UID do usuário para separar os clientes de cada conta.

## 7. Perguntas técnicas prováveis

### Por que usar Firebase Auth?

Porque ele já fornece um sistema seguro de autenticação. Com ele, eu não preciso criar um backend próprio para lidar com senha, sessão e validação de usuário.

### Onde a senha fica salva?

A senha é gerenciada pelo Firebase Authentication. Ela não aparece no app, no código, nem no Firestore. O Firebase armazena de forma segura.

### Como o app sabe que o usuário está logado?

Pelo stream:

```dart
FirebaseAuth.instance.userChanges()
```

Esse stream avisa quando o usuário entra ou sai da conta e quando seu perfil autenticado é atualizado.

### O que acontece depois do login?

Depois do login, o Firebase atualiza o estado de autenticação. O `AuthGate` percebe que existe um usuário logado e abre `MainShell`, que é a área principal do app.

### O que acontece no logout?

O app chama:

```dart
FirebaseAuth.instance.signOut();
```

Depois disso, o stream de autenticação muda para `null`, e o `AuthGate` volta para a tela de Login.

### Qual é a diferença entre Auth e Firestore?

Firebase Auth guarda a identidade do usuário: login, e-mail, senha e sessão. Firestore guarda os dados do aplicativo, como clientes, status e follow-ups.

## 8. Roteiro para mostrar no VS Code

1. Abrir `lib/main.dart`.
   - Mostrar `Firebase.initializeApp`.
   - Explicar que o Firebase é iniciado antes do app.

2. Abrir `lib/firebase_options.dart`.
   - Mostrar `DefaultFirebaseOptions.currentPlatform`.
   - Explicar que o arquivo foi gerado pelo FlutterFire.

3. Abrir `lib/app/connect_crm_app.dart`.
   - Mostrar `AuthGate`.
   - Mostrar `userChanges`.
   - Explicar a decisão entre Login e área principal.

4. Abrir `lib/features/auth/login_screen.dart`.
   - Mostrar `signInWithEmailAndPassword`.
   - Explicar que o Firebase valida e-mail e senha.

5. Abrir `lib/features/auth/register_screen.dart`.
   - Mostrar `createUserWithEmailAndPassword`.
   - Mostrar `updateDisplayName`.
   - Explicar criação de conta e salvamento do nome.

6. Se perguntarem de dados do CRM, abrir `lib/features/clients/data/clients_repository.dart`.
   - Mostrar o caminho `users/{userId}/clients`.
   - Explicar separação de dados por usuário.

## 9. Resposta curta para apresentação

> O app inicializa o Firebase no `main.dart` usando as opções geradas pelo FlutterFire. Depois, no `ConnectCrmApp`, eu uso um `AuthGate` que escuta `FirebaseAuth.instance.userChanges()`. Se existir usuário logado, o app abre a área principal; se não existir, mostra Login; e se o nome do perfil for atualizado, a saudação muda. Na tela de Login, uso `signInWithEmailAndPassword`. Na tela de Registro, uso `createUserWithEmailAndPassword` e salvo o nome com `updateDisplayName`. Assim, o Firebase Auth gerencia login, senha, sessão e logout de forma segura.
