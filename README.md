# Cart-App

O **Cart-App** é um aplicativo desenvolvido em Flutter com integração ao Firebase, projetado para ser utilizado em carrinhos de supermercado. Ele permite que os usuários escaneiem códigos de barras de produtos utilizando a câmera do dispositivo, adicionando automaticamente os itens escaneados ao carrinho de compras. Além disso, o aplicativo oferece a funcionalidade de importar uma lista de compras de outro aplicativo, facilitando a organização das compras.

## Funcionalidades Principais

- **Escaneamento de Código de Barras**: Utiliza a câmera do dispositivo para escanear códigos de barras de produtos, identificando-os e adicionando-os ao carrinho de compras.
- **Adição de Produtos ao Carrinho**: Após o escaneamento, os produtos são automaticamente adicionados ao carrinho, onde o usuário pode visualizar a lista de itens selecionados.
- **Importação de Lista de Compras**: Permite a importação de uma lista de compras de outro aplicativo, facilitando a organização e o planejamento das compras.
- **Integração com Firebase**: Utiliza o Firebase para armazenamento de dados, autenticação de usuários e outras funcionalidades em tempo real.

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento de aplicativos móveis multiplataforma, permitindo a criação de interfaces nativas para iOS e Android a partir de um único código base.
- **Firebase**: Plataforma de desenvolvimento de aplicativos que oferece diversos serviços, como banco de dados em tempo real, autenticação, armazenamento e muito mais.
- **Câmera do Dispositivo**: Utilizada para escanear os códigos de barras dos produtos.

## Como Executar o Projeto

### Clone o Repositório:
```bash
git clone https://github.com/TotalizerCompany/Cart-App.git
```

### Navegue até o Diretório do Projeto:
```bash
cd Cart-App
```

### Instale as Dependências:
```bash
flutter pub get
```

### Configure o Firebase:
1. Crie um projeto no Firebase Console.
2. Adicione os arquivos de configuração do Firebase (`google-services.json` para Android e `GoogleService-Info.plist` para iOS) ao projeto.
3. Siga as instruções de configuração do Firebase para Flutter disponíveis na [documentação oficial](https://firebase.flutter.dev/docs/overview/).

### Execute o Aplicativo:
```bash
flutter run
```

## Estrutura do Projeto

```
Cart-App/
├── lib/
│   ├── main.dart  # Ponto de entrada do aplicativo
│   ├── models/  # Modelos de dados
│   ├── screens/  # Telas do aplicativo
│   ├── services/  # Lógica de negócio e integração com Firebase
│   ├── widgets/  # Componentes reutilizáveis
├── android/  # Configurações Android
├── ios/  # Configurações iOS
├── pubspec.yaml  # Configuração do projeto e dependências
```

## Contribuição

Contribuições são bem-vindas! Se você deseja contribuir para o projeto, siga os passos abaixo:

1. Faça um fork do repositório.
2. Crie uma branch para sua feature:
   ```bash
   git checkout -b feature/nova-feature
   ```
3. Commit suas mudanças:
   ```bash
   git commit -m 'Adicionando nova feature'
   ```
4. Envie para o repositório remoto:
   ```bash
   git push origin feature/nova-feature
   ```
5. Abra um Pull Request.

## Licença

Este projeto está licenciado sob a [licença MIT](LICENSE).

## Contato

Para mais informações, entre em contato com a equipe de desenvolvimento através do repositório do GitHub ou pelo email: **contato@totalizercompany.com**.
