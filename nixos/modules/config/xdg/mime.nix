{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.xdg.mime;
  associationOptions =
    with lib.types;
    attrsOf (coercedTo (either (listOf str) str) (x: lib.concatStringsSep ";" (lib.toList x)) str);
in

{
  options = {
    xdg.mime.addedAssociations = lib.mkOption {
      default = { };

      description = ''
        Adds associations between mimetypes and applications. See the
        [specifications](https://specifications.freedesktop.org/mime-apps-spec/latest/associations) for more information.
        Globs in all variations are supported.
      '';

      example = {
        "application/pdf" = "firefox.desktop";

        "text/*" = [
          "nvim.desktop"
          "codium.desktop"
        ];
      };

      type = associationOptions;
    };

    xdg.mime.defaultApplications = lib.mkOption {
      default = { };

      description = ''
        Sets the default applications for given mimetypes. See the
        [specifications](https://specifications.freedesktop.org/mime-apps-spec/latest/default) for more information.
        Globs in all variations are supported.
      '';

      example = {
        "application/pdf" = "firefox.desktop";

        "image/*" = [
          "sxiv.desktop"
          "gimp.desktop"
        ];
      };

      type = associationOptions;
    };

    xdg.mime.enable = lib.mkOption {
      default = true;

      description = ''
        Whether to install files to support the
        [XDG Shared MIME-info specification](https://specifications.freedesktop.org/shared-mime-info-spec/latest) and the
        [XDG MIME Applications specification](https://specifications.freedesktop.org/mime-apps-spec/latest).
      '';

      type = lib.types.bool;
    };

    xdg.mime.removedAssociations = lib.mkOption {
      default = { };

      description = ''
        Removes associations between mimetypes and applications. See the
        [specifications](https://specifications.freedesktop.org/mime-apps-spec/latest/associations) for more information.
        Globs in all variations are supported.
      '';

      example = {
        "audio/*" = [
          "mpv.desktop"
          "umpv.desktop"
        ];

        "inode/directory" = "codium.desktop";
      };

      type = associationOptions;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."xdg/mimeapps.list" =
      let
        generateMimeScript =
          title: attrs:
          lib.optionalString (attrs != { }) ''
            echo "[${title}]" >> $out
          ''
          + (lib.concatStringsSep "\n" (
            lib.attrValues (
              lib.mapAttrs (
                k: v: ''generateMimeItem "${k}" "${if lib.isList v then lib.concatStringsSep ";" v else v}"''
              ) attrs
            )
          ));
      in
      lib.mkIf
        (cfg.addedAssociations != { } || cfg.defaultApplications != { } || cfg.removedAssociations != { })
        {
          source = pkgs.runCommandLocal "mimeapps.list" { } ''
            function generateMimeItem() {
              mime=$1
              app=$2
              if [[ $mime == *"*"* ]]; then
                while read line; do
                  if [[ $line == $mime ]]; then
                    echo "$line=$app" >> $out
                  fi
                done < ${pkgs.shared-mime-info}/share/mime/types
              else
                echo "$mime=$app" >> $out
              fi
            }
            ${lib.concatStringsSep "\n" (
              lib.attrValues (
                lib.mapAttrs generateMimeScript {
                  "Added Associations" = cfg.addedAssociations;
                  "Default Applications" = cfg.defaultApplications;
                  "Removed Associations" = cfg.removedAssociations;
                }
              )
            )}
          '';
        };

    environment.extraSetup = ''
      if [ -w $out/share/mime ] && [ -d $out/share/mime/packages ]; then
          XDG_DATA_DIRS=$out/share PKGSYSTEM_ENABLE_FSYNC=0 ${pkgs.buildPackages.shared-mime-info}/bin/update-mime-database -V $out/share/mime > /dev/null
      fi

      if [ -w $out/share/applications ]; then
          ${pkgs.buildPackages.desktop-file-utils}/bin/update-desktop-database $out/share/applications
      fi
    '';

    environment.pathsToLink = [ "/share/mime" ];

    environment.systemPackages = [
      # this package also installs some useful data, as well as its utilities
      pkgs.shared-mime-info
    ];
  };

  meta = {
    teams = [ lib.teams.freedesktop ];
  };

}
