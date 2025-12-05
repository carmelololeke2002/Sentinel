# Antivirus API

Small example API for the Antivirus project. Contains basic endpoints used by the UI and CI.

Available scripts (from `package.json`):

- `npm start` - run production server
- `npm run dev` - run server with `nodemon` for development
- `npm run lint` - run ESLint
- `npm run test` - placeholder
- `npm run healthcheck` - run a small probe to verify the server is running

Endpoints:

- `GET /healthz` - basic health check
- `GET /` - welcome message
- `POST /api/v1/telemetry` - receive telemetry
- `GET /api/v1/signatures/latest` - example signature manifest
- `POST /api/v1/scan/report` - receive scan reports
- `POST /api/v1/update/check` - check for updates (example manifest)

Notes:
- Install dependencies with `npm ci` in the `api/` folder.
- For CI, run `npm ci && npm run lint && npm test && npm start & sleep 5 && curl -f http://localhost:3000/healthz`.
