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

        # Build script
        buildScript = pkgs.writeShellScriptBin "build-site" ''
          echo "Building Org-mode website..."
          ${pkgs.emacs-nox}/bin/emacs -Q --script build-site.el
          echo "Build complete! Output in ./public/"
        '';

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
            echo "  ./build.sh       - Build the website"
            echo "  nix run .#build  - Build the website (via Nix)"
            echo "  nix run .#serve  - Build and serve on http://localhost:8000"
            echo ""
            echo "Directory structure:"
            echo "  content/  - Org source files"
            echo "  public/   - Generated HTML (gh-pages worktree)"
            echo ""
          '';
        };

        # Runnable apps
        apps = {
          build = {
            type = "app";
            program = "${buildScript}/bin/build-site";
          };

          serve = {
            type = "app";
            program = "${serveScript}/bin/serve-site";
          };
        };
      }
    );
}
