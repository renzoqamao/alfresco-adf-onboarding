# Scripts de verificación

Reproducen las pruebas de la documentación. Se ejecutan en **Git Bash** (Windows) o en una terminal de
Linux/macOS. No cambian el Node global: buscan la versión necesaria dentro de nvm.

| Script | Qué hace |
|---|---|
| `probar-angular-adf.sh <14\|16\|18\|20\|22> [destino]` | `ng new` de esa versión de Angular, instala ADF con las correcciones de [06-adf-manual.md](../docs/06-adf-manual.md), pone `<adf-login>` y ejecuta `ng build` |
| `probar-aca.sh <tag> [destino]` | Clona ese tag de ACA, crea `.env`, instala (npm o pnpm) y ejecuta `nx build content-ce` |

Requisitos: nvm con Node **16.20.2** (Angular 14/16), **18** (ACA 4/5) y **24** (el resto). Ver
[01-preparar-entorno.md](../docs/01-preparar-entorno.md).

```bash
bash scripts/probar-angular-adf.sh 20 ../pruebas/ng20
cd ../pruebas/ng20 && npm start          # http://localhost:4200

bash scripts/probar-aca.sh 8.0.0 ../pruebas/aca800
cd ../pruebas/aca800 && npm start
```

Cada prueba descarga entre 300 MB y 1 GB de dependencias.
