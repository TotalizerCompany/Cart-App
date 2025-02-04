Cart-App
O Cart-App é um aplicativo desenvolvido em Flutter com integração ao Firebase, projetado para ser utilizado em carrinhos de supermercado. Ele permite que os usuários escaneiem códigos de barras de produtos utilizando a câmera do dispositivo, adicionando automaticamente os itens escaneados ao carrinho de compras. Além disso, o aplicativo oferece a funcionalidade de importar uma lista de compras de outro aplicativo, facilitando a organização das compras.

Funcionalidades Principais
Escaneamento de Código de Barras: Utiliza a câmera do dispositivo para escanear códigos de barras de produtos, identificando-os e adicionando-os ao carrinho de compras.

Adição de Produtos ao Carrinho: Após o escaneamento, os produtos são automaticamente adicionados ao carrinho, onde o usuário pode visualizar a lista de itens selecionados.

Importação de Lista de Compras: Permite a importação de uma lista de compras de outro aplicativo, facilitando a organização e o planejamento das compras.

Integração com Firebase: Utiliza o Firebase para armazenamento de dados, autenticação de usuários e outras funcionalidades em tempo real.

Tecnologias Utilizadas
Flutter: Framework de desenvolvimento de aplicativos móveis multiplataforma, permitindo a criação de interfaces nativas para iOS e Android a partir de um único código base.

Firebase: Plataforma de desenvolvimento de aplicativos que oferece diversos serviços, como banco de dados em tempo real, autenticação, armazenamento e muito mais.

Câmera do Dispositivo: Utilizada para escanear os códigos de barras dos produtos.

Como Executar o Projeto
Clone o Repositório:

bash
Copy
git clone https://github.com/TotalizerCompany/Cart-App.git
Navegue até o Diretório do Projeto:

bash
Copy
cd Cart-App
Instale as Dependências:

bash
Copy
flutter pub get
Configure o Firebase:

Crie um projeto no Firebase Console.

Adicione os arquivos de configuração do Firebase (google-services.json para Android e GoogleService-Info.plist para iOS) ao projeto.

Siga as instruções de configuração do Firebase para Flutter disponíveis na documentação oficial.

Execute o Aplicativo:

bash
Copy
flutter run
Estrutura do Projeto
lib/: Contém o código-fonte do aplicativo.

main.dart: Ponto de entrada do aplicativo.

models/: Define os modelos de dados utilizados no aplicativo.

screens/: Contém as diferentes telas do aplicativo.

services/: Implementa a lógica de negócio, como a integração com o Firebase e o escaneamento de códigos de barras.

widgets/: Contém os componentes de interface reutilizáveis.

android/ e ios/: Configurações específicas para as plataformas Android e iOS.

pubspec.yaml: Arquivo de configuração do Flutter que define as dependências do projeto.

Contribuição
Contribuições são bem-vindas! Se você deseja contribuir para o projeto, siga os passos abaixo:

Faça um fork do repositório.

Crie uma branch para sua feature (git checkout -b feature/nova-feature).

Commit suas mudanças (git commit -m 'Adicionando nova feature').

Push para a branch (git push origin feature/nova-feature).

Abra um Pull Request.

Licença
Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais detalhes.

Contato
Para mais informações, entre em contato com a equipe de desenvolvimento através do repositório do GitHub ou pelo email: contato@totalizercompany.com.
