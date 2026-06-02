# ConnectCRM

Aplicativo mobile de CRM simples feito em Flutter/Dart com Firebase.

## Estado atual

- Login e registro com Firebase Auth
- Dashboard com busca, métricas e lista de clientes
- Cadastro, edição, detalhe e exclusão de clientes
- Bottom navigation com Início, Funil e Lembretes
- Funil de vendas calculado a partir dos clientes reais
- Lembretes baseados no próximo follow-up dos clientes
- Dados salvos em `users/{userId}/clients/{clientId}` no Firebase Firestore
- Regras de Firestore em `firestore.rules`

## Como rodar

```sh
flutter pub get
flutter run
```

Para testar no navegador:

```sh
flutter run -d chrome
```

## Firebase

Project ID: `connectcrm-5899e`

No Firebase Console, habilite:

- `Authentication > Sign-in method > Email/Password`
- `Firestore Database`

As regras locais estão em `firestore.rules`. Para publicar as regras:

```sh
firebase deploy --only firestore:rules
```
