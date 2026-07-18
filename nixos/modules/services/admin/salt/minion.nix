{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.salt.minion;

  fullConfig = lib.recursiveUpdate {
    # Provide defaults for some directories to allow an immutable config dir
    # NOTE: the config dir being immutable prevents `minion_id` caching

    # Default is equivalent to /etc/salt/minion.d/*.conf
    default_include = "/var/lib/salt/minion.d/*.conf";
    # Default is in /etc/salt/pki/minion
    pki_dir = "/var/lib/salt/pki/minion";
  } cfg.configuration;

in

{
  options = {
    services.salt.minion = {
      enable = lib.mkEnableOption "Salt configuration management system minion service";

      configuration = lib.mkOption {
        default = { };

        description = ''
          Salt minion configuration as Nix attribute set.
          See <https://docs.saltstack.com/en/latest/ref/configuration/minion.html>
          for details.
        '';

        type = lib.types.attrs;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # Set this up in /etc/salt/minion so `salt-call`, etc. work.
      # The alternatives are
      # - passing --config-dir to all salt commands, not just the minion unit,
      # - setting aglobal environment variable.
      etc."salt/minion".source = pkgs.writeText "minion" (builtins.toJSON fullConfig);
      systemPackages = with pkgs; [ salt ];
    };

    systemd.services.salt-minion = {
      after = [ "network.target" ];
      description = "Salt Minion";

      path = with pkgs; [
        util-linux
      ];

      restartTriggers = [
        config.environment.etc."salt/minion".source
      ];

      serviceConfig = {
        ExecStart = "${pkgs.salt}/bin/salt-minion";
        LimitNOFILE = 8192;
        NotifyAccess = "all";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
