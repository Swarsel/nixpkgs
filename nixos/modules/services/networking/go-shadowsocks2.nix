{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.go-shadowsocks2.server;
in
{
  options.services.go-shadowsocks2.server = {
    enable = lib.mkEnableOption "go-shadowsocks2 server";

    listenAddress = lib.mkOption {
      description = "Server listen address or URL";
      example = "ss://AEAD_CHACHA20_POLY1305:your-password@:8488";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.go-shadowsocks2-server = {
      after = [ "network.target" ];
      description = "go-shadowsocks2 server";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.go-shadowsocks2}/bin/go-shadowsocks2 -s '${cfg.listenAddress}'";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
