{
  config,
  lib,
  pkgs,
  ...
}:
let
  pkg = pkgs._3proxy;
  cfg = config.services._3proxy;
  optionalList = list: if list == [ ] then "*" else lib.concatMapStringsSep "," toString list;
in
{
  options.services._3proxy = {
    enable = lib.mkEnableOption "3proxy";

    confFile = lib.mkOption {
      description = ''
        Ignore all other 3proxy options and load configuration from this file.
      '';

      example = "/var/lib/3proxy/3proxy.conf";
      type = lib.types.path;
    };

    denyPrivate = lib.mkOption {
      default = true;

      description = ''
        Whether to deny access to private IP ranges including loopback.
      '';

      type = lib.types.bool;
    };

    extraConfig = lib.mkOption {
      default = null;

      description = ''
        Extra configuration, appended to the 3proxy configuration file.
        Consult [documentation](https://github.com/z3APA3A/3proxy/wiki/3proxy.cfg) for available options.
      '';

      type = lib.types.nullOr lib.types.lines;
    };

    privateRanges = lib.mkOption {
      default = [
        "0.0.0.0/8"
        "127.0.0.0/8"
        "10.0.0.0/8"
        "100.64.0.0/10"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "::"
        "::1"
        "fc00::/7"
      ];

      description = ''
        What IP ranges to deny access when denyPrivate is set tu true.
      '';

      type = lib.types.listOf lib.types.str;
    };

    resolution = lib.mkOption {
      default = { };

      description = ''
        Use this option to configure name resolution and DNS caching.
      '';

      type = lib.types.submodule {
        options = {
          nscache = lib.mkOption {
            default = 65535;
            description = "Set name cache size for IPv4.";
            type = lib.types.int;
          };

          nscache6 = lib.mkOption {
            default = 65535;
            description = "Set name cache size for IPv6.";
            type = lib.types.int;
          };

          nserver = lib.mkOption {
            default = [ ];

            description = ''
              List of nameservers to use.

              Up to 5 nservers may be specified. If no nserver is configured,
              default system name resolution functions are used.
            '';

            example = [
              "127.0.0.53"
              "192.168.1.3:5353/tcp"
            ];

            type = lib.types.listOf lib.types.str;
          };

          nsrecord = lib.mkOption {
            default = { };
            description = "Adds static nsrecords.";

            example = lib.literalExpression ''
              {
                "files.local" = "192.168.1.12";
                "site.local" = "192.168.1.43";
              }
            '';

            type = lib.types.attrsOf lib.types.str;
          };
        };
      };
    };

    services = lib.mkOption {
      default = [ ];

      description = ''
        Use this option to define 3proxy services.
      '';

      example = lib.literalExpression ''
        [
          {
            type = "proxy";
            bindAddress = "192.168.1.24";
            bindPort = 3128;
            auth = [ "none" ];
          }
          {
            type = "proxy";
            bindAddress = "10.10.1.20";
            bindPort = 3128;
            auth = [ "iponly" ];
          }
          {
            type = "socks";
            bindAddress = "172.17.0.1";
            bindPort = 1080;
            auth = [ "strong" ];
          }
        ]
      '';

      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            acl = lib.mkOption {
              default = [ ];

              description = ''
                Use this option to limit user access to resources.
              '';

              example = lib.literalExpression ''
                [
                  {
                    rule = "allow";
                    users = [ "user1" ];
                  }
                  {
                    rule = "allow";
                    sources = [ "192.168.1.0/24" ];
                  }
                  {
                    rule = "deny";
                  }
                ]
              '';

              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    rule = lib.mkOption {
                      description = ''
                        ACL rule. The following values are valid:

                        - `"allow"`: connections allowed.
                        - `"deny"`: connections not allowed.
                      '';

                      example = "allow";

                      type = lib.types.enum [
                        "allow"
                        "deny"
                      ];
                    };

                    sources = lib.mkOption {
                      default = [ ];

                      description = ''
                        List of source IP range, use empty list for any.
                      '';

                      example = [
                        "127.0.0.1"
                        "192.168.1.0/24"
                      ];

                      type = lib.types.listOf lib.types.str;
                    };

                    targetPorts = lib.mkOption {
                      default = [ ];

                      description = ''
                        List of target ports, use empty list for any.
                      '';

                      example = [
                        80
                        443
                      ];

                      type = lib.types.listOf lib.types.port;
                    };

                    targets = lib.mkOption {
                      default = [ ];

                      description = ''
                        List of target IP ranges, use empty list for any.
                        May also contain host names instead of addresses.
                        It's possible to use wildmask in the beginning and in the the end of hostname, e.g. `*badsite.com` or `*badcontent*`.
                        Hostname is only checked if hostname presents in request.
                      '';

                      example = [
                        "127.0.0.1"
                        "192.168.1.0/24"
                      ];

                      type = lib.types.listOf lib.types.str;
                    };

                    users = lib.mkOption {
                      default = [ ];

                      description = ''
                        List of users, use empty list for any.
                      '';

                      example = [
                        "user1"
                        "user2"
                        "user3"
                      ];

                      type = lib.types.listOf lib.types.str;
                    };
                  };
                }
              );
            };

            auth = lib.mkOption {
              description = ''
                Authentication type. The following values are valid:

                - `"none"`: disables both authentication and authorization. You can not use ACLs.
                - `"iponly"`: specifies no authentication. ACLs authorization is used.
                - `"strong"`: authentication by username/password. If user is not registered their access is denied regardless of ACLs.

                Double authentication is possible, e.g.

                ```
                  {
                    auth = [ "iponly" "strong" ];
                    acl = [
                      {
                        rule = "allow";
                        targets = [ "192.168.0.0/16" ];
                      }
                      {
                        rule = "allow"
                        users = [ "user1" "user2" ];
                      }
                    ];
                  }
                ```
                In this example strong username authentication is not required to access 192.168.0.0/16.
              '';

              example = [
                "iponly"
                "strong"
              ];

              type = lib.types.listOf (
                lib.types.enum [
                  "none"
                  "iponly"
                  "strong"
                ]
              );
            };

            bindAddress = lib.mkOption {
              default = "[::]";

              description = ''
                Address used for service.
              '';

              example = "127.0.0.1";
              type = lib.types.str;
            };

            bindPort = lib.mkOption {
              default = null;

              description = ''
                Override default port used for service.
              '';

              example = 3128;
              type = lib.types.nullOr lib.types.port;
            };

            extraArguments = lib.mkOption {
              default = null;

              description = ''
                Extra arguments for service.
                Consult "Options" section in [documentation](https://github.com/z3APA3A/3proxy/wiki/3proxy.cfg) for available arguments.
              '';

              example = "-46";
              type = lib.types.nullOr lib.types.str;
            };

            extraConfig = lib.mkOption {
              default = null;

              description = ''
                Extra configuration for service. Use this to configure things like bandwidth limiter or ACL-based redirection.
                Consult [documentation](https://github.com/z3APA3A/3proxy/wiki/3proxy.cfg) for available options.
              '';

              type = lib.types.nullOr lib.types.lines;
            };

            maxConnections = lib.mkOption {
              default = 100;

              description = ''
                Maximum number of simulationeous connections to this service.
              '';

              example = 1000;
              type = lib.types.int;
            };

            type = lib.mkOption {
              description = ''
                Service type. The following values are valid:

                - `"proxy"`: HTTP/HTTPS proxy (default port 3128).
                - `"socks"`: SOCKS 4/4.5/5 proxy (default port 1080).
                - `"pop3p"`: POP3 proxy (default port 110).
                - `"ftppr"`: FTP proxy (default port 21).
                - `"admin"`: Web interface (default port 80).
                - `"dnspr"`: Caching DNS proxy (default port 53).
                - `"tcppm"`: TCP portmapper.
                - `"udppm"`: UDP portmapper.
                - `"auto"`: Proxy with protocol autoselection between proxy / socks / tlspr.
              '';

              example = "proxy";

              type = lib.types.enum [
                "proxy"
                "socks"
                "pop3p"
                "ftppr"
                "admin"
                "dnspr"
                "tcppm"
                "udppm"
                "auto"
              ];
            };
          };
        }
      );
    };

    usersFile = lib.mkOption {
      default = null;

      description = ''
        Load users and passwords from this file.

        Example users file with plain-text passwords:

        ```
          test1:CL:password1
          test2:CL:password2
        ```

        Example users file with md5-crypted passwords:

        ```
          test1:CR:$1$tFkisVd2$1GA8JXkRmTXdLDytM/i3a1
          test2:CR:$1$rkpibm5J$Aq1.9VtYAn0JrqZ8M.1ME.
        ```

        You can generate md5-crypted passwords via <https://unix4lyfe.org/crypt/>
        Note that htpasswd tool generates incompatible md5-crypted passwords.
        Consult [documentation](https://github.com/z3APA3A/3proxy/wiki/How-To-%28incomplete%29#USERS) for more information.
      '';

      example = "/var/lib/3proxy/3proxy.passwd";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services._3proxy.confFile = lib.mkDefault (
      pkgs.writeText "3proxy.conf" ''
        # log to stdout
        log

        ${lib.concatMapStringsSep "\n" (x: "nserver " + x) cfg.resolution.nserver}

        nscache ${toString cfg.resolution.nscache}
        nscache6 ${toString cfg.resolution.nscache6}

        ${lib.concatMapStringsSep "\n" (x: "nsrecord " + x) (
          lib.mapAttrsToList (name: value: "${name} ${value}") cfg.resolution.nsrecord
        )}

        ${lib.optionalString (cfg.usersFile != null) ''users $"${cfg.usersFile}"''}

        ${lib.concatMapStringsSep "\n" (service: ''
          auth ${lib.concatStringsSep " " service.auth}

          ${lib.optionalString (cfg.denyPrivate) "deny * * ${optionalList cfg.privateRanges}"}

          ${lib.concatMapStringsSep "\n" (
            acl:
            "${acl.rule} ${
              lib.concatMapStringsSep " " optionalList [
                acl.users
                acl.sources
                acl.targets
                acl.targetPorts
              ]
            }"
          ) service.acl}

          maxconn ${toString service.maxConnections}

          ${lib.optionalString (service.extraConfig != null) service.extraConfig}

          ${service.type} -i${toString service.bindAddress} ${
            lib.optionalString (service.bindPort != null) "-p${toString service.bindPort}"
          } ${lib.optionalString (service.extraArguments != null) service.extraArguments}

          flush
        '') cfg.services}
        ${lib.optionalString (cfg.extraConfig != null) cfg.extraConfig}
      ''
    );

    systemd.services."3proxy" = {
      after = [ "network.target" ];
      description = "Tiny free proxy server";
      documentation = [ "https://github.com/z3APA3A/3proxy/wiki" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkg}/bin/3proxy ${cfg.confFile}";
        Restart = "on-failure";
        StateDirectory = "3proxy";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ misuzu ];
}
