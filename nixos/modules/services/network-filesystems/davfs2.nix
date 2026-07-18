{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.generators) toINIWithGlobalSection;
  inherit (lib.modules) mkIf mkRemovedOptionModule;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.strings) escape;
  inherit (lib.types)
    attrsOf
    bool
    int
    oneOf
    str
    submodule
    ;

  cfg = config.services.davfs2;

  escapeString = escape [
    "\""
    "\\"
  ];

  formatValue =
    value:
    if true == value then
      "1"
    else if false == value then
      "0"
    else if builtins.isString value then
      "\"${escapeString value}\""
    else
      toString value;

  configFile = pkgs.writeText "davfs2.conf" (
    toINIWithGlobalSection {
      mkKeyValue = k: v: "${k} ${formatValue v}";
      mkSectionName = escapeString;
    } cfg.settings
  );
in
{

  imports = [
    (mkRemovedOptionModule [ "services" "davfs2" "extraConfig" ] ''
      The option extraConfig got removed, please migrate to
      services.davfs2.settings instead.
    '')
  ];

  options.services.davfs2 = {
    enable = mkEnableOption "davfs2";

    davGroup = mkOption {
      default = "davfs2";

      description = ''
        The group of the running mount.davfs daemon. Ordinary users must be
        member of this group in order to mount a davfs2 file system. Value must
        be given as name, not as numerical id.
      '';

      type = str;
    };

    davUser = mkOption {
      default = "davfs2";

      description = ''
        When invoked by root the mount.davfs daemon will run as this user.
        Value must be given as name, not as numerical id.
      '';

      type = str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Extra settings appended to the configuration of davfs2.
        See {manpage}`davfs2.conf(5)` for available settings.
      '';

      example = literalExpression ''
        {
          globalSection = {
            proxy = "foo.bar:8080";
            use_locks = false;
          };
          sections = {
            "/media/dav" = {
              use_locks = true;
            };
            "/home/otto/mywebspace" = {
              gui_optimize = true;
            };
          };
        }
      '';

      type = submodule {
        freeformType =
          let
            valueTypes = [
              bool
              int
              str
            ];
          in
          attrsOf (attrsOf (oneOf (valueTypes ++ [ (attrsOf (oneOf valueTypes)) ])));
      };
    };
  };

  config = mkIf cfg.enable {

    environment.etc."davfs2/davfs2.conf".source = configFile;
    environment.systemPackages = [ pkgs.davfs2 ];

    security.wrappers."mount.davfs" = {
      group = cfg.davGroup;
      owner = "root";
      permissions = "u+rx,g+x";
      program = "mount.davfs";
      setuid = true;
      source = "${pkgs.davfs2}/bin/mount.davfs";
    };

    security.wrappers."umount.davfs" = {
      group = cfg.davGroup;
      owner = "root";
      permissions = "u+rx,g+x";
      program = "umount.davfs";
      setuid = true;
      source = "${pkgs.davfs2}/bin/umount.davfs";
    };

    services.davfs2.settings = {
      globalSection = {
        dav_group = cfg.davGroup;
        dav_user = cfg.davUser;
      };
    };

    users.groups = optionalAttrs (cfg.davGroup == "davfs2") {
      davfs2.gid = config.ids.gids.davfs2;
    };

    users.users = optionalAttrs (cfg.davUser == "davfs2") {
      davfs2 = {
        createHome = false;
        description = "davfs2 user";
        group = cfg.davGroup;
        uid = config.ids.uids.davfs2;
      };
    };

  };

}
