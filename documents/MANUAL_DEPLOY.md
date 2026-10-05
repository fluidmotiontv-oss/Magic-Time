# 🚀 Manual Deployment Guide

I cannot push to your repositories directly — but I can make it a single copy-paste operation for you.

---

## Option 1: One-Click Script (Recommended)

### Step 1: Download the zip
Extract `fluid-motion-unified-studio.zip` to your computer.

### Step 2: Open terminal in that folder
```bash
cd /path/to/fluid-motion-unified-studio
```

### Step 3: Run the deploy script
```bash
./deploy.sh
```

This will:
- Clone your `D9Enigma` repo
- Copy all files into `unified-studio/` subdirectory
- Commit with a detailed message
- Push to `main`

### Step 4: Enable GitHub Pages
1. Go to `https://github.com/fluidmotiontv-oss/D9Enigma/settings/pages`
2. Under "Build and deployment", select **GitHub Actions**
3. The workflow file is already included — it will auto-deploy on push

### Step 5: Visit your live site
```
https://fluidmotiontv-oss.github.io/D9Enigma/unified-studio/
```

---

## Option 2: Manual Copy-Paste

If the script doesn't work, do it manually:

```bash
# 1. Clone your repo
git clone https://github.com/fluidmotiontv-oss/D9Enigma.git
cd D9Enigma

# 2. Create the subdirectory
mkdir -p unified-studio

# 3. Copy all files from the zip
cp -r /path/to/fluid-motion-unified-studio/* unified-studio/

# 4. Commit and push
git add unified-studio/
git commit -m "feat: Fluid Motion Unified Studio v1.2"
git push origin main
```

---

## Option 3: Push to a New Repo

If you want this as its own repository:

```bash
# 1. Create new repo on GitHub (e.g., fluidmotiontv-oss/unified-studio)
# 2. In the extracted folder:
cd fluid-motion-unified-studio
git init
git add .
git commit -m "Initial commit: Fluid Motion Unified Studio v1.2"
git branch -M main
git remote add origin https://github.com/fluidmotiontv-oss/unified-studio.git
git push -u origin main
```

Then enable GitHub Pages in Settings → Pages → Deploy from branch → `main` → `/ (root)`

---

## 🔧 What Gets Deployed

| File/Folder | Purpose |
|-------------|---------|
| `src/` | All React components, services, hooks |
| `package.json` | Dependencies (React, Vite, Tailwind) |
| `vite.config.js` | Build configuration |
| `tailwind.config.js` | Design system tokens |
| `index.html` | Entry point |
| `.github/workflows/deploy.yml` | **Auto-deploys to GitHub Pages on every push** |
| `deploy.sh` | Local deployment script |

---

## 🌐 Live URL After Deploy

```
https://fluidmotiontv-oss.github.io/D9Enigma/unified-studio/
```

Or if pushed to its own repo:
```
https://fluidmotiontv-oss.github.io/unified-studio/
```

---

## 🔄 Updating Later

After the initial push, updating is easy:

```bash
cd D9Enigma/unified-studio
# Make changes...
git add .
git commit -m "update: description of changes"
git push origin main
```

GitHub Actions will **automatically rebuild and redeploy** in ~2 minutes.

---

## ❓ Troubleshooting

### "Permission denied" when running deploy.sh
```bash
chmod +x deploy.sh
./deploy.sh
```

### GitHub Pages not showing
- Go to Settings → Pages → Source: GitHub Actions
- Check Actions tab for build errors
- Ensure `vite.config.js` has `base: '/D9Enigma/unified-studio/'` if deploying to subdirectory

### CORS errors with Invidious
- The app tries 5 public instances automatically
- For production, host your own: `docker run -d -p 3000:3000 quay.io/invidious/invidious`

---

*"Fluid Motion of the Future"*
