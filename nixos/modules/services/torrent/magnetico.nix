{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.magnetico;

  dataDir = "/var/lib/magnetico";

  credFile =
    with cfg.web;
    if credentialsFile != null then
      credentialsFile
    else
      pkgs.writeText "magnetico-credentials" (
        lib.concatStrings (lib.mapAttrsToList (user: hash: "${user}:${hash}\n") cfg.web.credentials)
      );

  # default options in magneticod/main.go
  dbURI = lib.concatStrings [
    "sqlite3://${dataDir}/database.sqlite3"
    "?_journal_mode=WAL"
    "&_busy_timeout=3000"
    "&_foreign_keys=true"
  ];

  crawlerArgs =
    with cfg.crawler;
    lib.escapeShellArgs (
      [
        "--database=${dbURI}"
        "--indexer-addr=${address}:${toString port}"
        "--indexer-max-neighbors=${toString maxNeighbors}"
        "--leech-max-n=${toString maxLeeches}"
      ]
      ++ extraOptions
    );

  webArgs =
    with cfg.web;
    lib.escapeShellArgs (
      [
        "--database=${dbURI}"
        (
          if (cfg.web.credentialsFile != null || cfg.web.credentials != { }) then
            "--credentials=${toString credFile}"
          else
            "--no-auth"
        )
        "--addr=${address}:${toString port}"
      ]
      ++ extraOptions
    );

in
{

  ###### interface

  options.services.magnetico = {
    enable = lib.mkEnableOption "Magnetico, Bittorrent DHT crawler";

    crawler.address = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        Address to be used for indexing DHT nodes.
      '';

      example = "1.2.3.4";
      type = lib.types.str;
    };

    crawler.extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to pass to magneticod.
      '';

      type = lib.types.listOf lib.types.str;
    };

    crawler.maxLeeches = lib.mkOption {
      default = 200;

      description = ''
        Maximum number of simultaneous leeches.
      '';

      type = lib.types.ints.positive;
    };

    crawler.maxNeighbors = lib.mkOption {
      default = 1000;

      description = ''
        Maximum number of simultaneous neighbors of an indexer.
        Be careful changing this number: high values can very
        easily cause your network to be congested or even crash
        your router.
      '';

      type = lib.types.ints.positive;
    };

    crawler.port = lib.mkOption {
      default = 0;

      description = ''
        Port to be used for indexing DHT nodes.
        This port should be added to
        {option}`networking.firewall.allowedTCPPorts`.
      '';

      type = lib.types.port;
    };

    web.address = lib.mkOption {
      default = "localhost";

      description = ''
        Address the web interface will listen to.
      '';

      example = "1.2.3.4";
      type = lib.types.str;
    };

    web.credentials = lib.mkOption {
      default = { };

      description = ''
        The credentials to access the web interface, in case authentication is
        enabled, in the format `username:hash`. If unset no
        authentication will be required.

        Usernames must start with a lowercase ([a-z]) ASCII character, might
        contain non-consecutive underscores except at the end, and consists of
        small-case a-z characters and digits 0-9.  The
        {command}`htpasswd` tool from the `apacheHttpd`
        package may be used to generate the hash:
        {command}`htpasswd -bnBC 12 username password`

        ::: {.warning}
        The hashes will be stored world-readable in the nix store.
        Consider using the `credentialsFile` option if you
        don't want this.
        :::
      '';

      example = lib.literalExpression ''
        {
          myuser = "$2y$12$YE01LZ8jrbQbx6c0s2hdZO71dSjn2p/O9XsYJpz.5968yCysUgiaG";
        }
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    web.credentialsFile = lib.mkOption {
      default = null;

      description = ''
        The path to the file holding the credentials to access the web
        interface. If unset no authentication will be required.

        The file must contain user names and password hashes in the format
        `username:hash`, one for each line.  Usernames must
        start with a lowecase ([a-z]) ASCII character, might contain
        non-consecutive underscores except at the end, and consists of
        small-case a-z characters and digits 0-9.
        The {command}`htpasswd` tool from the `apacheHttpd`
        package may be used to generate the hash:
        {command}`htpasswd -bnBC 12 username password`
      '';

      type = lib.types.nullOr lib.types.path;
    };

    web.extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to pass to magneticow.
      '';

      type = lib.types.listOf lib.types.str;
    };

    web.port = lib.mkOption {
      default = 8080;

      description = ''
        Port the web interface will listen to.
      '';

      type = lib.types.port;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.web.credentialsFile == null || cfg.web.credentials == { };

        message = ''
          The options services.magnetico.web.credentialsFile and
          services.magnetico.web.credentials are mutually exclusives.
        '';
      }
    ];

    systemd.services.magneticod = {
      after = [ "network.target" ];
      description = "Magnetico DHT crawler";

      serviceConfig = {
        ExecStart = "${pkgs.magnetico}/bin/magneticod ${crawlerArgs}";
        Restart = "on-failure";
        User = "magnetico";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.magneticow = {
      after = [
        "network.target"
        "magneticod.service"
      ];

      description = "Magnetico web interface";

      serviceConfig = {
        ExecStart = "${pkgs.magnetico}/bin/magneticow ${webArgs}";
        Restart = "on-failure";
        StateDirectory = "magnetico";
        User = "magnetico";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.magnetico = { };

    users.users.magnetico = {
      description = "Magnetico daemons user";
      group = "magnetico";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
