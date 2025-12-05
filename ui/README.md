# Antivirus UI

Small UI for the Antivirus project (Vite + React).

Scripts available (from `ui/package.json`):

- `npm run dev` / `npm start` - Run Vite dev server
- `npm run build` - Build production assets
- `npm run build:ci` - CI-friendly build command
- `npm run serve` - Preview built assets locally
- `npm run lint` - Run ESLint on `src/`
- `npm run format` - Run Prettier to auto-format files
- `npm run clean` - Remove `node_modules` and `dist`

Notes:
- After pulling the repository, run `npm ci` in `ui/` to install dependencies.
- ESLint and Prettier are configured but you must run `npm install` or `npm ci` to actually install them.

Recommended next steps:
- Add Git hooks (husky) to run lint/format before commits.
- Add unit tests (Vitest / React Testing Library) and a `test` script.
- Wire the UI build outputs into the Tauri or Electron packaging step if you plan native distribution.
