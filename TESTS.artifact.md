## TESTES MANUAIS - quiManda (GoRouter Migration)

### Autenticação (Fluxo Principal)
- [ ] Splash → Login (Phone Input)
- [ ] Login → OTP Verify
- [ ] OTP Verify → Dashboard (ou Store Selection se múltiplas lojas)
- [ ] Logout → Login

### Navegação de Módulos (SideMenu)
- [ ] Dashboard → Pedidos
- [ ] Dashboard → Cardápio
- [ ] Dashboard → Configurações
- [ ] Dashboard → Trocar Loja (Store Selection)

### Cardápio (Fluxo Detalhado)
- [ ] Listagem de Produtos
- [ ] Abrir Formulário (Novo) → Voltar
- [ ] Abrir Formulário (Edição) → Voltar
- [ ] Salvar Produto → Voltar Automático + Refresh Lista

### Deep Linking & Logs
- [ ] Verificar prefixos no console: `🚀 [MAIN]`, `🔄 [ROUTER]`, `📤 [NAVIGATION]`, `👂 [LISTENER]`
- [ ] Acessar `/dashboard` via browser (se web)

### Erros e Refresh
- [ ] Token 401 → Refresh automático (log `⚠️ [API]`)
- [ ] Falha no refresh → Redirect Login (log `❌ [API]`)
