# PlayBeat — Vercel Deployment Guide

## Folder structure before you deploy

Arrange your local files exactly like this inside `C:\Users\playb\Music\Playbeat\`:

```
Playbeat/
├── vercel.json          ← config file (this repo)
├── .gitignore
├── index.html
├── shop.html
├── deals.html
├── shared.css
├── shared.js
├── products.js
├── images/
│   └── bg.jpg           ← login background used by admin
└── admin/
    ├── admin.html
    └── assets/
        └── Untitled.png ← logo used on login screen
```

---

## Step 1 — Install Git (if you haven't)

Download from https://git-scm.com and install with default options.
Open **Command Prompt** and verify:

```
git --version
```

---

## Step 2 — Install Vercel CLI

Open **Command Prompt** and run:

```
npm install -g vercel
```

If you don't have Node.js: download it from https://nodejs.org (LTS version), install, then run the command above.

---

## Step 3 — Set up Git repository

Open Command Prompt, navigate to your project folder, then run each line one at a time:

```
cd "C:\Users\playb\Music\Playbeat"
git init
git add .
git commit -m "initial deployment"
```

---

## Step 4 — Deploy to Vercel

Still in the same Command Prompt window:

```
vercel
```

You will be asked a series of questions — answer them like this:

```
Set up and deploy? → Y
Which scope? → your Vercel account name
Link to existing project? → N
Project name: → playbeat
In which directory is your code? → ./   (just press Enter)
Want to override settings? → N
```

Vercel will give you a preview URL like `https://playbeat-abc123.vercel.app`.
Open it and check that the homepage loads correctly.

---

## Step 5 — Deploy to production

```
vercel --prod
```

This promotes the build to your production URL.

---

## Step 6 — Connect your custom domain (playbeat.digital)

1. Go to https://vercel.com/dashboard
2. Click your **playbeat** project
3. Go to **Settings → Domains**
4. Click **Add Domain** and type `playbeat.digital`
5. Vercel will show you two DNS records to add:

| Type | Name | Value |
|------|------|-------|
| A | @ | 76.76.21.21 |
| CNAME | www | cname.vercel-dns.com |

6. Log in to wherever you bought your domain (Namecheap, GoDaddy, etc.)
7. Go to **DNS settings** and add both records above
8. Wait 5–30 minutes for DNS to propagate
9. Back in Vercel, click **Verify** — it should turn green

Your site will then be live at:
- `https://playbeat.digital`
- `https://www.playbeat.digital`
- `https://playbeat.digital/admin` ← admin panel

---

## Step 7 — Every time you update files

After changing any file locally:

```
cd "C:\Users\playb\Music\Playbeat"
git add .
git commit -m "describe what you changed"
vercel --prod
```

That's it — Vercel redeploys in about 30 seconds.

---

## Important notes

**Admin panel security**
The admin panel at `/admin` is hidden from search engines via `vercel.json` but is still publicly reachable by URL. The JS password is the only gate right now. Before going live with real orders, change the password in `admin.html` to something strong.

**localStorage and your domain**
The cart and product data use `localStorage`. This only works correctly when all pages are on the same domain. Once your custom domain is connected, always use `https://playbeat.digital` — never mix the Vercel preview URL with your custom domain in the same browser session.

**Adding or editing products**
Edit `products.js`, then run `git add . && git commit -m "update products" && vercel --prod`.

**Images**
Any image referenced in your HTML (like `bg.jpg` or `Untitled.png`) must be in the repo. Vercel cannot serve files that aren't committed.