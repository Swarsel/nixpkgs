{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.appimage;
in

{
  options.programs.appimage = {
    enable = lib.mkEnableOption "appimage-run wrapper script for executing appimages on NixOS";

    package = lib.mkPackageOption pkgs "appimage-run" {
      example = ''
        pkgs.appimage-run.override {
          extraPkgs = pkgs: [ pkgs.ffmpeg pkgs.imagemagick ];
        }
      '';
    };

    binfmt = lib.mkEnableOption "binfmt registration to run appimages via appimage-run seamlessly";
  };

  config = lib.mkIf cfg.enable {
    boot.binfmt.registrations = lib.mkIf cfg.binfmt (
      let
        appimage_common = {
          interpreter = lib.getExe cfg.package;
          mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
          offset = 0;
          recognitionType = "magic";
          wrapInterpreterInShell = false;
        };
      in
      {
        appimage_type_1 = appimage_common // {
          magicOrExtension = ''\x7fELF....AI\x01'';
        };

        appimage_type_2 = appimage_common // {
          magicOrExtension = ''\x7fELF....AI\x02'';
        };
      }
    );

    environment.systemPackages = [ cfg.package ];
    programs.fuse.enable = true;
  };

  meta.maintainers = with lib.maintainers; [
    jopejoe1
    atemu
    aleksana
  ];
}
