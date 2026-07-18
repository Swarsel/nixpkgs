{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.taskserver;

  taskd = "${pkgs.taskserver}/bin/taskd";

  mkManualPkiOption =
    desc:
    lib.mkOption {
      default = null;

      description = ''
        ${desc}

        ::: {.note}
        Setting this option will prevent automatic CA creation and handling.
        :::
      '';

      type = lib.types.nullOr lib.types.path;
    };

  manualPkiOptions = {
    ca.cert = mkManualPkiOption ''
      Fully qualified path to the CA certificate.
    '';

    server.cert = mkManualPkiOption ''
      Fully qualified path to the server certificate.
    '';

    server.crl = mkManualPkiOption ''
      Fully qualified path to the server certificate revocation list.
    '';

    server.key = mkManualPkiOption ''
      Fully qualified path to the server key.
    '';
  };

  mkAutoDesc = preamble: ''
    ${preamble}

    ::: {.note}
    This option is for the automatically handled CA and will be ignored if any
    of the {option}`services.taskserver.pki.manual.*` options are set.
    :::
  '';

  mkExpireOption =
    desc:
    lib.mkOption {
      apply = val: if val == null then -1 else val;
      default = null;

      description = mkAutoDesc ''
        The expiration time of ${desc} in days or `null` for no
        expiration time.
      '';

      example = 365;
      type = lib.types.nullOr lib.types.int;
    };

  autoPkiOptions = {
    bits = lib.mkOption {
      default = 4096;
      description = mkAutoDesc "The bit size for generated keys.";
      example = 2048;
      type = lib.types.int;
    };

    expiration = {
      ca = mkExpireOption "the CA certificate";
      client = mkExpireOption "client certificates";
      crl = mkExpireOption "the certificate revocation list (CRL)";
      server = mkExpireOption "the server certificate";
    };
  };

  needToCreateCA =
    let
      notFound =
        path:
        let
          dotted = lib.concatStringsSep "." path;
        in
        throw "Can't find option definitions for path `${dotted}'.";
      findPkiDefinitions =
        path: attrs:
        let
          mkSublist =
            key: val:
            let
              newPath = path ++ lib.singleton key;
            in
            if lib.isOption val then
              lib.attrByPath newPath (notFound newPath) cfg.pki.manual
            else
              findPkiDefinitions newPath val;
        in
        lib.flatten (lib.mapAttrsToList mkSublist attrs);
    in
    lib.all (x: x == null) (findPkiDefinitions [ ] manualPkiOptions);

  orgOptions =
    { ... }:
    {
      options.groups = lib.mkOption {
        default = [ ];

        description = ''
          A list of group names that belong to the organization.
        '';

        example = [
          "workers"
          "slackers"
        ];

        type = lib.types.listOf lib.types.str;
      };

      options.users = lib.mkOption {
        default = [ ];

        description = ''
          A list of user names that belong to the organization.
        '';

        example = [
          "alice"
          "bob"
        ];

        type = lib.types.uniq (lib.types.listOf lib.types.str);
      };
    };

  certtool = "${pkgs.gnutls.bin}/bin/certtool";

  nixos-taskserver =
    with pkgs.python3.pkgs;
    buildPythonApplication {
      format = "setuptools";
      name = "nixos-taskserver";
      propagatedBuildInputs = [ click ];

      src = pkgs.runCommand "nixos-taskserver-src" { preferLocalBuild = true; } ''
        mkdir -p "$out"
        cat "${
          pkgs.replaceVars ./helper-tool.py {
            inherit taskd certtool;

            inherit (cfg)
              dataDir
              user
              group
              fqdn
              ;

            certBits = cfg.pki.auto.bits;
            clientExpiration = cfg.pki.auto.expiration.client;
            crlExpiration = cfg.pki.auto.expiration.crl;
            isAutoConfig = if needToCreateCA then "True" else "False";
          }
        }" > "$out/main.py"
        cat > "$out/setup.py" <<EOF
        from setuptools import setup
        setup(name="nixos-taskserver",
              py_modules=["main"],
              install_requires=["Click"],
              entry_points="[console_scripts]\\nnixos-taskserver=main:cli")
        EOF
      '';
    };

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "taskserver" "extraConfig" ] ''
      This option was removed in favor of `services.taskserver.config` with
      different semantics (it's now a list of attributes instead of lines).

      Please look up the documentation of `services.taskserver.config' to get
      more information about the new way to pass additional configuration
      options.
    '')
  ];

  options = {
    services.taskserver = {
      config = lib.mkOption {
        apply =
          let
            mkKey =
              path:
              if
                path == [
                  "server"
                  "listen"
                ]
              then
                "server"
              else
                lib.concatStringsSep "." path;
            recurse =
              path: attrs:
              let
                mapper =
                  name: val:
                  let
                    newPath = path ++ [ name ];
                    scalar =
                      if val == true then
                        "true"
                      else if val == false then
                        "false"
                      else
                        toString val;
                  in
                  if lib.isAttrs val then recurse newPath val else [ "${mkKey newPath}=${scalar}" ];
              in
              lib.concatLists (lib.mapAttrsToList mapper attrs);
          in
          recurse [ ];

        description = ''
          Configuration options to pass to Taskserver.

          The options here are the same as described in
          {manpage}`taskdrc(5)` from the `taskwarrior2` package, but with one difference:

          The `server` option is
          `server.listen` here, because the
          `server` option would collide with other options
          like `server.cert` and we would run in a type error
          (attribute set versus string).

          Nix types like integers or booleans are automatically converted to
          the right values Taskserver would expect.
        '';

        example.client.cert = "/tmp/debugging.cert";
        type = lib.types.attrs;
      };

      enable = lib.mkOption {
        default = false;

        description =
          let
            url = "https://nixos.org/manual/nixos/stable/index.html#module-services-taskserver";
          in
          ''
            Whether to enable the Taskwarrior 2 server.

            More instructions about NixOS in conjunction with Taskserver can be
            found [in the NixOS manual](${url}).
          '';

        type = lib.types.bool;
      };

      allowedClientIDs = lib.mkOption {
        default = [ ];

        description = ''
          A list of regular expressions that are matched against the reported
          client id (such as `task 2.3.0`).

          The values `all` or `none` have
          special meaning. Overridden by any entry in the option
          {option}`services.taskserver.disallowedClientIDs`.
        '';

        example = [ "[Tt]ask [2-9]+" ];
        type = with lib.types; either str (listOf str);
      };

      ciphers = lib.mkOption {
        default = null;

        description =
          let
            url = "https://gnutls.org/manual/html_node/Priority-Strings.html";
          in
          ''
            List of GnuTLS ciphers to use. See the GnuTLS documentation about
            priority strings at <${url}> for full details.
          '';

        example = "NORMAL:-VERS-SSL3.0";
        type = lib.types.nullOr (lib.types.separatedString ":");
      };

      confirmation = lib.mkOption {
        default = true;

        description = ''
          Determines whether certain commands are confirmed.
        '';

        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/taskserver";
        description = "Data directory for Taskserver.";
        type = lib.types.path;
      };

      debug = lib.mkOption {
        default = false;

        description = ''
          Logs debugging information.
        '';

        type = lib.types.bool;
      };

      disallowedClientIDs = lib.mkOption {
        default = [ ];

        description = ''
          A list of regular expressions that are matched against the reported
          client id (such as `task 2.3.0`).

          The values `all` or `none` have
          special meaning. Any entry here overrides those in
          {option}`services.taskserver.allowedClientIDs`.
        '';

        example = [ "[Tt]ask [2-9]+" ];
        type = with lib.types; either str (listOf str);
      };

      extensions = lib.mkOption {
        default = null;

        description = ''
          Fully qualified path of the Taskserver extension scripts.
          Currently there are none.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      fqdn = lib.mkOption {
        default = "localhost";

        description = ''
          The fully qualified domain name of this server, which is also used
          as the common name in the certificates.
        '';

        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "taskd";
        description = "Group for Taskserver.";
        type = lib.types.str;
      };

      ipLog = lib.mkOption {
        default = false;

        description = ''
          Logs the IP addresses of incoming requests.
        '';

        type = lib.types.bool;
      };

      listenHost = lib.mkOption {
        default = "localhost";

        description = ''
          The address (IPv4, IPv6 or DNS) to listen on.
        '';

        example = "::";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 53589;

        description = ''
          Port number of the Taskserver.
        '';

        type = lib.types.port;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the firewall for the specified Taskserver port.
        '';

        type = lib.types.bool;
      };

      organisations = lib.mkOption {
        default = { };

        description = ''
          An attribute set where the keys name the organisation and the values
          are a set of lists of {option}`users` and
          {option}`groups`.
        '';

        example.myShinyOrganisation.groups = [
          "staff"
          "outsiders"
        ];

        example.myShinyOrganisation.users = [
          "alice"
          "bob"
        ];

        example.yetAnotherOrganisation.users = [
          "foo"
          "bar"
        ];

        type = lib.types.attrsOf (lib.types.submodule orgOptions);
      };

      pki.auto = autoPkiOptions;
      pki.manual = manualPkiOptions;

      queueSize = lib.mkOption {
        default = 10;

        description = ''
          Size of the connection backlog, see {manpage}`listen(2)`.
        '';

        type = lib.types.int;
      };

      requestLimit = lib.mkOption {
        default = 1048576;

        description = ''
          Size limit of incoming requests, in bytes.
        '';

        type = lib.types.int;
      };

      trust = lib.mkOption {
        default = "strict";

        description = ''
          Determines how client certificates are validated.

          The value `allow all` performs no client
          certificate validation. This is not recommended. The value
          `strict` causes the client certificate to be
          validated against a CA.
        '';

        type = lib.types.enum [
          "allow all"
          "strict"
        ];
      };

      user = lib.mkOption {
        default = "taskd";
        description = "User for Taskserver.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [ nixos-taskserver ];

      services.taskserver.config = {
        ca.cert = if needToCreateCA then "${cfg.dataDir}/keys/ca.cert" else "${cfg.pki.manual.ca.cert}";
        # general
        ciphers = cfg.ciphers;
        # client
        client.allow = cfg.allowedClientIDs;
        client.deny = cfg.disallowedClientIDs;
        confirmation = cfg.confirmation;
        # systemd related
        daemon = false;
        # logging
        debug = cfg.debug;
        extensions = cfg.extensions;
        ip.log = cfg.ipLog;
        log = "-";
        queue.size = cfg.queueSize;
        request.limit = cfg.requestLimit;

        server = {
          listen = "${cfg.listenHost}:${toString cfg.listenPort}";
        }
        // (
          if needToCreateCA then
            {
              cert = "${cfg.dataDir}/keys/server.cert";
              crl = "${cfg.dataDir}/keys/server.crl";
              key = "${cfg.dataDir}/keys/server.key";
            }
          else
            {
              ${lib.mapNullable (_: "crl") cfg.pki.manual.server.crl} = "${cfg.pki.manual.server.crl}";
              cert = "${cfg.pki.manual.server.cert}";
              key = "${cfg.pki.manual.server.key}";
            }
        );

        # server
        trust = cfg.trust;
      };

      systemd.services.taskserver = {
        after = [ "network.target" ];
        description = "Taskwarrior 2 Server";
        environment.TASKDDATA = cfg.dataDir;

        preStart =
          let
            jsonOrgs = builtins.toJSON cfg.organisations;
            jsonFile = pkgs.writeText "orgs.json" jsonOrgs;
            helperTool = "${nixos-taskserver}/bin/nixos-taskserver";
          in
          "${helperTool} process-json '${jsonFile}'";

        serviceConfig = {
          ExecReload = "${pkgs.coreutils}/bin/kill -USR1 $MAINPID";

          ExecStart =
            let
              mkCfgFlag = flag: lib.escapeShellArg "--${flag}";
              cfgFlags = lib.concatMapStringsSep " " mkCfgFlag cfg.config;
            in
            "@${taskd} taskd server ${cfgFlags}";

          Group = cfg.group;
          PermissionsStartOnly = true;
          PrivateDevices = true;
          PrivateTmp = true;
          Restart = "on-failure";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.taskserver-init = {
        before = [ "taskserver.service" ];
        description = "Initialize Taskserver Data Directory";
        environment.TASKDDATA = cfg.dataDir;

        script = ''
          ${taskd} init
          touch "${cfg.dataDir}/.is_initialized"
        '';

        serviceConfig.Group = cfg.group;
        serviceConfig.PermissionsStartOnly = true;
        serviceConfig.PrivateDevices = true;
        serviceConfig.PrivateNetwork = true;
        serviceConfig.PrivateTmp = true;
        serviceConfig.Type = "oneshot";
        serviceConfig.User = cfg.user;
        unitConfig.ConditionPathExists = "!${cfg.dataDir}/.is_initialized";
        wantedBy = [ "taskserver.service" ];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group}"
        "z ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group}"
      ];

      users.groups = lib.optionalAttrs (cfg.group == "taskd") {
        taskd.gid = config.ids.gids.taskd;
      };

      users.users = lib.optionalAttrs (cfg.user == "taskd") {
        taskd = {
          description = "Taskserver user";
          group = cfg.group;
          uid = config.ids.uids.taskd;
        };
      };
    })
    (lib.mkIf (cfg.enable && needToCreateCA) {
      systemd.services.taskserver-ca = {
        after = [ "taskserver-init.service" ];
        before = [ "taskserver.service" ];
        description = "Initialize CA for TaskServer";

        script = ''
          silent_certtool() {
            if ! output="$("${certtool}" "$@" 2>&1)"; then
              echo "GNUTLS certtool invocation failed with output:" >&2
              echo "$output" >&2
            fi
          }

          mkdir -m 0700 -p "${cfg.dataDir}/keys"
          chown root:root "${cfg.dataDir}/keys"

          if [ ! -e "${cfg.dataDir}/keys/ca.key" ]; then
            silent_certtool -p \
              --bits ${toString cfg.pki.auto.bits} \
              --outfile "${cfg.dataDir}/keys/ca.key"
            silent_certtool -s \
              --template "${pkgs.writeText "taskserver-ca.template" ''
                cn = ${cfg.fqdn}
                expiration_days = ${toString cfg.pki.auto.expiration.ca}
                cert_signing_key
                ca
              ''}" \
              --load-privkey "${cfg.dataDir}/keys/ca.key" \
              --outfile "${cfg.dataDir}/keys/ca.cert"

            chgrp "${cfg.group}" "${cfg.dataDir}/keys/ca.cert"
            chmod g+r "${cfg.dataDir}/keys/ca.cert"
          fi

          if [ ! -e "${cfg.dataDir}/keys/server.key" ]; then
            silent_certtool -p \
              --bits ${toString cfg.pki.auto.bits} \
              --outfile "${cfg.dataDir}/keys/server.key"

            silent_certtool -c \
              --template "${pkgs.writeText "taskserver-cert.template" ''
                cn = ${cfg.fqdn}
                expiration_days = ${toString cfg.pki.auto.expiration.server}
                tls_www_server
                encryption_key
                signing_key
              ''}" \
              --load-ca-privkey "${cfg.dataDir}/keys/ca.key" \
              --load-ca-certificate "${cfg.dataDir}/keys/ca.cert" \
              --load-privkey "${cfg.dataDir}/keys/server.key" \
              --outfile "${cfg.dataDir}/keys/server.cert"

            chgrp "${cfg.group}" \
              "${cfg.dataDir}/keys/server.key" \
              "${cfg.dataDir}/keys/server.cert"

            chmod g+r \
              "${cfg.dataDir}/keys/server.key" \
              "${cfg.dataDir}/keys/server.cert"
          fi

          if [ ! -e "${cfg.dataDir}/keys/server.crl" ]; then
            silent_certtool --generate-crl \
              --template "${pkgs.writeText "taskserver-crl.template" ''
                expiration_days = ${toString cfg.pki.auto.expiration.crl}
              ''}" \
              --load-ca-privkey "${cfg.dataDir}/keys/ca.key" \
              --load-ca-certificate "${cfg.dataDir}/keys/ca.cert" \
              --outfile "${cfg.dataDir}/keys/server.crl"

            chgrp "${cfg.group}" "${cfg.dataDir}/keys/server.crl"
            chmod g+r "${cfg.dataDir}/keys/server.crl"
          fi

          chmod go+x "${cfg.dataDir}/keys"
        '';

        serviceConfig.PrivateNetwork = true;
        serviceConfig.PrivateTmp = true;
        serviceConfig.Type = "oneshot";
        serviceConfig.UMask = "0077";
        wantedBy = [ "taskserver.service" ];
      };
    })
    (lib.mkIf (cfg.enable && cfg.openFirewall) {
      networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    })
  ];

  meta.doc = ./default.md;
}
