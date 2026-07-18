{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nix-ld;

  nix-ld-libraries = pkgs.buildEnv {
    extraPrefix = "/share/nix-ld";
    ignoreCollisions = true;
    name = "ld-library-path";
    paths = map lib.getLib cfg.libraries;
    pathsToLink = [ "/lib" ];

    # TODO make glibc here configurable?
    postBuild = ''
      ln -s ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/share/nix-ld/lib/ld.so
    '';
  };
in
{
  options.programs.nix-ld = {
    enable = lib.mkEnableOption "nix-ld, Documentation: <https://github.com/nix-community/nix-ld>";
    package = lib.mkPackageOption pkgs "nix-ld" { };

    libraries = lib.mkOption {
      default = [ ];
      defaultText = lib.literalExpression "baseLibraries derived from systemd and nix dependencies.";
      description = "Libraries that automatically become available to all programs. The default set includes common libraries.";
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf config.programs.nix-ld.enable {
    environment.ldso = "${cfg.package}/libexec/nix-ld";
    environment.pathsToLink = [ "/share/nix-ld" ];

    environment.sessionVariables = {
      NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
      NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    };

    environment.systemPackages = [ nix-ld-libraries ];

    # We currently take all libraries from systemd and nix as the default.
    # Is there a better list?
    programs.nix-ld.libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };

  meta.maintainers = [ lib.maintainers.mic92 ];
}
