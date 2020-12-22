rec {
  description =
    "Modified version of the applesmc.c Linux driver adding T2 support";

  inputs = {
    src = {
      url = "github:MCMrARM/mbp2018-etc";
      flake = false;
    };
    mbpfan = {
      url = "github:linux-on-mac/mbpfan";
      flake = false;
    };
    utils.url = "github:kreisys/flake-utils";
  };

  outputs = { self, nixpkgs, src, mbpfan, utils, ... }:
    with nixpkgs.lib;
    let
      maybeExtend = obj: obj.extend or (_: obj);
      maybeExtendAttrs = extension: mapAttrs (_: flip maybeExtend extension);
      filterAttrsByPrefix = prefix: filterAttrs (flip (_: hasPrefix prefix));
    simpleFlake = utils.lib.simpleFlake rec {
      inherit nixpkgs;
      name = "applesmc-t2";
      systems = [ "x86_64-linux" ];
      overlay = final: prev: pipe prev [
        (filterAttrsByPrefix "linuxPackages")
        (maybeExtendAttrs (final: prev: {
          "${name}" = prev.callPackage ./package.nix {
            inherit src description;
            pname = name;
          };
        }))
      ];

      overlays = [ (final: prev: {
        mbpfan = prev.mbpfan.overrideAttrs (o: {
          version = "git";
          src = mbpfan;
          patches = [ ./mbpfan.patch ];
        });
      })];

      packages = { pkgs }: pipe pkgs [
        (filterAttrsByPrefix "linuxPackages")
        (filterAttrs (_: v: (builtins.tryEval v).success))
        (mapAttrs (_: v: recurseIntoAttrs {
          ${name} = v.${name} or null;
        }))
      ] // {
        inherit (pkgs) mbpfan;
        defaultPackage = pkgs.linuxPackages.${name};
      };

      nixosModule = { pkgs, ... }: {
        imports = [ ./module.nix ];
        nixpkgs.overlays = [ self.overlay ];
      };
    }; in simpleFlake // {
      hydraJobs = self.packages;
    };
}
