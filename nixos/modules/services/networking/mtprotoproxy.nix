{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.mtprotoproxy;

  configOpts = {
    PORT = cfg.port;
    SECURE_ONLY = cfg.secureOnly;
    USERS = cfg.users;
  }
  // lib.optionalAttrs (cfg.adTag != null) { AD_TAG = cfg.adTag; }
  // cfg.extraConfig;

  convertOption =
    opt:
    if isString opt || isInt opt then
      builtins.toJSON opt
    else if isBool opt then
      if opt then "True" else "False"
    else if isList opt then
      "[" + concatMapStringsSep "," convertOption opt + "]"
    else if isAttrs opt then
      "{"
      + concatStringsSep "," (
        mapAttrsToList (name: opt: "${builtins.toJSON name}: ${convertOption opt}") opt
      )
      + "}"
    else
      throw "Invalid option type";

  configFile = pkgs.writeText "config.py" (
    concatStringsSep "\n" (mapAttrsToList (name: opt: "${name} = ${convertOption opt}") configOpts)
  );

in

{

  ###### interface

  options = {

    services.mtprotoproxy = {

      enable = mkEnableOption "mtprotoproxy";

      adTag = mkOption {
        default = null;

        description = ''
          Tag for advertising that can be obtained from @MTProxybot.
        '';

        # Taken from mtproxyproto's repo.
        example = "3c09c680b76ee91a4c25ad51f742267d";
        type = types.nullOr types.str;
      };

      extraConfig = mkOption {
        default = { };

        description = ''
          Extra configuration options for mtprotoproxy.
        '';

        example = {
          STATS_PRINT_PERIOD = 600;
        };

        type = types.attrs;
      };

      port = mkOption {
        default = 3256;

        description = ''
          TCP port to accept mtproto connections on.
        '';

        type = types.port;
      };

      secureOnly = mkOption {
        default = true;

        description = ''
          Don't allow users to connect in non-secure mode (without random padding).
        '';

        type = types.bool;
      };

      users = mkOption {
        description = ''
          Allowed users and their secrets. A secret is a 32 characters long hex string.
        '';

        example = {
          tg = "00000000000000000000000000000000";
          tg2 = "0123456789abcdef0123456789abcdef";
        };

        type = types.attrsOf types.str;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.mtprotoproxy = {
      description = "MTProto Proxy Daemon";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.mtprotoproxy}/bin/mtprotoproxy ${configFile}";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
