{
  defaultConfig ? null,
}@args:
let
  lib = import ../../../lib;

  # By taking defaultConfig early, we can cache the result of calling
  # make-derivation.nix with config, which leads to more memoisation between
  # bootstrapping stages. We only have to re-call the file with another config
  # if stdenv-overridable is actually called with config, otherwise we stick to
  # defaultConfig. No stdenvs currently specify a non-default config, but we
  # leave it open as a possibility.
  makeDerivationFile = import ./make-derivation.nix lib;
  makeDerivationFileWithConfig =
    assert args ? defaultConfig;
    makeDerivationFile args.defaultConfig;

  defaultNativeBuildInputs0 = [
    ../../build-support/setup-hooks/no-broken-symlinks.sh
    ../../build-support/setup-hooks/audit-tmpdir.sh
    ../../build-support/setup-hooks/compress-man-pages.sh
    ../../build-support/setup-hooks/make-symlinks-relative.sh
    ../../build-support/setup-hooks/move-docs.sh
    ../../build-support/setup-hooks/move-lib64.sh
    ../../build-support/setup-hooks/move-sbin.sh
    ../../build-support/setup-hooks/move-systemd-user-units.sh
    ../../build-support/setup-hooks/multiple-outputs.sh
    ../../build-support/setup-hooks/patch-shebangs.sh
    ../../build-support/setup-hooks/prune-libtool-files.sh
    ../../build-support/setup-hooks/reproducible-builds.sh
    ../../build-support/setup-hooks/set-source-date-epoch-to-latest.sh
    ../../build-support/setup-hooks/strip.sh
  ];

  stdenv-overridable = lib.makeOverridable (

    argsStdenv@{
      ## Platform parameters
      ##
      ## The "build" "host" "target" terminology below comes from GNU Autotools. See
      ## its documentation for more information on what those words mean. Note that
      ## each should always be defined, even when not cross compiling.
      ##
      ## For purposes of bootstrapping, think of each stage as a "sliding window"
      ## over a list of platforms. Specifically, the host platform of the previous
      ## stage becomes the build platform of the current one, and likewise the
      ## target platform of the previous stage becomes the host platform of the
      ## current one.
      ##
      # The platform on which packages are built. Consists of `system`, a
      # string (e.g.,`i686-linux') identifying the most import attributes of the
      # build platform, and `platform` a set of other details.
      buildPlatform,
      cc,
      # The `fetchurl' to use for downloading curl and its dependencies
      # (see all-packages.nix).
      fetchurlBoot,
      # The platform on which packages run.
      hostPlatform,
      initialPath,
      shell,
      # The platform which build tools (especially compilers) build for in this stage,
      targetPlatform,
      __extraImpureHostDeps ? [ ],
      __stdenvImpureHostDeps ? [ ],
      allowedRequisites ? null,
      config ? args.defaultConfig,
      disallowedRequisites ? [ ],
      extraAttrs ? { },
      extraBuildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
      extraSandboxProfile ? "",
      # If we don't have a C compiler, we might either have `cc = null` or `cc =
      # throw ...`, but if we do have a C compiler we should definitely have `cc !=
      # null`.
      #
      # TODO(@Ericson2314): Add assert without creating infinite recursion
      hasCC ? cc != null,
      # The implementation of `mkDerivation`, parameterized with the final stdenv so we can tie the knot.
      # This is convenient to have as a parameter so the stdenv "adapters" work better
      mkDerivationFromStdenv ?
        let
          makeDerivationWithConfig' =
            if argsStdenv ? config then makeDerivationFile config else makeDerivationFileWithConfig;
        in
        stdenv: (makeDerivationWithConfig' stdenv).mkDerivation,
      name ? "stdenv",
      overrides ? (self: super: { }),
      pname ? name,
      preHook ? "",
      setupScript ? ./setup.sh,
      stdenvSandboxProfile ? "",
      version ? "26.05pre-git",
    }:

    let
      defaultNativeBuildInputs =
        extraNativeBuildInputs ++ defaultNativeBuildInputs0 ++ lib.optionals hasCC [ cc ];

      defaultBuildInputs = extraBuildInputs;

      stdenv = (stdenv-overridable argsStdenv);

    in
    # The stdenv that we are producing.
    derivation {
      inherit name pname version;
      inherit disallowedRequisites;
      # Nix itself uses the `system` field of a derivation to decide where to
      # build it. This is a bit confusing for cross compilation.
      inherit (buildPlatform) system;

      inherit
        initialPath
        shell
        defaultNativeBuildInputs
        defaultBuildInputs
        ;

      ${if allowedRequisites != null then "allowedRequisites" else null} =
        allowedRequisites ++ defaultNativeBuildInputs ++ defaultBuildInputs;

      ${if buildPlatform.isDarwin then "__impureHostDeps" else null} = __stdenvImpureHostDeps;
      ${if buildPlatform.isDarwin then "__sandboxProfile" else null} = stdenvSandboxProfile;
      ${if config.contentAddressedByDefault then "__contentAddressed" else null} = true;
      ${if config.contentAddressedByDefault then "outputHashAlgo" else null} = "sha256";
      ${if config.contentAddressedByDefault then "outputHashMode" else null} = "recursive";

      args = [
        "-e"
        ./builder.sh
      ];

      builder = shell;

      # We pretty much never need rpaths on Darwin, since all library path references
      # are absolute unless we go out of our way to make them relative (like with CF)
      # TODO: This really wants to be in stdenv/darwin but we don't have hostPlatform
      # there (yet?) so it goes here until then.
      preHook =
        preHook
        + lib.optionalString buildPlatform.isDarwin ''
          export NIX_DONT_SET_RPATH_FOR_BUILD=1
        ''
        + lib.optionalString (hostPlatform.isDarwin || (!hostPlatform.isElf && !hostPlatform.isMacho)) ''
          export NIX_DONT_SET_RPATH=1
          export NIX_NO_SELF_RPATH=1
        ''
        + lib.optionalString (hostPlatform.isDarwin && hostPlatform.isMacOS) ''
          export MACOSX_DEPLOYMENT_TARGET=${hostPlatform.darwinMinVersion}
        ''
      # TODO this should be uncommented, but it causes stupid mass rebuilds due to
      # `pkgsCross.*.buildPackages` not being the same, resulting in cross-compiling
      # for a target rebuilding all of `nativeBuildInputs` for that target.
      #
      # I think the best solution would just be to fixup linux RPATHs so we don't
      # need to set `-rpath` anywhere.
      # + lib.optionalString targetPlatform.isDarwin ''
      #   export NIX_DONT_SET_RPATH_FOR_TARGET=1
      # ''
      ;

      setup = setupScript;
    }

    // {

      inherit buildPlatform hostPlatform targetPlatform;

      inherit
        extraNativeBuildInputs
        extraBuildInputs
        __extraImpureHostDeps
        extraSandboxProfile
        ;

      # Utility flags to test the type of platform.
      inherit (hostPlatform)
        isDarwin
        isLinux
        isSunOS
        isCygwin
        isBSD
        isFreeBSD
        isOpenBSD
        isi686
        isx86_32
        isx86_64
        is32bit
        is64bit
        isAarch32
        isAarch64
        isMips
        isBigEndian
        ;

      # Override `system` so that packages can get the system of the host
      # platform through `stdenv.system`. `system` is originally set to the
      # build platform within the derivation above so that Nix directs the build
      # to correct type of machine.
      inherit (hostPlatform) system;
      inherit fetchurlBoot;
      inherit overrides;
      inherit cc hasCC;
      mkDerivation = mkDerivationFromStdenv stdenv;
      # Convenience for doing some very basic shell syntax checking by parsing a script
      # without running any commands. Because this will also skip `shopt -s extglob`
      # commands and extglob affects the Bash parser, we enable extglob always.
      shellDryRun = "${stdenv.shell} -n -O extglob";

      tests = {
        inputDerivationRequiredSystemFeatures = import ../tests/inputDerivationRequiredSystemFeatures.nix {
          inherit lib stdenv;
        };

        succeedOnFailure = import ../tests/succeedOnFailure.nix { inherit stdenv; };
      };

      passthru.tests = lib.warn "Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail." stdenv.tests;

      meta =
        let
          pos = builtins.unsafeGetAttrPos "name" argsStdenv;
        in
        {
          description = "The default build environment for Unix packages in Nixpkgs";
          license = lib.licenses.mit;
          platforms = lib.platforms.all;

          identifiers.cpeParts = {
            inherit version;
            part = "a";
            product = argsStdenv.name;
            vendor = "nixos";
          };

          position = "${pos.file}:${toString pos.line}";
          teams = [ lib.teams.stdenv ];
        };
    }

    # Propagate any extra attributes.  For instance, we use this to
    # "lift" packages like curl from the final stdenv for Linux to
    # all-packages.nix for that platform (meaning that it has a line
    # like curl = if stdenv ? curl then stdenv.curl else ...).
    // extraAttrs
  );
in
stdenv-overridable
