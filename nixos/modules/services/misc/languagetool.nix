{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.languagetool;
  settingsFormat = pkgs.formats.javaProperties { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "languagetool"
      "jrePackage"
    ] "The jre is now always taken from the package's jre attribute.")
  ];

  options.services.languagetool = {
    enable = lib.mkEnableOption "the LanguageTool server, a multilingual spelling, style, and grammar checker that helps correct or paraphrase texts";
    package = lib.mkPackageOption pkgs "languagetool" { };

    allowOrigin = lib.mkOption {
      default = null;

      description = ''
        Set the Access-Control-Allow-Origin header in the HTTP response,
        used for direct (non-proxy) JavaScript-based access from browsers.
        `"*"` to allow access from all sites.
      '';

      example = "https://my-website.org";
      type = lib.types.nullOr lib.types.str;
    };

    jvmOptions = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line options for the JVM running languagetool.
        More information can be found here: <https://docs.oracle.com/en/java/javase/19/docs/specs/man/java.html#standard-options-for-java>
      '';

      example = [
        "-Xmx512m"
      ];

      type = lib.types.listOf lib.types.str;
    };

    port = lib.mkOption {
      default = 8081;

      description = ''
        Port on which LanguageTool listens.
      '';

      example = 8081;
      type = lib.types.port;
    };

    public = lib.mkEnableOption "access from anywhere (rather than just localhost)";

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration file options for LanguageTool, see
        'languagetool-http-server --help'
        for supported settings.
      '';

      type = lib.types.submodule {
        options.cacheSize = lib.mkOption {
          apply = toString;
          default = 1000;
          description = "Number of sentences cached.";
          type = lib.types.ints.unsigned;
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.languagetool = {
      after = [ "network.target" ];
      description = "LanguageTool HTTP server";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;

        ExecStart = ''
          ${lib.getExe cfg.package.jre} \
            -cp ${cfg.package}/share/languagetool-server.jar \
            ${toString cfg.jvmOptions} \
            org.languagetool.server.HTTPServer \
              --port ${toString cfg.port} \
              ${lib.optionalString cfg.public "--public"} \
              ${lib.optionalString (cfg.allowOrigin != null) "--allow-origin ${cfg.allowOrigin}"} \
              "--config" ${settingsFormat.generate "languagetool.conf" cfg.settings}
        '';

        Group = "languagetool";
        ProtectHome = "yes";
        Restart = "on-failure";
        RestrictNamespaces = [ "" ];

        SystemCallFilter = [
          "@system-service"
          "~ @privileged"
        ];

        User = "languagetool";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
