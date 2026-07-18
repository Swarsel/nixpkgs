# This file defines the structure of the `config` nixpkgs option.

# This file is tested in `pkgs/test/config.nix`.
# Run tests with:
#
#     nix-build -A tests.config
#

{ lib, config, ... }:

let
  inherit (lib)
    literalExpression
    mapAttrsToList
    mkOption
    optionals
    types
    ;

  mkMassRebuild =
    args:
    mkOption (
      removeAttrs args [ "feature" ]
      // {
        default = args.default or false;

        description = (
          (args.description or ''
            Whether to ${args.feature} while building nixpkgs packages.
          ''
          )
          + ''
            Changing the default may cause a mass rebuild.
          ''
        );

        type = args.type or (types.uniq types.bool);
      }
    );

  options = {

    # Internal stuff
    # Hide built-in module system options from docs.
    _module.args = mkOption {
      internal = true;
    };

    allowAliases = mkOption {
      default = true;

      description = ''
        Whether to expose old attribute names for compatibility.

        The recommended setting is to enable this, as it
        improves backward compatibility, easing updates.

        The only reason to disable aliases is for continuous
        integration purposes. For instance, Nixpkgs should
        not depend on aliases in its internal code. Projects
        that aren't Nixpkgs should be cautious of instantly
        removing all usages of aliases, as migrating too soon
        can break compatibility with the stable Nixpkgs releases.
      '';

      type = types.bool;
    };

    allowBroken = mkOption {
      default = false;
      # getEnv part is in check-meta.nix
      defaultText = literalExpression ''false || builtins.getEnv "NIXPKGS_ALLOW_BROKEN" == "1"'';

      description = ''
        Whether to allow broken packages.

        See [Installing broken packages](https://nixos.org/manual/nixpkgs/stable/#sec-allow-broken) in the NixOS manual.
      '';

      type = types.bool;
    };

    allowDeprecatedx86_64Darwin = mkOption {
      default = false;

      description = ''
        Set to `"force"` to allow evaluating for the `x86_64-darwin`
        platform despite its deprecation in Nixpkgs 26.11.

        This is not expected to function, and Hydra will not build
        binaries for the platform. It is provided only as an escape
        hatch for custom setups, and comes with no support.

        See the [release notes](#x86_64-darwin-26.11) for more
        information.
      '';

      # `true` does nothing; it silenced the warning in 26.05.
      type = types.either types.bool (types.enum [ "force" ]);
    };

    allowUnfree = mkOption {
      default = false;
      # getEnv part is in check-meta.nix
      defaultText = literalExpression ''false || builtins.getEnv "NIXPKGS_ALLOW_UNFREE" == "1"'';

      description = ''
        Whether to allow unfree packages.

        See [Installing unfree packages](https://nixos.org/manual/nixpkgs/stable/#sec-allow-unfree) in the NixOS manual.
      '';

      type = types.bool;
    };

    allowUnfreePackages = mkOption {
      default = [ ];

      description = ''
        Allows specific unfree packages to be used.

        This option composes with `nixpkgs.config.allowUnfreePredicate` by also allowing the listed package names.

        Unlike `nixpkgs.config.allowUnfreePredicate`, this option merges additively, similar to `environment.systemPackages`.
        This enables defining allowed unfree packages in multiple modules, close to where they are used.

        This avoids the need to centralize all unfree package declarations or globally enable unfree packages via
        `nixpkgs.config.allowUnfree = true`.
      '';

      example = [ "ut1999" ];
      type = with lib.types; listOf str;
    };

    allowUnsupportedSystem = mkOption {
      default = false;
      # getEnv part is in check-meta.nix
      defaultText = literalExpression ''false || builtins.getEnv "NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM" == "1"'';

      description = ''
        Whether to allow unsupported packages.

        See [Installing packages on unsupported systems](https://nixos.org/manual/nixpkgs/stable/#sec-allow-unsupported-system) in the NixOS manual.
      '';

      type = types.bool;
    };

    allowVariants = mkOption {
      default = true;

      description = ''
        Whether to expose the nixpkgs variants.

        Variants are instances of the current nixpkgs instance with different stdenvs or other applied options.
        This allows for using different toolchains, libcs, or global build changes across nixpkgs.
        Disabling can ensure nixpkgs is only building for the platform which you specified.
      '';

      type = types.bool;
    };

    assertions = mkOption {
      default = [ ];
      internal = true;
      type = types.listOf types.anything;
    };

    attrPathsDisallowedForInternalUse = mkOption {
      default = [ ];

      description = ''
        List of attribute paths that may not be used by other packages in Nixpkgs.

        Should usually only be defined by Nixpkgs CI.
      '';

      internal = true;

      type = types.listOf (
        types.submodule {
          options.attrPath = lib.mkOption {
            description = ''
              Attribute path to disallow.
            '';

            type = types.listOf types.str;
          };

          options.reason = lib.mkOption {
            default = null;

            description = ''
              Reason for it being disallowed.
            '';

            example = /* because */ "it's dangerous.";
            type = types.nullOr types.str;
          };
        }
      );
    };

    checkMeta = mkOption {
      default = false;

      description = ''
        Whether to check that the `meta` attribute of derivations are correct during evaluation time.
      '';

      type = types.bool;
    };

    configurePlatformsByDefault = mkMassRebuild {
      feature = "set `configurePlatforms` to `[\"build\" \"host\"]` by default";
    };

    contentAddressedByDefault = mkMassRebuild {
      feature = "set `__contentAddressed` to true by default";
    };

    cudaCapabilities = mkOption {
      default = [ ];

      description = ''
        A list of CUDA capabilities to build for.

        Packages may use this option to control device code generation to
        take advantage of architecture-specific functionality, speed up
        compile times by producing less device code, or slim package closures.

        For example, you can build for Ada Lovelace GPUs with
        `cudaCapabilities = [ "8.9" ];`.

        If not provided, the default value is calculated per-package set,
        derived from a list of GPUs supported by that CUDA version.

        See the [CUDA section](https://nixos.org/manual/nixpkgs/stable/#cuda) in
        the Nixpkgs manual for more information.
      '';

      type = types.listOf types.str;
    };

    cudaForwardCompat = mkOption {
      default = true;

      description = ''
        Whether to enable PTX support for future hardware.

        When enabled, packages will include PTX code that can be JIT-compiled
        for GPUs newer than those explicitly targeted by `cudaCapabilities`.
      '';

      type = types.bool;
    };

    cudaSupport = mkMassRebuild {
      feature = "build packages with CUDA support by default";
    };

    doCheckByDefault = mkMassRebuild {
      feature = "run `checkPhase` by default";
    };

    enableParallelBuildingByDefault = mkMassRebuild {
      feature = "set `enableParallelBuilding` to true by default";
    };

    fetchedSourceNameDefault = mkOption {
      default = "source";

      description = ''
        This controls the default derivation `name` attribute set by the
        `fetch*` (`fetchzip`, `fetchFromGitHub`, etc) functions.

        Possible values and the resulting `.name`:

        - `"source"` -> `"source"`
        - `"versioned"` -> `"''${repo}-''${rev}-source"`
        - `"full"` -> `"''${repo}-''${rev}-''${fetcherName}-source"`

        The default `"source"` is the best choice for minimal rebuilds, it
        will ignore any non-hash changes (like branches being renamed, source
        URLs changing, etc) at the cost of `/nix/store` being easily
        cache-poisoned (see [NixOS/nix#969](https://github.com/NixOS/nix/issues/969)).

        Setting this to `"versioned"` greatly helps with discoverability of
        sources in `/nix/store` and makes cache-poisoning of `/nix/store` much
        harder, at the cost of a single mass-rebuild for all `src`
        derivations, and an occasional rebuild when a source changes some of
        its non-hash attributes.

        Setting this to `"full"` is similar to setting it to `"versioned"`,
        but the use of `fetcherName` in the derivation name will force a
        rebuild when `src` switches between `fetch*` functions, thus forcing
        `nix` to check new derivation's `outputHash`, which is useful for
        debugging.

        Also, `"full"` is useful for easy collection and tracking of
        statistics of where the packages you use are hosted.

        If you are a developer, you should probably set this to at
        least`"versioned"`.

        Changing the default will cause a mass rebuild.
      '';

      type = types.uniq (
        types.enum [
          "source"
          "versioned"
          "full"
        ]
      );
    };

    gitConfig = mkOption {
      default = { };

      description = ''
        The default [git configuration](https://git-scm.com/docs/git-config#_variables) for all [`pkgs.fetchgit`](#fetchgit) calls.

        Among many other potential uses, this can be used to override URLs to point to local mirrors.

        Changing this will not cause any rebuilds because `pkgs.fetchgit` produces a [fixed-output derivation](https://nix.dev/manual/nix/stable/glossary.html?highlight=fixed-output%20derivation#gloss-fixed-output-derivation).

        To set the configuration file directly, use the [`gitConfigFile`](#opt-gitConfigFile) option instead.

        To set the configuration file for individual calls, use `fetchgit { gitConfigFile = "..."; }`.
      '';

      example = {
        url."https://my-github-mirror.local".insteadOf = [ "https://github.com" ];
      };

      type = types.attrsOf (types.attrsOf types.anything);
    };

    # A rendered version of gitConfig that can be reused by all pkgs.fetchgit calls
    gitConfigFile = mkOption {
      default =
        if config.gitConfig != { } then
          builtins.toFile "gitconfig" (lib.generators.toGitINI config.gitConfig)
        else
          null;

      description = ''
        A path to a [git configuration](https://git-scm.com/docs/git-config#_variables) file, to be used for all [`pkgs.fetchgit`](#fetchgit) calls.

        This overrides the [`gitConfig`](#opt-gitConfig) option, see its documentation for more details.
      '';

      type = types.nullOr types.path;
    };

    hashedMirrors = mkOption {
      default = [ "https://tarballs.nixos.org" ];

      description = ''
        The set of content-addressed/hashed mirror URLs used by [`pkgs.fetchurl`](#sec-pkgs-fetchers-fetchurl).
        In case `pkgs.fetchurl` can't download from the given URLs,
        it will try the hashed mirrors based on the expected output hash.

        See [`copy-tarballs.pl`](https://github.com/NixOS/nixpkgs/blob/a2d829eaa7a455eaa3013c45f6431e705702dd46/maintainers/scripts/copy-tarballs.pl)
        for more details on how hashed mirrors are constructed.
      '';

      type = types.listOf types.str;
    };

    microsoftVisualStudioLicenseAccepted = mkOption {
      default = false;
      # getEnv part is in check-meta.nix
      defaultText = literalExpression ''false || builtins.getEnv "NIXPKGS_ALLOW_UNFREE" == "1"'';

      description = ''
        If the Microsoft Visual Studio license has been accepted.

        Please read https://www.visualstudio.com/license-terms/mt644918/ and enable this config if you accept.
      '';

      type = types.bool;
    };

    npmRegistryOverrides = mkOption {
      default = { };

      description = ''
        The default npm registry overrides for all `fetchNpmDeps` calls, as an attribute set.

        For each attribute, all files fetched from the host corresponding to the name will instead be fetched from the host (and sub-path) specified in the value.

        For example, an override like `"registry.npmjs.org" = "my-mirror.local/registry.npmjs.org"` will replace a URL like `https://registry.npmjs.org/foo.tar.gz` with `https://my-mirror.local/registry.npmjs.org/foo.tar.gz`.

        To set the string directly, see [`npmRegistryOverridesString`](#opt-npmRegistryOverridesString).
      '';

      example = {
        "registry.npmjs.org" = "my-mirror.local/registry.npmjs.org";
      };

      type = types.attrsOf types.str;
    };

    npmRegistryOverridesString = mkOption {
      default = builtins.toJSON config.npmRegistryOverrides;

      description = ''
        A string containing a string with a JSON representation of npm registry overrides for `fetchNpmDeps`.

        This overrides the [`npmRegistryOverrides`](#opt-npmRegistryOverrides) option, see its documentation for more details.
      '';

      type = types.addCheck types.str (
        s:
        let
          j = builtins.fromJSON s;
        in
        lib.isAttrs j && lib.all builtins.isString (builtins.attrValues j)
      );
    };

    problems = (import ../stdenv/generic/problems.nix { inherit lib; }).configOptions;

    recursionMode = mkOption {
      default = "eval";

      description = ''
        In which way to recurse through Nixpkgs. In most cases you want keep this as the default.
        You can use this to emulate how `hydra` and `search` are going through Nixpkgs.
      '';

      type = types.uniq (
        types.enum [
          "hydra"
          "eval"
          "search"
        ]
      );
    };

    replaceBootstrapFiles = mkMassRebuild {
      default = lib.id;
      defaultText = literalExpression "lib.id";

      description = ''
        Use the bootstrap files returned instead of the default bootstrap
        files.
        The default bootstrap files are passed as an argument.
      '';

      example = literalExpression ''
        prevFiles:
        let
          replacements = {
            "sha256-YQlr088HPoVWBU2jpPhpIMyOyoEDZYDw1y60SGGbUM0=" = import <nix/fetchurl.nix> {
              url = "(custom glibc linux x86_64 bootstrap-tools.tar.xz)";
              hash = "(...)";
            };
            "sha256-QrTEnQTBM1Y/qV9odq8irZkQSD9uOMbs2Q5NgCvKCNQ=" = import <nix/fetchurl.nix> {
              url = "(custom glibc linux x86_64 busybox)";
              hash = "(...)";
              executable = true;
            };
          };
        in
        builtins.mapAttrs (name: prev: replacements.''${prev.outputHash} or prev) prevFiles
      '';

      type = types.functionTo (types.attrsOf types.package);
    };

    replaceStdenv = mkMassRebuild {
      default = null;
      defaultText = literalExpression "null";

      description = ''
        A function to replace the standard environment (stdenv).

        The function receives an attribute set with `pkgs` and should return
        a stdenv derivation.

        This can be used to globally replace the stdenv with a custom one,
        for example to use ccache or distcc.
      '';

      example = literalExpression "{ pkgs }: pkgs.ccacheStdenv";
      type = types.nullOr (types.functionTo types.package);
    };

    rewriteURL = mkOption {
      default = null;

      description = ''
        A hook to rewrite/filter URLs before they are fetched.

        The function is passed the URL as a string, and is expected to return a new URL, or null if the given URL should not be attempted.

        This function is applied _prior_ to resolving mirror:// URLs.

        The intended use is to allow URL rewriting to insert company-internal mirrors, or work around company firewalls and similar network restrictions.
      '';

      example = literalExpression ''
        {
          # Use Nix like it's 2024! ;-)
          rewriteURL = url: "https://web.archive.org/web/2024/''${url}";
        }
      '';

      type = types.nullOr (types.functionTo (types.nullOr types.str));
    };

    rocmSupport = mkMassRebuild {
      feature = "build packages with ROCm support by default";
    };

    showDerivationWarnings = mkOption {
      default = [ ];

      description = ''
        Which warnings to display for potentially dangerous
        or deprecated values passed into `stdenv.mkDerivation`.

        A list of warnings can be found in
        [/pkgs/stdenv/generic/check-meta.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/check-meta.nix).

        This is not a stable interface; warnings may be added, changed
        or removed without prior notice.
      '';

      type = types.listOf (types.enum [ "maintainerless" ]);
    };

    strictDepsByDefault = mkMassRebuild {
      feature = "set `strictDeps` to true by default";
    };

    structuredAttrsByDefault = mkMassRebuild {
      feature = "set `__structuredAttrs` to true by default";
    };

    # Config options
    warnUndeclaredOptions = mkOption {
      default = false;
      description = "Whether to warn when `config` contains an unrecognized attribute.";
      type = types.bool;
    };

    # Should be replaced by importing <nixos/modules/misc/assertions.nix> in the future
    # see also https://github.com/NixOS/nixpkgs/pull/207187
    warnings = mkOption {
      default = [ ];
      internal = true;
      type = types.listOf types.str;
    };
  };

in
{

  inherit options;

  config = {
    assertions =
      # Collect the assertions from the problems.matchers.* submodules, propagate them into here
      lib.concatMap (matcher: matcher.assertions) config.problems.matchers;

    # Put the default value for matchers in here (as in, not as an *actual* mkDefault default value),
    # to force it being merged with any custom values instead of being overridden.
    problems.matchers = [
      {
        handler = "error";
        kind = "broken";
      }
      # Be loud and clear about package removals
      {
        handler = "warn";
        kind = "removal";
      }
      (lib.mkIf (lib.elem "maintainerless" config.showDerivationWarnings) {
        handler = "warn";
        kind = "maintainerless";
      })
    ];

    warnings =
      optionals config.warnUndeclaredOptions (
        mapAttrsToList (k: v: "undeclared Nixpkgs option set: config.${k}") config._undeclared or { }
      )
      ++ lib.optional (config.showDerivationWarnings != [ ]) ''
        `config.showDerivationWarnings = [ "maintainerless" ]` is deprecated, use `config.problems` instead:

          config.problems.matchers = [ { kind = "maintainerless"; handler = "warn"; } ];

        See this page for more details: https://nixos.org/manual/nixpkgs/unstable#sec-problems
      '';
  };

  freeformType =
    let
      t = types.lazyAttrsOf types.raw;
    in
    t
    // {
      merge =
        loc: defs:
        let
          r = t.merge loc defs;
        in
        r // { _undeclared = r; };
    };

}
