# Ejemplos

| Ejemplo | Angular | ADF | Node | Contenido |
|---|---|---|---|---|
| [`angular20-adf9-mini-app`](angular20-adf9-mini-app) | 20.3 | 9.0.0 | 24 | Login → documentos (breadcrumb, upload, document list) → visor. Explicado en [07-tutorial-mini-app.md](../docs/07-tutorial-mini-app.md) |

```powershell
cd angular20-adf9-mini-app
nvm use 24
npm install        # usa .npmrc con legacy-peer-deps=true
npm start          # http://localhost:4200 (ACS en http://localhost:8080, ver proxy.conf.json)
```

Comprobado: compila desde cero y el guard redirige a login sin errores. Para ver documentos hace
falta ACS levantado ([01-preparar-entorno.md](../docs/01-preparar-entorno.md#5-backend-acs-con-docker)).
