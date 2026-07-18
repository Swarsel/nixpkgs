{
  lib,
  fetchFromGitHub,
  callPackage,
  cmake,
  elfutils,
  nix-update-script,
  pkg-config,
  protobuf,
  router,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage rec {
  pname = "router";
  version = "1.56.0";

  src = fetchFromGitHub {
    owner = "apollographql";
    repo = "router";
    rev = "v${version}";
    hash = "sha256-4l9nTbtF8hy2x1fdRhmMKcYxTD6wWKXIfihLTWdtm7U=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [
    elfutils
  ];

  cargoHash = "sha256-1AKYOv7kT60H8x1qmtPqR4Wxq1DxSCDzt+Uv7MRUeaw=";
  # The v8 package will try to download a `librusty_v8.a` release at build time to our read-only filesystem
  # To avoid this we pre-download the file and export it via RUSTY_V8_ARCHIVE
  env.RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix { };

  cargoTestFlags = [
    "--"
    "--skip=query_planner::tests::missing_typename_and_fragments_in_requires"
  ];

  passthru = {
    tests.version = testers.testVersion { package = router; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Configurable, high-performance routing runtime for Apollo Federation";
    homepage = "https://www.apollographql.com/docs/router/";
    license = lib.licenses.elastic20;
    maintainers = [ lib.maintainers.bbigras ];
  };
}
