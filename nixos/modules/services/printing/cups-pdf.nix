{
  config,
  lib,
  pkgs,
  ...
}:

let

  # cups calls its backends as user `lp` (which is good!),
  # but cups-pdf wants to be called as `root`, so it can change ownership of files.
  # We add a suid wrapper and a wrapper script to trick cups into calling the suid wrapper.
  # Note that a symlink to the suid wrapper alone wouldn't suffice, cups would complain
  # > File "/nix/store/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-cups-progs/lib/cups/backend/cups-pdf" has insecure permissions (0104554/uid=0/gid=20)

  # wrapper script that redirects calls to the suid wrapper
  cups-pdf-wrapper = pkgs.writeTextFile {
    checkPhase = ''
      ${pkgs.stdenv.shellDryRun} "$target"
      ${lib.getExe pkgs.shellcheck} "$target"
    '';

    destination = "/lib/cups/backend/cups-pdf";
    executable = true;
    name = "${pkgs.cups-pdf-to-pdf.name}-wrapper.sh";

    text = ''
      #! ${pkgs.runtimeShell}
      exec "${config.security.wrapperDir}/cups-pdf" "$@"
    '';
  };

  # wrapped cups-pdf package that uses the suid wrapper
  cups-pdf-wrapped = pkgs.buildEnv {
    ignoreCollisions = true;
    name = "${pkgs.cups-pdf-to-pdf.name}-wrapped";

    # using the wrapper as first path ensures it is used
    paths = [
      cups-pdf-wrapper
      pkgs.cups-pdf-to-pdf
    ];
  };

  instanceSettings = name: {
    options.AnonDirName = lib.mkOption {
      default = "/var/spool/cups-pdf-${name}/anonymous";
      defaultText = "/var/spool/cups-pdf-{instance-name}/anonymous";
      description = "path for anonymously created PDF files";
      example = "/var/lib/cups-pdf";
      type = with lib.types; nullOr singleLineStr;
    };

    options.Anonuser = lib.mkOption {
      default = "root";

      description = ''
        User for anonymous PDF creation.
        An empty string disables this feature.
      '';

      type = lib.types.singleLineStr;
    };

    options.GhostScript = lib.mkOption {
      default = lib.getExe pkgs.ghostscript;
      defaultText = lib.literalExpression "lib.getExe pkgs.ghostscript";
      description = "location of GhostScript binary";
      example = lib.literalExpression "\${pkgs.ghostscript}/bin/ps2pdf";
      type = with lib.types; nullOr path;
    };

    # override defaults:
    # inject instance name into paths,
    # also avoid conflicts between user names and special dirs
    options.Out = lib.mkOption {
      default = "/var/spool/cups-pdf-${name}/users/\${USER}";
      defaultText = "/var/spool/cups-pdf-{instance-name}/users/\${USER}";

      description = ''
        output directory;
        `''${HOME}` will be expanded to the user's home directory,
        `''${USER}` will be expanded to the user name.
      '';

      example = "\${HOME}/cups-pdf";
      type = with lib.types; nullOr singleLineStr;
    };

    options.Spool = lib.mkOption {
      default = "/var/spool/cups-pdf-${name}/spool";
      defaultText = "/var/spool/cups-pdf-{instance-name}/spool";
      description = "spool directory";
      example = "/var/lib/cups-pdf";
      type = with lib.types; nullOr singleLineStr;
    };

    freeformType =
      with lib.types;
      attrsOf (
        nullOr (oneOf [
          int
          str
          path
          package
        ])
      );
  };

  instanceConfig =
    { config, name, ... }:
    {
      options = {
        enable = (lib.mkEnableOption "this cups-pdf instance") // {
          default = true;
        };

        confFileText = lib.mkOption {
          description = ''
            This will contain the contents of {file}`cups-pdf.conf` for this instance, derived from {option}`settings`.
            You can use this option to append text to the file.
          '';

          type = lib.types.lines;
        };

        installPrinter =
          (lib.mkEnableOption ''
            a CUPS printer queue for this instance.
            The queue will be named after the instance and will use the {file}`CUPS-PDF_opt.ppd` ppd file.
            If this is disabled, you need to add the queue yourself to use the instance
          '')
          // {
            default = true;
          };

        settings = lib.mkOption {
          default = { };

          description = ''
            Settings for a cups-pdf instance, see the descriptions in the template config file in the cups-pdf package.
            The key value pairs declared here will be translated into proper key value pairs for {file}`cups-pdf.conf`.
            Setting a value to `null` disables the option and removes it from the file.
          '';

          example = {
            Out = "\${HOME}/cups-pdf";
            UserUMask = "0033";
          };

          type = lib.types.submodule (instanceSettings name);
        };
      };

      config.confFileText = lib.pipe config.settings [
        (lib.filterAttrs (key: value: value != null))
        (lib.mapAttrs (key: toString))
        (lib.mapAttrsToList (key: value: "${key} ${value}\n"))
        lib.concatStrings
      ];
    };

  cupsPdfCfg = config.services.printing.cups-pdf;

  copyConfigFileCmds = lib.pipe cupsPdfCfg.instances [
    (lib.filterAttrs (name: lib.getAttr "enable"))
    (lib.mapAttrs (name: lib.getAttr "confFileText"))
    (lib.mapAttrs (name: pkgs.writeText "cups-pdf-${name}.conf"))
    (lib.mapAttrsToList (
      name: confFile:
      "ln --symbolic --no-target-directory ${confFile} /var/lib/cups/cups-pdf-${name}.conf\n"
    ))
    lib.concatStrings
  ];

  printerSettings = lib.pipe cupsPdfCfg.instances [
    (lib.filterAttrs (name: lib.getAttr "enable"))
    (lib.filterAttrs (name: lib.getAttr "installPrinter"))
    (lib.mapAttrsToList (
      name: instance:
      (lib.mapAttrs (key: lib.mkDefault) {
        inherit name;
        description = "virtual printer for cups-pdf instance ${name}";
        deviceUri = "cups-pdf:/${name}";
        location = instance.settings.Out;
        model = "CUPS-PDF_opt.ppd";
      })
    ))
  ];

in

{

  options.services.printing.cups-pdf = {
    enable = lib.mkEnableOption ''
      the cups-pdf virtual pdf printer backend.
      By default, this will install a single printer `pdf`.
      but this can be changed/extended with {option}`services.printing.cups-pdf.instances`
    '';

    instances = lib.mkOption {
      default.pdf = { };

      description = ''
        Permits to raise one or more cups-pdf instances.
        Each instance is named by an attribute name, and the attribute's values control the instance' configuration.
      '';

      example.pdf.settings = {
        Out = "\${HOME}/cups-pdf";
        UserUMask = "0033";
      };

      type = lib.types.attrsOf (lib.types.submodule instanceConfig);
    };
  };

  config = lib.mkIf cupsPdfCfg.enable {
    hardware.printers.ensurePrinters = printerSettings;

    security.wrappers.cups-pdf = {
      group = "lp";
      owner = "root";
      permissions = "+r,ug+x";
      setuid = true;
      source = "${pkgs.cups-pdf-to-pdf}/lib/cups/backend/cups-pdf";
    };

    services.printing.drivers = [ cups-pdf-wrapped ];
    services.printing.enable = true;

    # the cups module will install the default config file,
    # but we don't need it and it would confuse cups-pdf
    systemd.services.cups.preStart = lib.mkAfter ''
      rm -f /var/lib/cups/cups-pdf.conf
      ${copyConfigFileCmds}
    '';
  };

  meta.maintainers = [ lib.maintainers.yarny ];

}
