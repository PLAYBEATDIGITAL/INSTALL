# PlayBeat — Deployment Guide

This document explains how to push the repository to GitHub, deploy the backend to Render, and deploy the frontend to Vercel.

Prerequisites
- A GitHub repository (this project). Remote in this workspace is currently `git@github.com:rahulk6778/Playbeat.git`.
- A Render account for backend deployment.
- A Vercel account for frontend deployment.
- A MongoDB connection string (MONGODB_URI) — you will provide this when configuring Render.

1) Push changes to GitHub (HTTPS)

Run these commands locally from the repo root (you will authenticate via GitHub credentials or PAT):

```bash
cd "C:\Users\playb\Music\Playbeat"
# switch remote to HTTPS if SSH keys are not available
git remote set-url origin https://github.com/rahulk6778/Playbeat.git
git push --set-upstream origin main
```

2) Deploy backend to Render

- In Render dashboard, click "New" → "Web Service" → "Connect from GitHub" and select this repo.
- Render will use `render.yaml` defaults. Ensure the following details:
  - Branch: `main`
  - Build Command: `npm install`
  - Start Command: `npm start`
  - Environment: Node
- In Render's Environment tab, add a new secret `MONGODB_URI` with your MongoDB connection string.
- Deploy. After a successful deploy, note the service URL (e.g. `https://playbeat-backend.onrender.com`).

3) Deploy frontend to Vercel

- In Vercel, import the GitHub repository.
- When prompted, set the Project Root to `frontend` so Vercel serves the static site.
- Set an Environment Variable in Vercel named `API_URL` with the backend base URL from Render (e.g. `https://playbeat-backend.onrender.com`).
- Deploy the project.

4) Post-deploy: Admin UI

- Visit the deployed frontend URL and open the admin panel (`/admin.html` or `/admin`).
- In the admin settings, ensure the API Base URL is set to the backend URL (if `API_URL` env var wasn’t applied).

Local testing
- Install dependencies and run backend locally:

```bash
cd "C:\Users\playb\Music\Playbeat"
npm install
npm run dev  # requires nodemon installed; or `npm start` for production
```

- Serve the frontend locally (quick test):

```bash
npx http-server frontend -p 8080 -c-1
# then open http://localhost:8080
```

Environment variables checklist
- `MONGODB_URI` — required for backend database connection
- `PORT` — optional (Render sets this automatically)
- `API_URL` — set in Vercel (frontend) to point to the backend URL

Troubleshooting
- Render SSH/GitHub permissions: ensure Render has access to the repo when connecting via GitHub.
- If backend fails to connect to MongoDB, double-check `MONGODB_URI` and network access (IP whitelist on Atlas).

If you want, I can generate a small Render CLI command to set secrets or a sample `dockerfile` instead of `render.yaml`.
