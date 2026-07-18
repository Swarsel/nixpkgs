{
  lib,
  fetchFromGitHub,
  protobuf,
  rustPlatform,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "starpls";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "withered-magic";
    repo = "starpls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t9kdpBKyGM61CKhtfO5urVVzyKpL0bX0pZuf0djDdCw=";
  };

  nativeBuildInputs = [
    protobuf
  ];

  cargoHash = "sha256-5xYfQRm7U7sEQiJEfjaLznoXUxHsxnLmIEA/OxTkjFg=";
  # The tests assume Bazel build and environment variables set like
  # RUNFILES_DIR which don't have an equivalent in Cargo.
  doCheck = false;
  # Only build the starpls language server, not the xtask build helper, which
  # would otherwise leak into $out/bin.
  cargoBuildFlags = [ "-p starpls" ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "starpls version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Language server for Starlark";
    homepage = "https://github.com/withered-magic/starpls";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.all;
    mainProgram = "starpls";
  };
})
