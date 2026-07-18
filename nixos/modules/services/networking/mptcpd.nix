{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mptcpd;
  settingsFormat = pkgs.formats.ini { };
in
{

  options = {

    services.mptcpd = {

      enable = lib.mkEnableOption "the Multipath TCP path management daemon";
      package = lib.mkPackageOption pkgs "mptcpd" { };

      settings = lib.mkOption {
        default = { };

        description = ''
          mptcpd configuration written to {file}`/etc/mptcpd/mptcpd.conf`.

          See {manpage}`mptcpd(8)` for details about available options and syntax.
        '';

        example = lib.literalExpression ''
          {
            core = {
              "addr-flags" = "subflow";
              "notify-flags" = "existing,skip_link_local,skip_loopback,check_route";
              "load-plugins" = "addr_adv,sspi";
            };
          }
        '';

        type = settingsFormat.type;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    environment.etc."mptcpd/mptcpd.conf".source = settingsFormat.generate "mptcpd.conf" cfg.settings;
    environment.systemPackages = [ cfg.package ];

    # Disable NetworkManager from configuring the MPTCP endpoints.
    # See https://github.com/multipath-tcp/mptcpd/blob/48942b2110805af236ca41164fde67830efd7507/README.md?plain=1#L19-L38
    networking.networkmanager.connectionConfig = {
      "connection.mptcp-flags" = 1;
    };

    services.mptcpd.settings = {
      core = {
        log = lib.mkDefault "journal";
        "path-manager" = lib.mkDefault "addr_adv";
        "plugin-dir" = "${cfg.package}/lib/mptcpd";
      };
    };

    systemd.packages = [ cfg.package ];

    systemd.services.mptcp = {
      serviceConfig.ExecStart = [
        ""
        "${cfg.package}/libexec/mptcpd"
      ];

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ nim65s ];
}
