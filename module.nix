{ config, lib, pkgs, ... }:

let cfg = config.hardware.apple.t2;
in with lib; {
  options.hardware.apple.t2 = with types; {
    enable = mkEnableOption "Apple SMC support for Macs with a T2 chip";
  };

  config = mkIf cfg.enable {
    boot = {
      blacklistedKernelModules = [ "applesmc" ];
      extraModulePackages = [ config.boot.kernelPackages.applesmc-t2 ];
      kernelModules = [ "applesmc_t2_kmod" ];
    };
  };
}
