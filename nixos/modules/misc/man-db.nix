{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.documentation.man.man-db;
  cfgm = config.documentation.man;
in

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "documentation" "man" "manualPages" ]
      [ "documentation" "man" "man-db" "manualPages" ]
    )
  ];

  options = {
    documentation.man.man-db = {
      enable = lib.mkEnableOption "man-db as the default man page viewer" // {
        default = cfgm.enable;
        defaultText = lib.literalExpression "config.documentation.man.enable";
        example = false;
      };

      package = lib.mkOption {
        default = pkgs.man-db;
        defaultText = lib.literalExpression "pkgs.man-db";

        description = ''
          The `man-db` derivation to use. Useful to override
          configuration options used for the package.
        '';

        type = lib.types.package;
      };

      manualPages = lib.mkOption {
        default = pkgs.buildEnv {
          extraOutputsToInstall = [ "man" ] ++ lib.optionals config.documentation.dev.enable [ "devman" ];
          ignoreCollisions = true;
          name = "man-paths";
          paths = lib.subtractLists cfg.skipPackages config.environment.systemPackages;
          pathsToLink = [ "/share/man" ];
        };

        defaultText = lib.literalMD "all man pages in {option}`config.environment.systemPackages`";

        description = ''
          The manual pages to generate caches for if {option}`documentation.man.cache.enable`
          is enabled. Must be a path to a directory with man pages under
          `/share/man`; see the source for an example.
          Advanced users can make this a content-addressed derivation to save a few rebuilds.
        '';

        type = lib.types.path;
      };

      skipPackages = lib.mkOption {
        default = [ ];

        description = ''
          Packages to *not* include in the man-db.
          This can be useful to avoid unnecessary rebuilds due to packages that change frequently, like nixos-version.
        '';

        internal = true;
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.etc."man_db.conf".text =
          let
            # We unfortunately can’t use the customized `cfg.package` when
            # cross‐compiling. Instead we detect that situation and work
            # around it by using the vanilla one, like the OpenSSH module.
            buildPackage =
              if pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform then
                cfg.package
              else
                pkgs.buildPackages.man-db;

            manualCache =
              if (!cfgm.cache.generateAtRuntime) then
                pkgs.runCommand "man-cache"
                  {
                    nativeBuildInputs = [ buildPackage ];
                    preferLocalBuild = true;
                  }
                  ''
                    echo "MANDB_MAP ${cfg.manualPages}/share/man $out" > man.conf
                    mandb -C man.conf -pscq
                  ''
              else
                "/var/cache/man/nixos-mandb";
          in
          ''
            # Manual pages paths for NixOS
            MANPATH_MAP /run/current-system/sw/bin /run/current-system/sw/share/man
            MANPATH_MAP /run/wrappers/bin          /run/current-system/sw/share/man

            ${lib.optionalString cfgm.cache.enable ''
              # Manual pages caches for NixOS
              MANDB_MAP /run/current-system/sw/share/man ${manualCache}
            ''}
          '';

        environment.systemPackages = [ cfg.package ];
      }

      (lib.mkIf (cfgm.enable && cfgm.cache.generateAtRuntime) {
        systemd.services.mandb = {
          path = [
            cfg.package
            pkgs.rsync
          ];

          script = ''
            rsync \
              --checksum --recursive --copy-links --delete --no-times --no-perms --chmod=+w \
              ${cfg.manualPages}/share/man/ "$CACHE_DIRECTORY/nixos-manpages"

            echo "MANDB_MAP $CACHE_DIRECTORY/nixos-manpages $CACHE_DIRECTORY/nixos-mandb" \
              > "$RUNTIME_DIRECTORY/man.conf"

            mandb -C "$RUNTIME_DIRECTORY/man.conf" -q
          '';

          serviceConfig = {
            BindReadOnlyPaths = [ "/dev/null:/etc/man_db.conf" ]; # mandb will still read /etc/man_db.conf if it exists, even when setting -C path/to/config.conf
            CacheDirectory = "man";
            ProtectSystem = "strict";
            RuntimeDirectory = "mandb";
            User = "mandb";
          };

          wantedBy = [ "multi-user.target" ];
        };

        users.groups.mandb = { };

        users.users.mandb = {
          group = "mandb";
          isSystemUser = true;
        };
      })
    ]
  );
}
