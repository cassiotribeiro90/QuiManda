# Implementação do Sistema Centralizado de Imagens (Padrão ImageHelper)

Este plano detalha a adaptação do projeto QuiManda para utilizar um sistema centralizado de gerenciamento de imagens, incluindo upload, compressão e manipulação de URLs via `ImageHelper`, seguindo o padrão do QuiGestor.

## User Review Required

> [!IMPORTANT]
> O roteiro fornecido menciona alguns nomes de arquivos que diferem levemente dos nomes reais no projeto (ex: `produto_model.dart` em vez de `produto.dart`). Vou utilizar os caminhos reais do projeto para evitar erros.
> Também notei que `AppConstants` já existe em `lib/app/core/constants.dart`. Vou integrar as novas constantes lá ou criar o novo arquivo conforme solicitado, mas ajustando para evitar conflitos de nomes se necessário.

## Proposed Changes

### [Core & Shared]
Implementação da infraestrutura de constantes, helpers e serviços de upload.

#### [NEW] [app_constants.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/core/constants/app_constants.dart)
Criação do arquivo de constantes para URLs base e configurações de upload.

#### [NEW] [image_helper.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/shared/utils/image_helper.dart)
Criação do utilitário para conversão de caminhos relativos em URLs completas.

#### [NEW] [upload_service.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/shared/services/upload_service.dart)
Implementação do serviço de upload com suporte a compressão de imagens.

#### [NEW] [product_image_picker.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/shared/widgets/product_image_picker.dart)
Widget reutilizável para seleção e upload de imagens.

#### [MODIFY] [dependencies.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/di/dependencies.dart)
Registro do `UploadService` no GetIt.

---

### [Models & Modules]
Adaptação dos modelos de dados e telas para utilizar o novo sistema de imagens.

#### [MODIFY] [produto_model.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/modules/cardapio/models/produto_model.dart)
Adição de getters para `imagemUrl` e `imagemPath` utilizando o `ImageHelper`.

#### [MODIFY] [cardapio_page.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/modules/cardapio/views/cardapio_page.dart)
Atualização da exibição de imagens na lista de produtos.

#### [MODIFY] [formulario_produto_page.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/modules/cardapio/views/formulario_produto_page.dart)
Integração do `ProductImagePicker` no formulário de criação/edição de produtos.

#### [MODIFY] [dashboard_screen.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/modules/dashboard/views/dashboard_screen.dart)
Atualização da exibição de imagens no dashboard (se aplicável).

#### [MODIFY] [all_pedido_detail_screen.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/modules/all_pedidos/views/all_pedido_detail_screen.dart)
Atualização da exibição de imagens nos itens do pedido.

---

### [Configuration]
#### [MODIFY] [pubspec.yaml](file:///C:/Users/cassi/projetos/quimanda/pubspec.yaml)
Adição das dependências: `image_picker`, `flutter_image_compress`, `path_provider`.

## Verification Plan

### Automated Tests
- Não se aplica (verificação manual via UI).

### Manual Verification
1.  **Build & Run:** Executar o app no simulador/dispositivo.
2.  **Cardápio:** Verificar se as imagens dos produtos existentes carregam corretamente via `ImageHelper`.
3.  **Upload:** Abrir o formulário de produto, selecionar uma imagem da galeria/câmera e verificar se o upload ocorre com sucesso e a barra de progresso funciona.
4.  **Edição:** Salvar um produto com imagem e verificar se o caminho relativo é enviado para a API.
5.  **Persistência:** Verificar se após salvar, a imagem continua aparecendo corretamente na lista.
