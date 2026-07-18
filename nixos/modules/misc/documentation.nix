{
  config,
  lib,
  pkgs,
  options,
  modulesPath,
  utils,
  baseModules,
  extraModules,
  modules,
  specialArgs,
  ...
}:

let
  inherit (lib)
    cleanSourceFilter
    concatMapStringsSep
    evalModules
    functionArgs
    hasSuffix
    isAttrs
    isDerivation
    isFunction
    isPath
    literalExpression
    mapAttrs
    mkIf
    mkMerge
    mkOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optional
    optionalAttrs
    optionals
    partition
    removePrefix
    types
    warn
    ;

  cfg = config.documentation;
  allOpts = options;

  canCacheDocs =
    m:
    let
      f = import m;
      instance = f (mapAttrs (n: _: abort "evaluating ${n} for `meta` failed") (functionArgs f));
    in
    cfg.nixos.options.splitBuild
    && isPath m
    && isFunction f
    && instance ? options
    && instance.meta.buildDocsInSandbox or true;

  docModules =
    let
      p = partition canCacheDocs (baseModules ++ cfg.nixos.extraModules);
    in
    {
      eager = p.wrong ++ optionals cfg.nixos.includeAllModules (extraModules ++ modules);
      lazy = p.right;
    };

  manual = import ../../doc/manual rec {
    inherit pkgs config;
    inherit (cfg.nixos.options) warningsAreErrors;

    options =
      let
        scrubbedEval = evalModules {
          class = "nixos";

          modules = [
            {
              _module.check = false;
            }
          ]
          ++ docModules.eager;

          specialArgs = specialArgs // {
            inherit modulesPath utils;
            # allow access to arbitrary options for eager modules, eg for getting
            # option types from lazy modules
            options = allOpts;
            pkgs = scrubDerivations "pkgs" pkgs;
          };
        };
        scrubDerivations =
          namePrefix: pkgSet:
          mapAttrs (
            name: value:
            let
              wholeName = "${namePrefix}.${name}";
              guard = warn "Attempt to evaluate package ${wholeName} in option documentation; this is not supported and will eventually be an error. Use `mkPackageOption{,MD}` or `literalExpression` instead.";
            in
            if isAttrs value then
              scrubDerivations wholeName value
              // optionalAttrs (isDerivation value) {
                drvPath = guard value.drvPath;
                outPath = guard "\${${wholeName}}";
              }
            else
              value
          ) pkgSet;
      in
      scrubbedEval.options;

    baseOptionsJSON =
      let
        filter = builtins.filterSource (
          n: t:
          cleanSourceFilter n t
          && (t == "directory" -> baseNameOf n != "tests")
          && (t == "file" -> hasSuffix ".nix" n)
        );
        prefixRegex =
          "^"
          + lib.strings.escapeRegex (toString pkgs.path)
          + "($|/(modules|nixos|lib/services)($|/.*)|/lib)";
        filteredModules = builtins.path {
          inherit (pkgs) path;

          filter =
            n: t:
            builtins.match prefixRegex n != null
            && cleanSourceFilter n t
            && (t == "directory" -> baseNameOf n != "tests")
            && (t == "file" -> hasSuffix ".nix" n);

          name = "source";
        };
      in
      pkgs.runCommand "lazy-options.json"
        rec {
          __structuredAttrs = true;

          disallowedReferences = [
            filteredModules
            libPath
            pkgsLibPath
          ];

          env.NIX_ABORT_ON_WARN = warningsAreErrors;
          libPath = filter (pkgs.path + "/lib");

          modules =
            "[ "
            + concatMapStringsSep " " (p: ''"${removePrefix "${modulesPath}/" (toString p)}"'') docModules.lazy
            + " ]";

          nixosPath = filteredModules + "/nixos";
          pkgsLibPath = filter (pkgs.path + "/pkgs/pkgs-lib");
        }
        ''
          modulesPath="$TMPDIR/modules"
          printf "%s" "$modules" > "$modulesPath"
          export NIX_STORE_DIR=$TMPDIR/store
          export NIX_STATE_DIR=$TMPDIR/state
          ${pkgs.buildPackages.nix}/bin/nix-instantiate \
            --show-trace \
            --eval --json --strict \
            --argstr libPath "$libPath" \
            --argstr pkgsLibPath "$pkgsLibPath" \
            --argstr nixosPath "$nixosPath" \
            --arg modules "import $modulesPath" \
            --argstr stateVersion "${options.system.stateVersion.default}" \
            --argstr release "${config.system.nixos.release}" \
            $nixosPath/lib/eval-cacheable-options.nix > $out \
            || {
              echo -en "\e[1;31m"
              echo 'Cacheable portion of option doc build failed.'
              echo 'Usually this means that an option attribute that ends up in documentation (eg' \
                '`default` or `description`) depends on the restricted module arguments' \
                '`config` or `pkgs`.'
              echo
              echo 'Rebuild your configuration with `--show-trace` to find the offending' \
                'location. Remove the references to restricted arguments (eg by escaping' \
                'their antiquotations or adding a `defaultText`) or disable the sandboxed' \
                'build for the failing module by setting `meta.buildDocsInSandbox = false`.'
              echo -en "\e[0m"
              exit 1
            } >&2
        '';

    checkRedirects = cfg.nixos.checkRedirects;
    extraSources = cfg.nixos.extraModuleSources;
    revision = "release-${version}";
    version = config.system.nixos.release;
  };

  nixos-help =
    let
      helpScript = pkgs.writeShellScriptBin "nixos-help" ''
        # Finds first executable browser in a colon-separated list.
        # (see how xdg-open defines BROWSER)
        browser="$(
          IFS=: ; for b in $BROWSER; do
            [ -n "$(type -P "$b" || true)" ] && echo "$b" && break
          done
        )"
        if [ -z "$browser" ]; then
          browser="$(type -P xdg-open || true)"
          if [ -z "$browser" ]; then
            browser="${pkgs.w3m-nographics}/bin/w3m"
          fi
        fi
        exec "$browser" ${manual.manualHTMLIndex}
      '';

      desktopItem = pkgs.makeDesktopItem {
        categories = [ "System" ];
        comment = "View NixOS documentation in a web browser";
        desktopName = "NixOS Manual";
        exec = "nixos-help";
        genericName = "System Manual";
        icon = "nix-snowflake";
        name = "nixos-manual";
      };

    in
    pkgs.symlinkJoin {
      name = "nixos-help";

      paths = [
        helpScript
        desktopItem
      ];
    };

in

{
  imports = [
    ./man-db.nix
    ./mandoc.nix
    ./assertions.nix
    ./meta.nix
    ../config/system-path.nix
    ../system/etc/etc.nix
    (mkRenamedOptionModule [ "programs" "info" "enable" ] [ "documentation" "info" "enable" ])
    (mkRenamedOptionModule [ "programs" "man" "enable" ] [ "documentation" "man" "enable" ])
    (mkRenamedOptionModule [ "services" "nixosManual" "enable" ] [ "documentation" "nixos" "enable" ])
    (mkRenamedOptionModule
      [ "documentation" "man" "generateCaches" ]
      [ "documentation" "man" "cache" "enable" ]
    )
    (mkRemovedOptionModule [
      "documentation"
      "nixos"
      "options"
      "allowDocBook"
    ] "DocBook option documentation is no longer supported")
  ];

  options = {

    documentation = {

      enable = mkOption {
        default = true;

        description = ''
          Whether to install documentation of packages from
          {option}`environment.systemPackages` into the generated system path.

          See "Multiple-output packages" chapter in the nixpkgs manual for more info.
        '';

        type = types.bool;
        # which is at ../../../doc/multiple-output.chapter.md
      };

      dev.enable = mkOption {
        default = false;

        description = ''
          Whether to install documentation targeted at developers.
          * This includes man pages targeted at developers if {option}`documentation.man.enable` is
            set (this also includes "devman" outputs).
          * This includes info pages targeted at developers if {option}`documentation.info.enable`
            is set (this also includes "devinfo" outputs).
          * This includes other pages targeted at developers if {option}`documentation.doc.enable`
            is set (this also includes "devdoc" outputs).
        '';

        type = types.bool;
      };

      doc.enable = mkOption {
        default = true;

        description = ''
          Whether to install documentation distributed in packages' `/share/doc`.
          Usually plain text and/or HTML.
          This also includes "doc" outputs.
        '';

        type = types.bool;
      };

      info.enable = mkOption {
        default = true;

        description = ''
          Whether to install info pages and the {command}`info` command.
          This also includes "info" outputs.
        '';

        type = types.bool;
      };

      man.cache.enable = mkOption {
        default = false;

        description = ''
          Whether to generate the manual page index caches.
          This allows searching for a page or
          keyword using utilities like {manpage}`apropos(1)`
          and the `-k` option of
          {manpage}`man(1)`.
        '';

        type = types.bool;
      };

      man.cache.generateAtRuntime = mkOption {
        default = false;

        description = ''
          Whether to generate the manual page index caches at runtime using
          a systemd service.

          ::: {.note}
          This is currently only supported by the man-db module.
          :::
        '';

        type = types.bool;
      };

      man.enable = mkOption {
        default = true;

        description = ''
          Whether to install manual pages.
          This also includes `man` outputs.
        '';

        type = types.bool;
      };

      nixos.checkRedirects = mkOption {
        default = true;

        description = ''
          Check redirects for manualHTML.
        '';

        type = types.bool;
      };

      nixos.enable = mkOption {
        default = true;

        description = ''
          Whether to install NixOS's own documentation.

          - This includes man pages like
            {manpage}`configuration.nix(5)` if {option}`documentation.man.enable` is
            set.
          - This includes the HTML manual and the {command}`nixos-help` command if
            {option}`documentation.doc.enable` is set.
        '';

        type = types.bool;
      };

      nixos.extraModuleSources = mkOption {
        default = [ ];

        description = ''
          Which extra NixOS module paths the generated NixOS's documentation should strip
          from options.
        '';

        example = literalExpression ''
          # e.g. with options from modules in ''${pkgs.customModules}/nix:
          [ pkgs.customModules ]
        '';

        type = types.listOf (types.either types.path types.str);
      };

      nixos.extraModules = mkOption {
        default = [ ];

        description = ''
          Modules for which to show options even when not imported.
        '';

        type = types.listOf types.raw;
      };

      nixos.includeAllModules = mkOption {
        default = false;

        description = ''
          Whether the generated NixOS's documentation should include documentation for all
          the options from all the NixOS modules included in the current
          `configuration.nix`. Disabling this will make the manual
          generator to ignore options defined outside of `baseModules`.
        '';

        type = types.bool;
      };

      nixos.options.splitBuild = mkOption {
        default = true;

        description = ''
          Whether to split the option docs build into a cacheable and an uncacheable part.
          Splitting the build can substantially decrease the amount of time needed to build
          the manual, but some user modules may be incompatible with this splitting.
        '';

        type = types.bool;
      };

      nixos.options.warningsAreErrors = mkOption {
        default = true;

        description = ''
          Treat warning emitted during the option documentation build (eg for missing option
          descriptions) as errors.
        '';

        type = types.bool;
      };

    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.man.man-db.enable && cfg.man.mandoc.enable);

          message = ''
            man-db and mandoc can't be used as the default man page viewer at the same time!
          '';
        }
      ];
    }

    # The actual implementation for this lives in man-db.nix or mandoc.nix,
    # depending on which backend is active.
    (mkIf cfg.man.enable {
      environment.extraOutputsToInstall = [ "man" ] ++ optional cfg.dev.enable "devman";
      environment.pathsToLink = [ "/share/man" ];
    })

    (mkIf cfg.info.enable {
      environment.extraOutputsToInstall = [ "info" ] ++ optional cfg.dev.enable "devinfo";

      environment.extraSetup = ''
        if [ -w $out/share/info ]; then
          shopt -s nullglob
          for i in $out/share/info/*.info $out/share/info/*.info.gz; do
              ${pkgs.buildPackages.texinfo}/bin/install-info $i $out/share/info/dir
          done
        fi
      '';

      environment.pathsToLink = [ "/share/info" ];
      environment.systemPackages = [ pkgs.texinfoInteractive ];
    })

    (mkIf cfg.doc.enable {
      environment.extraOutputsToInstall = [ "doc" ] ++ optional cfg.dev.enable "devdoc";

      environment.pathsToLink = [
        "/share/doc"

        # Legacy paths used by gtk-doc & adjacent tools.
        "/share/gtk-doc"
        "/share/devhelp"
      ];
    })

    (mkIf cfg.nixos.enable {
      environment.systemPackages =
        [ ]
        ++ optional cfg.man.enable manual.nixos-configuration-reference-manpage
        ++ optionals cfg.doc.enable [
          manual.manualHTML
          nixos-help
        ];

      system.build.manual = manual;
    })

  ]);

}
