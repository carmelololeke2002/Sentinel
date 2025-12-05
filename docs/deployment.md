# Deployment Guide

## Prerequisites
- Rust (stable version)
- Node.js (v18 or higher)
- PostgreSQL (for telemetry storage)

## Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/antivirus.git
   ```

2. **Build the Agent**:
   ```bash
   cd antivirus/agent
   cargo build --release
   ```

3. **Set Up the UI**:
   ```bash
   cd ../ui
   npm install
   npm run build
   ```

4. **Run the API**:
   ```bash
   cd ../api
   npm install
   node server.js

Installation Windows (script automatisé)
--------------------------------------
Un script PowerShell `install.ps1` est fournie à la racine du projet pour automatiser l'installation locale sur Windows.

Usage (PowerShell en administrateur) :

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install.ps1 -InstallPath "C:\Program Files\Antivirus" -NodePath "C:\Program Files\nodejs\node.exe"
```

Ce script :
- installe les dépendances de l'API (`npm ci`)
- construit (ou copie) la UI (`ui/dist`) vers `api/public`
- copie le binaire agent si présent dans `agent/target/release`
- crée et démarre un service Windows `AntivirusAPI` pointant sur `node server.js`

Remarques:
- Le script doit être lancé en tant qu'administrateur.
- Pour obtenir un binaire agent si tu ne veux pas compiler localement, utilise la CI (pousse une tag) ; les artefacts seront attachés à la Release.

Utiliser la Release manuelle via GitHub Actions (sans push local)
------------------------------------------------------------
Si tu ne veux rien faire en local, tu peux lancer un build + release depuis l'interface GitHub :

1. Va dans l'onglet `Actions` du dépôt.
2. Choisis le workflow `Manual Release` et clique `Run workflow`.
3. Renseigne le champ `tag` (par ex. `v0.1.0`) et `release_name` si souhaité puis clique `Run`.
4. Le workflow construira l'UI et l'agent (Linux + Windows) et créera une Release GitHub avec les artefacts attachés.
5. Va dans `Actions` → exécution correspondante → `Artifacts` ou dans `Releases` pour télécharger les zips contenant les binaires.


   ```

5. **Configure the Database**:
   - Create a PostgreSQL database.
   - Apply migrations (if any).

6. **Start the Application**:
   - Launch the agent.
   - Access the UI via the built files.
   - Ensure the API is running.