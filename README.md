# Resumo Técnico e Funcional do Projeto Lojista (MVP)

Stack: Flutter 3.x (Dart) no frontend, backend a definir (sugestão: PHP/Yii2 ou Node.js), banco MariaDB/MySQL ou PostgreSQL. Gerenciamento de estado com flutter_bloc (Cubit) e injeção de dependências com GetIt. HTTP via Dio customizado no ApiClient. Navegação por rotas nomeadas (Navigator 1.0). Tema com cores de alto contraste e tipografia legível (tamanhos mínimos para uso em ambiente de loja).

Estrutura de diretórios principal: lib/app/modules/ contém cada funcionalidade (pedidos, dashboard, chat, config, auth). Cada módulo segue o padrão: bloc/ (Cubit + State), models/ (modelos com Equatable e copyWith), repositories/ (abstração que chama services), services/ (chamadas HTTP com ApiClient), views/ (telas), widgets/ (componentes reutilizáveis). Exemplo: módulo pedidos tem PedidoCubit, PedidoState (PedidoInitial, PedidoLoading, PedidoLoaded, PedidoError, PedidoAceito, PedidoRecusado, PedidoTimerTick), PedidoModel, PedidoRepository, PedidoService, PedidosListView, PedidoCardWidget, PedidoBottomSheet.

Cubits gerenciam estado local e chamam repository -> service -> API. Fluxo: View chama context.read<Cubit>().metodo(), Cubit emite Loading, processa, emite Loaded/Error, View reage com BlocBuilder/BlocConsumer.

Injeção de dependências centralizada em app/di/dependencies.dart com GetIt. ApiClient singleton, Cubits factories. Exemplo: getIt.registerLazySingleton(() => ApiClient()); getIt.registerFactory(() => PedidoCubit(getIt()));

Backend: autenticação por device_id (header X-Device-Id). Endpoints principais (a definir): GET /orders (lista pedidos ativos e novos), POST /orders/{id}/accept, POST /orders/{id}/reject (com motivo opcional), GET /dashboard (métricas), GET /chat/{order_id}/messages, POST /chat/{order_id}/messages. O aceite automático e pausa programada serão implementados futuramente no backend.

Rotas do app: splash, home (pedidos), dashboard, config, chat, detalhes do pedido (bottom sheet). Definidas em app/routes/app_routes.dart.
Usabilidades e Decisões de UX (MVP)
Home (tela principal = Pedidos)

    Fila vertical expansível: apenas pedidos, sem barra de status fixa.

    Card compacto com resumo: valor total, itens, timer.

    Toque no card expande um bottom sheet com detalhes completos.

    Timer visível em anel progressivo ou barra no card.

    Aceitar: botão gigante verde, um toque, sem confirmação.

    Recusar: botão discreto, sem modal – confirmação inline (ex: manter pressionado ou botão que se transforma em "Confirmar recusa"). Motivo da recusa opcional (sugestões: item indisponível, área fora de entrega, volume alto, outro).

    Sem modal de confirmação – prioriza performance e velocidade.

Notificações e TTS

    Ao receber novo pedido: som + vibração + TTS (Text-to-Speech).

    TTS reproduz: “Novo pedido de R$ 54,90, 3 itens, entrega em 2,3 km.”

    Enquanto houver pedidos pendentes, o TTS pode repetir o anúncio (configurável).

    Configurações de som: TTS, toque sonoro ou sem som (útil para quem usa aceite automático).

Chat

    Chat direto com o cliente sem expor telefone.

    Acessível a partir do card expandido (bottom sheet).

Dashboard (segunda aba)

    Separado da home, com métricas:

        Total de pedidos ativos

        Faturamento do dia

        Tempo médio de aceite

        Taxa de aceite

        Cancelamentos

Layout Responsivo

    Celular: lista vertical com cards + bottom sheet.

    Tablet: split screen (lista de pedidos à esquerda, detalhe à direita).

    Modo retrato e paisagem bem adaptados.

    Alvos de toque mínimos de 48x48dp.

    Contraste alto e fonte legível.

Funcionalidades Pós-MVP (implementação futura)

    Aceite automático com regras (ex.: valor mínimo, distância máxima).

    Pausa programada com horários definidos pelo lojista.

    Impressão automática do pedido na cozinha.

    Modo KDS (arrastar pedidos entre estágios: Novo → Em preparo → Pronto).

    Respostas rápidas para o cliente.

    Integração com smartwatch.

    Gamificação leve (sequência de pedidos aceitos sem recusa).

Pontos de Atenção

    Não usar modal para recusa – confirmação inline.

    TTS configurável e respeitar preferência do usuário.

    Dashboard separado – home apenas pedidos.

    Fila vertical – não usar fila horizontal.

    Aceitar sem confirmação; recusar com confirmação inline.

    Layout responsivo obrigatório (celular e tablet).

    Alvos de toque ≥ 48x48dp.

    Timer com anel progressivo no card.

    Chat não expõe telefone do cliente.

    Arquitetura já deve prever aceite automático e pausa programada para evitar retrabalho futuro.

