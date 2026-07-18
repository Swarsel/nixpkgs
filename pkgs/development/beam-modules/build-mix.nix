{
  lib,
  stdenv,
  beamCopySourceHook,
  beamModuleInstallHook,
  elixir,
  erlang,
  hex,
  mixAppConfigPatchHook,
  mixBuildDirHook,
  mixCompileHook,
  writeText,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "mixEnv"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      # Allow passing compile time config instead of an empty config
      appConfigPath ? null,
      beamDeps ? [ ],
      enableDebugInfo ? false,
      erlangCompilerOptions ? [ ],
      # Deterministic Erlang builds remove full system paths from debug information
      # among other things to keep builds more reproducible. See their docs for more:
      # https://www.erlang.org/doc/man/compile
      erlangDeterministicBuilds ? true,
      mixEnv ? "prod",
      mixTarget ? "host",
      ...
    }@args:
    {
      nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
        elixir
        hex

        beamCopySourceHook
        beamModuleInstallHook
        mixBuildDirHook
        mixCompileHook
        mixAppConfigPatchHook
      ];

      propagatedBuildInputs = (args.propagatedBuildInputs or [ ]) ++ beamDeps;

      env = {
        ERL_COMPILER_OPTIONS =
          let
            options = erlangCompilerOptions ++ lib.optionals erlangDeterministicBuilds [ "deterministic" ];
          in
          "[${lib.concatStringsSep "," options}]";

        HEX_OFFLINE = 1;
        LANG = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "C";
        LC_CTYPE = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "UTF-8";
        MIX_BUILD_PREFIX = (if mixTarget == "host" then "" else "${mixTarget}_") + "${mixEnv}";
        MIX_DEBUG = if enableDebugInfo then 1 else 0;
        MIX_ENV = mixEnv;
        MIX_TARGET = mixTarget;
        # some hooks need name-version, but we've overridden name above for the nix package
        beamModuleName = args.name;
      }
      // (args.env or { });

      __darwinAllowLocalNetworking = true;
      name = "erlang${erlang.version}-${args.name}-${finalAttrs.version}";

      # add to ERL_LIBS so other modules can find at runtime.
      # http://erlang.org/doc/man/code.html#code-path
      # Mix also searches the code path when compiling with the --no-deps-check flag
      # This is used by package builders such as mixRelease
      setupHook = writeText "setupHook.sh" ''
        addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
      '';

      passthru = (args.passthru or { }) // {
        inherit beamDeps;
      };
    };
}
