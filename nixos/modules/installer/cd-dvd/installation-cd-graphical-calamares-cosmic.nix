{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./installation-cd-graphical-calamares.nix ];
  environment.pathsToLink = [ "/share/calamares" ];
  isoImage.configurationName = "COSMIC (Linux LTS)";
  isoImage.edition = lib.mkDefault "cosmic";

  services = {
    desktopManager.cosmic.enable = true;

    displayManager = {
      # No need to have a lockscreen on an installer ISO, enable autologin
      autoLogin = {
        enable = true;
        user = "nixos";
      };

      # Greeter needs to be enabled to handle an idle logout and login
      cosmic-greeter.enable = true;
    };
  };

  specialisation = {
    cosmic_latest_kernel.configuration =
      { config, ... }:
      {
        imports = [ ./latest-kernel.nix ];
        isoImage.configurationName = lib.mkForce "COSMIC (Linux ${config.boot.kernelPackages.kernel.version})";
      };
  };

  systemd.tmpfiles.rules =
    let
      desktopDir = "/home/nixos/Desktop";
      filesInHomePerms = "0644 nixos users -";
      dirsInHomePerms = "0755 nixos users - -";
      CosmicAppList_favorites = "${pkgs.writeText "favorites" ''
        [
            "calamares",
            "firefox",
            "gparted",
            "com.system76.CosmicFiles",
            "com.system76.CosmicEdit",
            "com.system76.CosmicTerm",
            "com.system76.CosmicSettings",
        ]''}";
    in
    [
      # Need to create ${desktopDir} first or we get an ownership issue because
      # otherwise ${desktopDir} gets the ownership of `root:root`.
      "d ${desktopDir} ${dirsInHomePerms}"
      "L+ ${desktopDir}/calamares.desktop ${filesInHomePerms} ${pkgs.calamares-nixos}/share/applications/calamares.desktop"
      "L+ ${desktopDir}/firefox.desktop ${filesInHomePerms} ${pkgs.firefox}/share/applications/firefox.desktop"
      "L+ ${desktopDir}/gparted.desktop ${filesInHomePerms} ${pkgs.gparted}/share/applications/gparted.desktop"
      "L+ ${desktopDir}/nixos-manual.desktop ${filesInHomePerms} /run/current-system/sw/share/applications/nixos-manual.desktop"

      # Same as ${desktopDir}, need to create all directories in the hierarchy
      "d /home/nixos/.config ${dirsInHomePerms}"
      "d /home/nixos/.config/cosmic ${dirsInHomePerms}"
      "d /home/nixos/.config/cosmic/com.system76.CosmicAppList ${dirsInHomePerms}"
      "d /home/nixos/.config/cosmic/com.system76.CosmicAppList/v1 ${dirsInHomePerms}"
      "L+ /home/nixos/.config/cosmic/com.system76.CosmicAppList/v1/favorites ${filesInHomePerms} ${CosmicAppList_favorites}"
    ];
}
