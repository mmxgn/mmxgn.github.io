# Simple Org-mode Website

Personal website built with Emacs Org-mode, managed with Nix, and auto-deployed via GitHub Actions.

## Architecture

This project uses a **git worktree** setup with automated deployment:

- **`main` branch** - Source files (org files, build scripts, Nix config)
- **`gh-pages` branch** - Generated HTML (deployed via GitHub Actions)
- **`public/` directory** - Git worktree pointing to `gh-pages` branch

## Quick Start

### Using Nix (Recommended)

```bash
# Enter development environment
nix develop

# Build the site
./build.sh

# Build and serve locally on http://localhost:8000
nix run .#serve

# Build site to ./result (for deployment)
nix build
```

### Without Nix

```bash
# Install dependencies
# - emacs-nox (or emacs)
# - python3 (for local server)

# Build the site
./build.sh

# Serve locally
cd public
python -m http.server 8000
```

## Development Workflow

### 1. Edit Content

Edit org files in `content/`:

```bash
emacs content/blog.org
emacs content/index.org
```

### 2. Build and Test Locally

```bash
# Build
./build.sh

# Serve and preview
nix run .#serve
# or manually:
cd public && python -m http.server 8000
```

Open http://localhost:8000 in your browser.

### 3. Commit and Push

```bash
# Commit source changes to main branch
git add content/blog.org
git commit -m "feat: add new blog post"
git push origin main
```

**GitHub Actions automatically builds and deploys to `gh-pages`!**

## Manual Deployment (Optional)

If you need to manually deploy from your local machine:

```bash
# Build the site
./build.sh

# Commit generated HTML to gh-pages (via worktree)
cd public
git add .
git commit -m "build: manual deployment"
git push origin gh-pages
cd ..
```

## Project Structure

```
simple-org-mode-website/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Auto-deployment workflow
├── content/                     # Org-mode source files
│   ├── blog.org
│   ├── index.org
│   ├── sitemap.org
│   └── static/                 # CSS, images, CV, etc.
├── public/                      # Generated HTML (git worktree → gh-pages)
├── build-site.el                # Org-publish configuration
├── build.sh                     # Build wrapper script
├── flake.nix                    # Nix development environment
└── README.md                    # This file
```

## How It Works

### Git Worktree Setup

The `public/` directory is a **git worktree** that points to the `gh-pages` branch:

```bash
# View worktrees
git worktree list

# Output:
# /path/to/project         <commit> [main]
# /path/to/project/public  <commit> [gh-pages]
```

This allows you to:
- Keep source and deployment code in separate branches
- Test builds locally before pushing
- Manually deploy if needed

### Automated Deployment

On every push to `main`:

1. GitHub Actions checks out your source code
2. Installs Emacs and dependencies
3. Runs `./build.sh` to generate HTML
4. Pushes the `public/` directory to `gh-pages` branch
5. GitHub Pages serves the site from `gh-pages`

## Nix Flake Features

The `flake.nix` provides:

- **`nix develop`** - Development shell with Emacs, Python, Git
- **`nix run .#serve`** - Build and serve locally
- **`nix run .#build`** - Build the site
- **`nix build`** - Build site to `./result/` (for deployment)

## GitHub Pages Setup

1. Go to your repository settings
2. Navigate to **Pages**
3. Set **Source** to `gh-pages` branch
4. Save

Your site will be available at `https://<username>.github.io/<repo-name>`

## Customization

### Modify Site Content

Edit files in `content/`:
- `index.org` - Homepage
- `blog.org` - Blog posts
- `static/` - CSS, images, CV, etc.

### Modify Build Configuration

Edit `build-site.el`:
- Change CSS framework
- Customize HTML output
- Add org-publish projects

### Modify Deployment

Edit `.github/workflows/deploy.yml`:
- Change trigger branches
- Add build steps
- Customize deployment settings

## Troubleshooting

### Build Fails

```bash
# Clean cache and rebuild
rm -rf .packages/
./build.sh
```

### Worktree Issues

```bash
# List worktrees
git worktree list

# Remove and recreate public/ worktree
git worktree remove public
git worktree add public gh-pages
```

### GitHub Actions Not Deploying

1. Check workflow runs in the **Actions** tab
2. Verify `gh-pages` branch exists
3. Ensure GitHub Pages is enabled in settings
4. Check permissions in `.github/workflows/deploy.yml`

## License

[Your License Here]
