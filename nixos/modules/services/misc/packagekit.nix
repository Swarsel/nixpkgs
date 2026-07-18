{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.packagekit;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkRemovedOptionModule
    listToAttrs
    recursiveUpdate
    ;

  iniFmt = pkgs.formats.ini { };

  confFiles = [
    (iniFmt.generate "PackageKit.conf" (
      recursiveUpdate {
        Daemon = {
          DefaultBackend = "test_nop";
          KeepCache = false;
        };
      } cfg.settings
    ))

    (iniFmt.generate "Vendor.conf" (
      recursiveUpdate {
        PackagesNotFound = rec {
          CodecUrl = DefaultUrl;
          DefaultUrl = "https://github.com/NixOS/nixpkgs";
          FontUrl = DefaultUrl;
          HardwareUrl = DefaultUrl;
          MimeUrl = DefaultUrl;
        };
      } cfg.vendorSettings
    ))
  ];

in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "packagekit"
      "backend"
    ] "Always set to test_nop, Nix backend is broken see #177946.")
  ];

  options.services.packagekit = {
    enable = mkEnableOption ''
      PackageKit, a cross-platform D-Bus abstraction layer for
      installing software. Software utilizing PackageKit can install
      software regardless of the package manager
    '';

    settings = mkOption {
      default = { };
      description = "Additional settings passed straight through to PackageKit.conf";
      type = iniFmt.type;
    };

    vendorSettings = mkOption {
      default = { };
      description = "Additional settings passed straight through to Vendor.conf";
      type = iniFmt.type;
    };
  };

  config = mkIf cfg.enable {

    environment.etc = listToAttrs (
      map (e: lib.nameValuePair "PackageKit/${e.name}" { source = e; }) confFiles
    );

    environment.systemPackages = with pkgs; [ packagekit ];
    services.dbus.packages = with pkgs; [ packagekit ];
    systemd.packages = with pkgs; [ packagekit ];
  };
}
