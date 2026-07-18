{
  lib,
  stdenv,
  buildPackages,
  cargo,
  cargo-auditable,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
  cargoNextestHook,
  cargoSetupHook,
  fetchCargoVendor,
  importCargoLock,
  rustc,
  windows,
}:

let
  getOptionalAttrs =
    names: attrs: lib.getAttrs (lib.intersectLists names (lib.attrNames attrs)) attrs;

  interpolateString =
    s:
    if lib.isList s then
      lib.concatMapStringsSep " " (s: "${s}") (lib.filter (s: s != null) s)
    else if s == null then
      ""
    else
      "${s}";
in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "depsExtraArgs"
    "cargoUpdateHook"
    "cargoLock"
    "useFetchCargoVendor"
    "RUSTFLAGS"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      auditable ? !cargo-auditable.meta.broken,
      # Needed to `pushd`/`popd` into a subdir of a tarball if this subdir
      # contains a Cargo.toml, but isn't part of a workspace (which is e.g. the
      # case for `rustfmt`/etc from the `rust-sources).
      # Otherwise, everything from the tarball would've been built/tested.
      buildAndTestSubdir ? null,
      buildFeatures ? [ ],
      buildInputs ? [ ],
      buildNoDefaultFeatures ? false,
      buildType ? "release",
      cargoDeps ? null,
      cargoDepsHook ? "",
      # Name for the vendored dependencies tarball
      cargoDepsName ? null,
      cargoLock ? null,
      cargoPatches ? [ ],
      cargoRoot ? null,
      cargoUpdateHook ? "",
      cargoVendorDir ? null,
      checkFeatures ? buildFeatures,
      checkNoDefaultFeatures ? buildNoDefaultFeatures,
      checkType ? buildType,
      depsExtraArgs ? { },
      logLevel ? "",
      meta ? { },
      nativeBuildInputs ? [ ],
      patches ? [ ],
      sourceRoot ? null,
      useFetchCargoVendor ? true,
      useNextest ? false,
      ...
    }@args:

    assert
      useFetchCargoVendor
      || throw "buildRustPackage: `useFetchCargoVendor` is non‐optional and enabled by default as of 25.05, remove it";

    assert lib.warnIf (args ? useFetchCargoVendor)
      "buildRustPackage: `useFetchCargoVendor` is non‐optional and enabled by default as of 25.05, remove it"
      true;
    {
      inherit buildAndTestSubdir;
      patches = cargoPatches ++ patches;
      strictDeps = true;

      nativeBuildInputs =
        nativeBuildInputs
        ++ lib.optionals auditable [
          (buildPackages.cargo-auditable-cargo-wrapper.override {
            inherit cargo cargo-auditable;
          })
        ]
        ++ [
          cargoBuildHook
          (if useNextest then cargoNextestHook else cargoCheckHook)
          cargoInstallHook
          cargoSetupHook
          rustc
          cargo
        ];

      buildInputs = buildInputs ++ lib.optionals stdenv.hostPlatform.isMinGW [ windows.pthreads ];

      env =
        let
          isDarwinDebug = stdenv.hostPlatform.isDarwin && buildType == "debug";
        in
        {
          # Prevent shadowing *_RUSTFLAGS environment variables
          ${if args ? RUSTFLAGS || isDarwinDebug then "RUSTFLAGS" else null} =
            lib.optionalString isDarwinDebug "-C split-debuginfo=packed "
            # Workaround the existing RUSTFLAGS specified as a list.
            + interpolateString (args.RUSTFLAGS or "");

          PKG_CONFIG_ALLOW_CROSS = if stdenv.buildPlatform != stdenv.hostPlatform then 1 else 0;
          RUST_LOG = logLevel;
        }
        // args.env or { };

      doCheck = args.doCheck or true;
      cargoBuildFeatures = buildFeatures;
      cargoBuildNoDefaultFeatures = buildNoDefaultFeatures;
      cargoBuildType = buildType;
      cargoCheckFeatures = checkFeatures;
      cargoCheckNoDefaultFeatures = checkNoDefaultFeatures;
      cargoCheckType = checkType;

      cargoDeps =
        if cargoVendorDir != null then
          null
        else if cargoDeps != null then
          cargoDeps
        else if cargoLock != null then
          importCargoLock cargoLock
        else if args.cargoHash or null == null then
          throw "cargoHash, cargoVendorDir, cargoDeps, or cargoLock must be set"
        else
          fetchCargoVendor (
            getOptionalAttrs [
              "name"
              "pname"
              "version"
              "src"
              "srcs"
              "sourceRoot"
              "cargoRoot"
              "preUnpack"
              "unpackPhase"
              "postUnpack"
            ] finalAttrs
            // {
              patches = cargoPatches;
              ${if cargoDepsName != null then "name" else null} = cargoDepsName;
              hash = args.cargoHash;
            }
            // depsExtraArgs
          );

      configurePhase =
        args.configurePhase or ''
          runHook preConfigure
          runHook postConfigure
        '';

      meta = meta // {
        # default to Rust's platforms
        platforms = lib.intersectLists meta.platforms or lib.platforms.all rustc.targetPlatforms;
        badPlatforms = meta.badPlatforms or [ ] ++ rustc.badTargetPlatforms;
      };
    };
}
