# Smart Shamba

**Group 20 · University of Eldoret**

Smart Shamba is a student farm-management system. This repository is a lightweight monorepo containing a React PWA frontend, an Express REST API and PostgreSQL database scripts.

## Repository layout

```text
smart-shamba/
├── client/                 # React + Vite frontend (Netlify)
├── server/                 # Node.js + Express API (Render)
├── database/               # PostgreSQL schema and seed scripts
├── docs/                   # Project and user documentation
├── tests/                  # Unit, integration and Postman tests
├── .gitignore
├── package.json            # npm workspaces and shared commands
└── README.md
```

## Prerequisites

Install:
- Node.js 20 LTS (or a current supported LTS release) and npm
- PostgreSQL 14 or newer
- Git

## Run locally

### 1. Clone and install

```bash
git clone <your-github-repository-url>
cd smart-shamba
cp server/.env.example server/.env
cp client/.env.example client/.env
npm install
```

Edit `server/.env` and set your local PostgreSQL connection string and a long, random `JWT_SECRET`. Keep `.env` files private; they are ignored by Git.

The client uses `VITE_API_URL` from `client/.env`. The server uses the variables in `server/.env`.

### 2. Create the PostgreSQL database

For example, using `psql`:

```bash
createdb smart_shamba
psql -d smart_shamba -f database/schema.sql
psql -d smart_shamba -f database/seed.sql
```

Alternatively, create a database named `smart_shamba` using pgAdmin, then open and run `database/schema.sql` followed by `database/seed.sql` in the Query Tool.

Set `DATABASE_URL` in `server/.env` to match your local database, for example:

```env
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/smart_shamba
```

The seed script inserts a demo farm only. Create users through the application's registration/admin workflow so passwords can be stored as bcrypt hashes.

### 3. Start the app

From the repository root:

```bash
npm run dev
```

- React frontend: http://localhost:5173
- Express API health check: http://localhost:5000/api/health

You can also start either side separately:

```bash
npm run dev:client
npm run dev:server
```

Build the frontend:

```bash
npm run build
```

## Environment variables

### `server/.env`

| Variable | Purpose |
|---|---|
| `PORT` | Express port; defaults to `5000` |
| `DATABASE_URL` | PostgreSQL connection URL |
| `JWT_SECRET` | Secret used to sign and verify JWTs |
| `FRONTEND_URL` | Allowed frontend origin for CORS |
| `AT_API_KEY` | Africa's Talking API key |
| `AT_USERNAME` | Africa's Talking username (`sandbox` for sandbox testing) |

### `client/.env`

| Variable | Purpose |
|---|---|
| `VITE_API_URL` | Base URL for the backend API, e.g. `http://localhost:5000/api` |

Only expose non-secret values prefixed with `VITE_` to the browser. Never put database credentials, JWT secrets or Africa's Talking keys in the client environment.

## Deployment

Deploy from the same GitHub repository. No Docker or Kubernetes setup is required.

### Frontend — Netlify

1. Push the repository to GitHub.
2. In Netlify, choose **Add new site → Import an existing project** and select the repository.
3. Set the base directory to `client` (or let Netlify read `client/netlify.toml`).
4. Set the build command to `npm run build` and publish directory to `dist`.
5. Add the environment variable `VITE_API_URL` with your deployed Render API URL, for example `https://your-api-name.onrender.com/api`.
6. Deploy. The `client/netlify.toml` redirect sends SPA routes to `index.html`.

### Backend — Render

1. In Render, choose **New → Web Service** and connect the GitHub repository.
2. Set the root directory to `server`.
3. Set the build command to `npm install` and start command to `npm start`.
4. Add the environment variables from `server/.env.example` in Render's Environment settings:
   - `PORT` is normally assigned by Render; the app reads `process.env.PORT`.
   - `DATABASE_URL`: use the connection URL for your Render PostgreSQL database.
   - `JWT_SECRET`: generate a strong, unique secret.
   - `FRONTEND_URL`: your deployed Netlify site origin, e.g. `https://your-site.netlify.app`.
   - `AT_API_KEY` and `AT_USERNAME`: your Africa's Talking credentials.
5. Create a PostgreSQL database in Render. Copy its **internal database URL** when the web service and database are in the same Render region; use the external URL only when connecting from outside Render.
6. Run `database/schema.sql` and then `database/seed.sql` against the Render database using `psql` or a PostgreSQL client.
7. Deploy the web service and check `https://your-api-name.onrender.com/api/health`.

After deployment, update Netlify's `VITE_API_URL` to the Render API URL and redeploy the frontend if needed.

## Git workflow for Group 20

Team: **Justin, Abel, Imran, Johncyra and Kadesa**.

Use `main` for stable, reviewed work. Each member should work on a short-lived feature branch:

```bash
git switch main
git pull origin main
git switch -c feature/short-feature-name
# make and test your changes
git add .
git commit -m "Add: short description"
git push -u origin feature/short-feature-name
```

Then open a Pull Request on GitHub into `main`. Ask at least one teammate to review it, resolve feedback, and merge only after checks pass. Avoid pushing directly to `main`.

Suggested branch names:
- `feature/authentication`
- `feature/farm-dashboard`
- `feature/animal-management`
- `feature/milk-records`
- `feature/reports`

Before starting new work, update your local `main` and create a fresh branch. If two people edit the same file, coordinate before merging to reduce conflicts.

## Roles and permissions

The application should enforce these roles on the backend (not only by hiding frontend controls):

- `ADMINISTRATOR`
- `FARM_OWNER`
- `FARM_MANAGER`
- `FARM_WORKER`
- `VET_OFFICER`

Use the authentication middleware and role-check middleware as a starting point. Validate permissions for every protected API endpoint.

## Development notes

- Passwords must be hashed with `bcrypt`; never store plain-text passwords.
- Sign JWTs with a strong secret and set an appropriate expiry.
- Keep Africa's Talking credentials on the server only.
- Validate and authorize incoming API requests; do not trust role values sent by the browser.
- Back up the database and use a separate test database for integration tests.
- This is a starter scaffold: implement and test the proposal's full workflows before production use.
