{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  # nativeBuildInputs
  cmake,
  fmt,
  gtest,
  libpq,
  # buildInputs
  nanoarrow,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (finalAttrs.finalPackage.passthru.bigquery-go-package) goModules;
  pname = "arrow-adbc";
  version = "23";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "arrow-adbc";
    tag = "apache-arrow-adbc-${finalAttrs.version}";
    hash = "sha256-33JUx4ZI+BHIZMvlCO43mjU34zShJZGQpAkqRrvgl2w=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    # NOTE that the meson build system has a bug that it puts a few shared
    # objects in $out and not in $out/lib.
    cmake
    pkg-config
    finalAttrs.finalPackage.passthru.bigquery-go-package.passthru.go
  ];

  buildInputs = [
    fmt
    gtest
    libpq
    nanoarrow
    sqlite
  ];

  vendorHash = "sha256-uGxCTllRNtXkrl31d88TOK36X09ylo++gtorx0uFR8A=";

  cmakeFlags = map (driver: lib.cmakeBool "ADBC_DRIVER_${driver}" true) [
    "BIGQUERY"
    "FLIGHTSQL"
    "MANAGER"
    "POSTGRESQL"
    "SNOWFLAKE"
    "SQLITE"
  ];

  # We are building the C project
  preConfigure = ''
    cd c/
  '';

  preBuild =
    (lib.pipe finalAttrs.finalPackage.passthru.bigquery-go-package.configurePhase [
      # Make that this configure phase doesn't run our configure hooks.
      (lib.replaceString "runHook preConfigure" "")
      (lib.replaceString "runHook postConfigure" "")
    ])
    # Return to original meson build directory.
    + ''
      cd ../../c/build
    '';

  __structuredAttrs = true;
  # Upstream's build invoces a custom `go build` command to build one of the
  # targets. We use buildGoModule's engineering to supply it the offline
  # `goModules` path and other GO[A-Z] environment variables. Ideally, there
  # should be setup hooks for the mechanisms of buildGoModule, that would make
  # it easier.
  modRoot = "../../go/adbc";

  passthru = {
    bigquery-go-package = buildGoModule (finalGoAttrs: {
      inherit (finalAttrs)
        pname
        version
        src
        vendorHash
        ;

      # This derivation is not really evaluated anyway, but it is used to
      # update the vendorHash... TODO: Check that nix-update is capable of
      # updating vendorHash automatically.
      dontBuild = true;
      dontInstall = true;
      sourceRoot = "${finalAttrs.src.name}/go/adbc";
    });
  };

  meta = {
    description = "Database connectivity API standard and libraries for Apache Arrow";
    homepage = "https://arrow.apache.org/adbc/";
    changelog = "https://github.com/apache/arrow-adbc/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.afl20;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.all;
  };
})
