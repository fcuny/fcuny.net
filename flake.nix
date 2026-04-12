{
  description = "Franck Cuny's personal website.";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11-small/nixexprs.tar.xz";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # for `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # for `nix flake check`
        checks = {
          # Throws an error if any of the source files are not correctly formatted
          # when you run `nix flake check --print-build-logs`. Useful for CI
          treefmt = treefmtEval.config.build.check self;
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              format = {
                enable = true;
                name = "Format with treefmt";
                pass_filenames = true;
                entry = "${treefmtEval.config.build.wrapper}/bin/treefmt";
                stages = [
                  "pre-commit"
                  "pre-push"
                ];
              };
            };
          };
        };

        # for `nix build`
        packages = {
          default =
            with pkgs;
            stdenv.mkDerivation {
              pname = "fcuny.net";
              version = self.lastModifiedDate;
              src = ./.;
              buildInputs = [
                pandoc
                python3
              ];
              buildPhase = ''
                mkdir -p $out
                pandoc --standalone \
                       --template=src/templates/page.html \
                       --metadata title="Franck Cuny" \
                       -t html5 -o $out/index.html src/index.md
                pandoc --standalone \
                       --template=src/templates/page.html \
                       --metadata title="Franck Cuny - Resume" \
                       -t html5 -o $out/resume.html src/resume.md
                echo "fcuny.net" > $out/CNAME
                cp -r src/static $out/

                # Generate Go vanity import pages
                python3 scripts/generate-go-imports.py src/go-modules.json $out
              '';
              dontInstall = true;
            };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          packages = with pkgs; [
            #keep-sorted start
            git
            just
            nodePackages.prettier
            pandoc
            python3
            treefmt
            vscode-langservers-extracted
            watchexec
            #keep-sorted end
          ];
        };
      }
    );
}
