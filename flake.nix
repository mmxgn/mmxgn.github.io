{
  description = "Simple Org-mode Website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Emacs with required packages
        emacs-with-packages = (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages (epkgs: [ epkgs.htmlize ]);

        # Build the website as a derivation
        buildSite = pkgs.stdenv.mkDerivation {
          name = "org-mode-website";
          src = ./.;

          buildInputs = [ emacs-with-packages ];

          buildPhase = ''
            export HOME=$TMPDIR
            mkdir -p .packages
            ${emacs-with-packages}/bin/emacs -Q --script build-site.el
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };

        # Serve script (no browser)
        serveScript = pkgs.writeShellScriptBin "serve-site" ''
          echo "Building site..."
          ${pkgs.emacs-nox}/bin/emacs -Q --script build-site.el

          echo ""
          echo "Site built successfully!"
          echo "Starting local server at http://localhost:8000"
          echo "Press Ctrl+C to stop"
          echo ""

          cd public
          ${pkgs.python3}/bin/python -m http.server 8000
        '';

        # Default: serve + open browser
        defaultScript = pkgs.writeShellScriptBin "serve-and-open" ''
          echo "Building site..."
          ${pkgs.emacs-nox}/bin/emacs -Q --script build-site.el

          echo ""
          echo "Site built successfully!"
          echo "Starting local server at http://localhost:8000"
          echo "Opening browser..."
          echo "Press Ctrl+C to stop"
          echo ""

          cd public

          # Open browser in background
          ${pkgs.xdg-utils}/bin/xdg-open http://localhost:8000 &

          # Start server
          ${pkgs.python3}/bin/python -m http.server 8000
        '';

        # Setup script for worktree
        setupScript = pkgs.writeShellScriptBin "setup-worktree" ''
          if [ -d "public" ]; then
            echo "✅ public/ directory already exists"
            if [ -f "public/.git" ]; then
              echo "✅ Already a worktree"
            else
              echo "❌ public/ exists but is not a worktree"
              echo "   Please remove it: rm -rf public/"
              exit 1
            fi
          else
            echo "Setting up git worktree for gh-pages..."
            ${pkgs.git}/bin/git worktree add public gh-pages
            echo "✅ Worktree created: public/ → gh-pages branch"
          fi
        '';

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [
            emacs-with-packages 
            pkgs.python3
            pkgs.git
          ];

          shellHook = ''
            echo "Org-mode Website Development Environment"
            echo ""

            # Check if worktree is set up
            if [ ! -d "public" ]; then
              echo "⚠️  Worktree not set up. Run: nix run .#setup"
              echo ""
            fi

            echo "Available commands:"
            echo "  nix run .#setup  - Set up git worktree (first time)"
            echo "  nix build        - Build to ./result"
            echo "  nix run          - Build, serve, and open browser"
            echo "  nix run .#serve  - Build and serve (no browser)"
            echo ""
            echo "Directory structure:"
            echo "  content/  - Org source files"
            echo "  public/   - Generated HTML (gh-pages worktree)"
            echo ""
          '';
        };

        # Build output
        packages.default = buildSite;

        # Runnable apps
        apps = {
          default = {
            type = "app";
            program = "${defaultScript}/bin/serve-and-open";
          };

          serve = {
            type = "app";
            program = "${serveScript}/bin/serve-site";
          };

          setup = {
            type = "app";
            program = "${setupScript}/bin/setup-worktree";
          };
        };
      }
    );
}
