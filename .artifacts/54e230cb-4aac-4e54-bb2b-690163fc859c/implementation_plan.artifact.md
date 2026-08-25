# Fix Forced Redirection to Dashboard

This plan addresses the issue where the app forcibly redirects the user to `/dashboard` upon authentication, even if they accessed a specific protected route directly (e.g., `/pedidos`).

## Proposed Changes

### Navigation Component

#### [MODIFY] [navigation_cubit.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/navigation/navigation_cubit.dart)
- Add `isProtectedRoute(String location)` to check if a path belongs to the protected area.
- Add `goToDashboardIfNeeded(String currentLocation)` to only redirect to dashboard if the user is not already on a protected route.

#### [MODIFY] [app_router_listener.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/navigation/app_router_listener.dart)
- Update `BlocListener<AuthCubit>` to retrieve the current location using `GoRouterState`.
- Use `nav.goToDashboardIfNeeded(currentLocation)` to decide whether to redirect.

### Initialization Component

#### [MODIFY] [app_initializer.dart](file:///C:/Users/cassi/projetos/quimanda/lib/app/initialization/app_initializer.dart)
- Ensure it only triggers `checkAuthStatus` and doesn't perform any navigation.

## Verification Plan

### Manual Verification
- Access the app via `http://localhost:51642/pedidos` directly.
- Verify that the app stays on the Pedidos page after authentication.
- Access the app via `http://localhost:51642/` and verify it redirects to `/dashboard` after authentication.
- Access other protected routes like `/cardapio` or `/configuracoes` directly and verify they are maintained.
