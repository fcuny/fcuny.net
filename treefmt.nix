{
  projectRootFile = "flake.nix";
  programs = {
    #keep-sorted start
    actionlint.enable = true;
    deadnix.enable = true;
    keep-sorted.enable = true;
    nixfmt.enable = true;
    prettier.enable = true;
    statix.enable = true;
    typos.enable = true;
    #keep-sorted end
  };
}
