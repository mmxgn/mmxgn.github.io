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

        # Build the website as a derivation
        buildSite = pkgs.stdenv.mkDerivation {
          name = "org-mode-website";
          src = ./.;

          buildInputs = [ pkgs.emacs-nox ];

          buildPhase = ''
            mkdir -p .packages
            ${pkgs.emacs-nox}/bin/emacs -Q --script build-site.el
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };

        # Serve script for local testing
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

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.emacs-nox
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
        apps.serve = {
          type = "app";
          program = "${serveScript}/bin/serve-site";
        };
      }
    );
}
