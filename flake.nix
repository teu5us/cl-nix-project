{
  description = "A flake for building cl-nix-shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          {
            defaultPackage = import ./default.nix { inherit pkgs; };
            devShell = import ./default.nix { inherit pkgs; };
          });
}
