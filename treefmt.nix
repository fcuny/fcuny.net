{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    statix.enable = true;
    actionlint.enable = true;
    deadnix.enable = true;
    prettier.enable = true;
    typos.enable = true;
  };
  settings = {
    formatter = {
      nixfmt.includes = [
        "*.nix"
      ];
      statix.includes = [
        "*.nix"
      ];
    };
  };
}
