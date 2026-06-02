# ConnectCRM — Contexto do Projeto

## Estado atual do projeto

Projeto Flutter/Dart já criado na pasta `LP3`.

A parte antiga de Figma/React/Vite foi removida do repositório porque não será usada no projeto final.

O app está conectado ao Firebase:

- Firebase Project ID: `connectcrm-5899e`
- Firebase Auth configurado no código
- Apps Firebase registrados para Android, iOS e Web
- Firestore Database criado no projeto Firebase
- Regras do Firestore publicadas com sucesso
- Arquivo de opções gerado em `lib/firebase_options.dart`
- Arquivos nativos gerados:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

Etapa entregue para 12/05:

- Estrutura inicial Flutter criada
- Tela de Login criada
- Tela de Registro criada
- Login conectado ao Firebase Auth
- Registro conectado ao Firebase Auth
- Home temporária após login/cadastro
- Logout na Home
- Visual moderno com fundo claro, cards arredondados e botões em gradiente roxo/azul
- Código separado por arquivos organizados

Etapas 2 e 3 implementadas no código:

- Home/Dashboard final com busca, métricas e lista de clientes
- Tela de Novo Cliente
- Tela de Editar Cliente
- Tela de Detalhe do Cliente
- Tela de Funil de Vendas
- Tela de Lembretes
- Navegação entre todas as telas
- Bottom navigation com Início, Funil e Lembretes
- Firebase Firestore adicionado ao projeto
- CRUD de clientes conectado ao Firestore
- Clientes separados por usuário em `users/{userId}/clients/{clientId}`
- Perfil do usuário salvo em `users/{userId}` no cadastro e sincronizado no login
- Recuperação de senha por e-mail na tela de Login com Firebase Auth
- Histórico de interações conectado ao Firestore em `users/{userId}/clients/{clientId}/interactions/{interactionId}`
- Funil e Lembretes atualizados com dados reais do Firestore
- Regras de Firestore criadas em `firestore.rules`
- Regras de Firestore atualizadas localmente para perfis, clientes e interações

Validação feita:

- `flutter analyze` sem erros
- `flutter test` passando
- `flutter build web` passando
- App executado em celular Android fisico Samsung via USB
- Login e cadastro testados com sucesso no Android
- Permissoes Android de internet adicionadas ao `AndroidManifest.xml`

Importante:

- O método `Email/Password` precisa estar habilitado no Firebase Console em `Authentication > Sign-in method`.
- Firestore Database já foi criado pelo Firebase CLI.
- As regras locais permitem que cada usuário acesse apenas seu perfil, seus clientes e suas interações.

## Pendências / melhorias futuras

- Publicar novamente as regras de `firestore.rules` caso haja alteracao futura nas regras de seguranca.
- Melhorar validacoes de formulario e mensagens de erro.
- Adicionar testes automatizados para regras de negocio do repositorio.

---

## Estrutura atual principal

Arquivos e pastas importantes:

- `lib/main.dart`
- `lib/firebase_options.dart`
- `lib/app/connect_crm_app.dart`
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`
- `lib/features/home/main_shell.dart`
- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/clients/data/client.dart`
- `lib/features/clients/data/client_interaction.dart`
- `lib/features/clients/data/clients_repository.dart`
- `lib/features/clients/screens/client_form_screen.dart`
- `lib/features/clients/screens/client_detail_screen.dart`
- `lib/features/funnel/sales_funnel_screen.dart`
- `lib/features/reminders/reminders_screen.dart`
- `lib/shared/widgets/auth_card.dart`
- `lib/shared/widgets/gradient_button.dart`
- `docs/context.md`
- `pubspec.yaml`
- `firebase.json`
- `firestore.rules`
- `.firebaserc`

---

## Objetivo geral

O ConnectCRM é um aplicativo mobile de CRM simples, desenvolvido em Flutter/Dart com Firebase.

O objetivo do app é ajudar pequenos empreendedores, vendedores, autônomos e pequenas empresas a organizar clientes, acompanhar negociações e controlar follow-ups.

O projeto final NÃO será feito em Figma, React ou Vite. O projeto final deve ser totalmente em Flutter/Dart, usando Firebase Auth e Firebase Firestore.

---

## Tecnologias finais obrigatórias

- Flutter
- Dart
- Firebase Authentication
- Firebase Firestore
- Material Design / Widgets Flutter
- Navegação entre telas com Flutter Navigator ou GoRouter

---

## Identidade visual

O app deve manter uma aparência moderna, mobile-first e parecida com um app real.

Estilo visual desejado:

- Fundo claro, levemente acinzentado
- Cores principais: roxo e azul
- Botões com gradiente roxo → azul
- Cards brancos com bordas arredondadas
- Sombras leves
- Campos de texto grandes e limpos
- Ícones simples
- Layout inspirado em iPhone/mobile
- Interface limpa, jovem e profissional

---

## Telas principais

### 1. Login

Tela para o usuário entrar no sistema.

Campos:

- E-mail
- Senha

Ações:

- Entrar
- Ir para tela de criação de conta
- Após login bem-sucedido, ir para Home

Firebase:

- Usar Firebase Auth
- Login com e-mail e senha

---

### 2. Registro

Tela para criação de conta.

Campos:

- Nome completo
- E-mail
- Senha
- Confirmar senha

Ações:

- Cadastrar
- Voltar para Login
- Após cadastro bem-sucedido, ir para Home

Firebase:

- Criar usuário com Firebase Auth
- Salvar nome do usuário, e-mail e data de criação no Firestore, se necessário

---

### 3. Home / Dashboard

Tela inicial após login.

Elementos:

- Saudação com o nome do usuário logado; caso o perfil ainda não tenha nome, usar texto genérico
- Texto: “Gerencie seus clientes com facilidade”
- Campo de busca de clientes
- Card com total de clientes
- Botão de adicionar novo cliente
- Lista de clientes cadastrados

Cada cliente na lista deve mostrar:

- Nome
- Empresa
- Status no funil

Status possíveis:

- Novo Lead
- Negociação
- Fechado

Ações:

- Clicar em um cliente abre a tela de detalhes
- Botão “+” abre tela de novo cliente
- Campo de busca filtra clientes por nome ou empresa
- Botão de sair/logout

---

### 4. Novo Cliente / Editar Cliente

Tela usada para criar e editar clientes.

Campos:

- Nome completo
- Empresa
- Telefone
- E-mail
- Status no funil
- Próximo follow-up
- Observações

Status possíveis:

- Novo Lead
- Negociação
- Fechado

Ações:

- Salvar cliente
- Voltar
- Se estiver editando, carregar os dados existentes do cliente
- Se for novo, criar um novo documento no Firestore

Firebase:

- Criar cliente no Firestore
- Atualizar cliente existente no Firestore
- Cada cliente deve pertencer ao usuário logado

---

### 5. Detalhe do Cliente

Tela para visualizar todas as informações de um cliente.

Mostrar:

- Nome
- Empresa
- Telefone
- E-mail
- Status
- Próximo follow-up
- Observações
- Histórico de interações registradas

Ações:

- Editar cliente
- Excluir cliente
- Registrar interação
- Excluir interação registrada
- Voltar

Firebase:

- Ler dados do cliente no Firestore
- Excluir cliente do Firestore
- Criar, listar e excluir interações no Firestore

---

### 6. Funil de Vendas

Tela para acompanhar os clientes por etapa.

Mostrar:

- Total de clientes no pipeline
- Taxa de conversão
- Quantidade de clientes em:
  - Novo Lead
  - Negociação
  - Fechado

Também mostrar os clientes separados por status.

Cálculo da taxa de conversão:

Taxa de conversão = clientes fechados / total de clientes * 100

---

### 7. Lembretes

Tela para acompanhar próximos follow-ups.

Mostrar:

- Lista de clientes com follow-up pendente
- Nome do cliente
- Observação
- Data do próximo follow-up

A lista deve ser baseada nos clientes cadastrados no Firestore.

---

## Modelo de dados sugerido no Firestore

Coleção:

users/{userId}/clients/{clientId}

Campos do cliente:

```json
{
  "name": "Maria Silva",
  "company": "Tech Corp",
  "phone": "+55 (11) 98765-4321",
  "email": "maria.silva@techcorp.com",
  "status": "Novo Lead",
  "nextFollowUp": "2026-04-29",
  "notes": "Interessada em organizar os contatos da empresa.",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Documento de perfil:

```text
users/{userId}
```

Campos do perfil:

```json
{
  "name": "Pedro Silva",
  "email": "pedro@email.com",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

Subcoleção de histórico:

```text
users/{userId}/clients/{clientId}/interactions/{interactionId}
```

Campos da interação:

```json
{
  "type": "Reunião",
  "notes": "Apresentação comercial realizada.",
  "createdAt": "timestamp"
}
```
