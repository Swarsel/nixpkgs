{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.cntlm;

  configFile =
    if cfg.configText != "" then
      pkgs.writeText "cntlm.conf" ''
        ${cfg.configText}
      ''
    else
      pkgs.writeText "lighttpd.conf" ''
        # Cntlm Authentication Proxy Configuration
        Username ${cfg.username}
        Domain ${cfg.domain}
        Password ${cfg.password}
        ${lib.optionalString (cfg.netbios_hostname != "") "Workstation ${cfg.netbios_hostname}"}
        ${lib.concatMapStrings (entry: "Proxy ${entry}\n") cfg.proxy}
        ${lib.optionalString (cfg.noproxy != [ ]) "NoProxy ${lib.concatStringsSep ", " cfg.noproxy}"}

        ${lib.concatMapStrings (port: ''
          Listen ${toString port}
        '') cfg.port}

        ${cfg.extraConfig}
      '';

in

{

  options.services.cntlm = {

    enable = lib.mkEnableOption "cntlm, which starts a local proxy";

    configText = lib.mkOption {
      default = "";
      description = "Verbatim contents of {file}`cntlm.conf`.";
      type = lib.types.lines;
    };

    domain = lib.mkOption {
      description = "Proxy account domain/workgroup name.";
      type = lib.types.str;
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "Additional config appended to the end of the generated {file}`cntlm.conf`.";
      type = lib.types.lines;
    };

    netbios_hostname = lib.mkOption {
      default = "";

      description = ''
        The hostname of your machine.
      '';

      type = lib.types.str;
    };

    noproxy = lib.mkOption {
      default = [ ];

      description = ''
        A list of domains where the proxy is skipped.
      '';

      example = [
        "*.example.com"
        "example.com"
      ];

      type = lib.types.listOf lib.types.str;
    };

    password = lib.mkOption {
      default = "/etc/cntlm.password";
      description = "Proxy account password. Note: use chmod 0600 on /etc/cntlm.password for security.";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = [ 3128 ];
      description = "Specifies on which ports the cntlm daemon listens.";
      type = lib.types.listOf lib.types.port;
    };

    proxy = lib.mkOption {
      description = ''
        A list of NTLM/NTLMv2 authenticating HTTP proxies.

        Parent proxy, which requires authentication. The same as proxy on the command-line, can be used more than  once  to  specify  unlimited
        number  of  proxies.  Should  one proxy fail, cntlm automatically moves on to the next one. The connect request fails only if the whole
        list of proxies is scanned and (for each request) and found to be invalid. Command-line takes precedence over the configuration file.
      '';

      example = [ "proxy.example.com:81" ];
      type = lib.types.listOf lib.types.str;
    };

    username = lib.mkOption {
      description = ''
        Proxy account name, without the possibility to include domain name ('at' sign is interpreted literally).
      '';

      type = lib.types.str;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.cntlm = {
      after = [ "network.target" ];
      description = "CNTLM is an NTLM / NTLM Session Response / NTLMv2 authenticating HTTP proxy";

      serviceConfig = {
        ExecStart = ''
          ${pkgs.cntlm}/bin/cntlm -U cntlm -c ${configFile} -v -f
        '';

        User = "cntlm";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.users.cntlm = {
      description = "cntlm system-wide daemon";
      isSystemUser = true;
      name = "cntlm";
    };
  };
}
