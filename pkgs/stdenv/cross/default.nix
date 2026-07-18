{
  lib,
  config,
  crossOverlays,
  crossSystem,
  localSystem,
  overlays,
}:

let
  bootStages = import ../. {
    inherit lib localSystem overlays;
    # Ignore custom stdenvs when cross compiling for compatibility
    # Use replaceCrossStdenv instead.
    config = removeAttrs config [ "replaceStdenv" ];
    crossOverlays = [ ];
    crossSystem = localSystem;
  };

in
lib.init bootStages
++ [

  # Regular native packages
  (
    somePrevStage:
    lib.last bootStages somePrevStage
    // {
      # It's OK to change the built-time dependencies
      allowCustomOverrides = true;
    }
  )

  # Build tool Packages
  (vanillaPackages: {
    inherit config overlays;
    # It's OK to change the built-time dependencies
    allowCustomOverrides = true;
    selfBuild = false;

    stdenv =
      assert vanillaPackages.stdenv.buildPlatform == localSystem;
      assert vanillaPackages.stdenv.hostPlatform == localSystem;
      assert vanillaPackages.stdenv.targetPlatform == localSystem;
      vanillaPackages.stdenv.override { targetPlatform = crossSystem; };
  })

  # Run Packages
  (
    buildPackages:
    let
      adaptStdenv = if crossSystem.isStatic then buildPackages.stdenvAdapters.makeStatic else lib.id;
      stdenvNoCC = adaptStdenv (
        buildPackages.stdenv.override (old: rec {
          allowedRequisites = null;
          buildPlatform = localSystem;
          cc = null;
          extraBuildInputs = [ ]; # Old ones run on wrong platform

          extraNativeBuildInputs =
            old.extraNativeBuildInputs
            ++ lib.optionals (hostPlatform.isLinux && !buildPlatform.isLinux) [ buildPackages.patchelf ]
            ++ lib.optional (
              let
                f =
                  p:
                  !p.isx86
                  || builtins.elem p.libc [
                    "musl"
                    "wasilibc"
                    "relibc"
                  ]
                  || p.isiOS
                  || p.isGenode;
              in
              f hostPlatform && !(f buildPlatform)
            ) buildPackages.updateAutotoolsGnuConfigScriptsHook
            ++ lib.optional (
              hostPlatform.isCygwin && !buildPlatform.isCygwin
            ) buildPackages.cygwin.cygwinDllLinkHook;

          hasCC = false;
          hostPlatform = crossSystem;
          # Prior overrides are surely not valid as packages built with this run on
          # a different platform, and so are disabled.
          overrides = _: _: { };
          targetPlatform = crossSystem;
        })
      );
    in
    {
      inherit config;
      inherit stdenvNoCC;
      overlays = overlays ++ crossOverlays;
      selfBuild = false;

      stdenv =
        let
          inherit (stdenvNoCC) hostPlatform targetPlatform;
          baseStdenv = stdenvNoCC.override {
            cc =
              if crossSystem.useiOSPrebuilt or false then
                buildPackages.darwin.iosSdkPkgs.clang
              else if crossSystem.useAndroidPrebuilt or false then
                buildPackages."androidndkPkgs_${crossSystem.androidNdkVersion}".clang
              else if
                targetPlatform.isGhcjs
              # Need to use `throw` so tryEval for splicing works, ugh.  Using
              # `null` or skipping the attribute would cause an eval failure
              # `tryEval` wouldn't catch, wrecking accessing previous stages
              # when there is a C compiler and everything should be fine.
              then
                throw "no C compiler provided for this platform"
              else if crossSystem.isDarwin then
                buildPackages.llvmPackages.systemLibcxxClang
              else if crossSystem.useLLVM or false then
                buildPackages.llvmPackages.clang
              else if crossSystem.useZig or false then
                buildPackages.zig.cc
              else if crossSystem.useArocc or false then
                buildPackages.arocc
              else
                buildPackages.gcc;

            # Old ones run on wrong platform
            extraBuildInputs = lib.optionals hostPlatform.isDarwin [
              buildPackages.targetPackages.apple-sdk
            ];

            hasCC = !stdenvNoCC.targetPlatform.isGhcjs;

          };
        in
        if config ? replaceCrossStdenv then
          config.replaceCrossStdenv { inherit buildPackages baseStdenv; }
        else
          baseStdenv;
    }
  )

]
