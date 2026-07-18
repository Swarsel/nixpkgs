{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  protobuf,
  python3,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sail";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "lakehq";
    repo = "sail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DpkoC7uShuReOBN5tjvcCSH1LH/e+fj3gp47idsEGEg=";
  };

  nativeBuildInputs = [
    protobuf
    pkg-config
  ];

  buildInputs = [
    python3
  ];

  cargoHash = "sha256-byjxrJN+Q+Rn3pq/FWXxzheZyUs+aoTvfileahqinuA=";

  env = {
    PROTOC = lib.getExe protobuf;
    PYO3_PYTHON = lib.getExe python3;
  };

  # Tests require a running server
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "-p"
    "sail-cli"
  ];

  cargoTestFlags = [
    "-p"
    "sail-cli"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Spark-compatible compute engine built on Apache Arrow and DataFusion";
    homepage = "https://github.com/lakehq/sail";
    changelog = "https://github.com/lakehq/sail/blob/v${finalAttrs.version}/docs/reference/changelog/index.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.davidlghellin ];
    mainProgram = "sail";
  };
})
