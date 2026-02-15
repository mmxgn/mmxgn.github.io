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
            echo "Available commands:"
            echo "  nix build        - Build to ./result"
            echo "  nix run .#serve  - Build and serve on http://localhost:8000"
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
        };
      }
    );
}
