{
  description = "ccal 2.5.3 — Chinese calendar viewer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems
        (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs:
        let ccal = pkgs.callPackage ./package.nix { src = self; };
        in {
          inherit ccal;
          default = ccal;
        });

      overlays.default = final: prev: {
        ccal = final.callPackage ./package.nix { src = self; };
      };

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ gcc gnumake ghostscript_headless ];
        };
      });
    };
}
