{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sks;
  sksPkg = cfg.package;
  dbConfig = pkgs.writeText "DB_CONFIG" ''
    ${cfg.extraDbConfig}
  '';

in
{
  options = {

    services.sks = {

      enable = lib.mkEnableOption ''
        SKS (synchronizing key server for OpenPGP) and start the database
        server. You need to create "''${dataDir}/dump/*.gpg" for the initial
        import'';

      package = lib.mkPackageOption pkgs "sks" { };

      dataDir = lib.mkOption {
        default = "/var/db/sks";

        # TODO: The default might change to "/var/lib/sks" as this is more
        # common. There's also https://github.com/NixOS/nixpkgs/issues/26256
        # and "/var/db" is not FHS compliant (seems to come from BSD).
        description = ''
          Data directory (-basedir) for SKS, where the database and all
          configuration files are located (e.g. KDB, PTree, membership and
          sksconf).
        '';

        example = "/var/lib/sks";
        type = lib.types.path;
      };

      extraDbConfig = lib.mkOption {
        default = "";

        description = ''
          Set contents of the files "KDB/DB_CONFIG" and "PTree/DB_CONFIG" within
          the ''${dataDir} directory. This is used to configure options for the
          database for the sks key server.

          Documentation of available options are available in the file named
          "sampleConfig/DB_CONFIG" in the following repository:
          https://bitbucket.org/skskeyserver/sks-keyserver/src
        '';

        type = lib.types.str;
      };

      hkpAddress = lib.mkOption {
        default = [
          "127.0.0.1"
          "::1"
        ];

        description = ''
          Domain names, IPv4 and/or IPv6 addresses to listen on for HKP
          requests.
        '';

        type = lib.types.listOf lib.types.str;
      };

      hkpPort = lib.mkOption {
        default = 11371;
        description = "HKP port to listen on.";
        type = lib.types.ints.u16;
      };

      webroot = lib.mkOption {
        default = "${sksPkg.webSamples}/OpenPKG";
        defaultText = lib.literalExpression ''"''${package.webSamples}/OpenPKG"'';

        description = ''
          Source directory (will be symlinked, if not null) for the files the
          built-in webserver should serve. SKS (''${pkgs.sks.webSamples})
          provides the following examples: "HTML5", "OpenPKG", and "XHTML+ES".
          The index file can be named index.html, index.htm, index.xhtm, or
          index.xhtml. Files with the extensions .css, .es, .js, .jpg, .jpeg,
          .png, or .gif are supported. Subdirectories and filenames with
          anything other than alphanumeric characters and the '.' character
          will be ignored.
        '';

        type = lib.types.nullOr lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services =
      let
        hkpAddress = "'" + (builtins.concatStringsSep " " cfg.hkpAddress) + "'";
        hkpPort = toString cfg.hkpPort;
      in
      {
        sks-db = {
          after = [ "network.target" ];
          description = "SKS database server";
          documentation = [ "man:sks(8)" ];

          preStart = ''
            ${lib.optionalString (cfg.webroot != null) "ln -sfT \"${cfg.webroot}\" web"}
            mkdir -p dump
            ${sksPkg}/bin/sks build dump/*.gpg -n 10 -cache 100 || true #*/
            ${sksPkg}/bin/sks cleandb || true
            ${sksPkg}/bin/sks pbuild -cache 20 -ptree_cache 70 || true
            # Check that both database configs are symlinks before overwriting them
            # TODO: The initial build will be without DB_CONFIG, but this will
            # hopefully not cause any significant problems. It might be better to
            # create both directories manually but we have to check that this does
            # not affect the initial build of the DB.
            for CONFIG_FILE in KDB/DB_CONFIG PTree/DB_CONFIG; do
              if [ -e $CONFIG_FILE ] && [ ! -L $CONFIG_FILE ]; then
                echo "$CONFIG_FILE exists but is not a symlink." >&2
                echo "Please remove $PWD/$CONFIG_FILE manually to continue." >&2
                exit 1
              fi
              ln -sf ${dbConfig} $CONFIG_FILE
            done
          '';

          serviceConfig = {
            ExecStart = "${sksPkg}/bin/sks db -hkp_address ${hkpAddress} -hkp_port ${hkpPort}";
            Group = "sks";
            Restart = "always";
            User = "sks";
            WorkingDirectory = "~";
          };

          wantedBy = [ "multi-user.target" ];
        };
      };

    users = {
      groups.sks = { };

      users.sks = {
        createHome = true;
        description = "SKS user";
        group = "sks";
        home = cfg.dataDir;
        isSystemUser = true;

        packages = [
          sksPkg
          pkgs.db
        ];

        useDefaultShell = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    calbrecht
    jcumming
  ];
}
