{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  fontconfig,
  nix-update-script,
  openssl,
  # nativeBuildInputs
  pkg-config,
  protobuf,
  redis,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "golem";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "golemcloud";
    repo = "golem";
    tag = "v${version}";
    hash = "sha256-6AUUgXWlDaoI16p/Hrl115XMGYUIDD5YWHX6JfDk9SI=";
  };

  # Taker from https://github.com/golemcloud/golem/blob/v1.0.26/Makefile.toml#L399
  postPatch = ''
    grep -rl --include 'Cargo.toml' '0\.0\.0' | xargs sed -i "s/0\.0\.0/${version}/g"
  '';

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    (lib.getDev openssl)
  ];

  cargoHash = "sha256-zf/L7aNsfQXCdGpzvBZxgoatAGB92bvIuj59jANrXIc=";

  env = {
    # Required for golem-wasm-rpc's build.rs to find the required protobuf files
    # https://github.com/golemcloud/wasm-rpc/blob/v1.0.6/wasm-rpc/build.rs#L7
    GOLEM_WASM_AST_ROOT = "../golem-wasm-ast-1.1.0";
    # Required for golem-examples's build.rs to find the required Wasm Interface Type (WIT) files
    # https://github.com/golemcloud/golem-examples/blob/v1.0.6/build.rs#L9
    GOLEM_WIT_ROOT = "../golem-wit-1.1.0";
  };

  # Tests are failing in the sandbox because of some redis integration tests
  doCheck = false;
  checkInputs = [ redis ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = [ "${placeholder "out"}/bin/golem-cli" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source durable computing platform that makes it easy to build and deploy highly reliable distributed systems";
    homepage = "https://www.golem.cloud/";
    changelog = "https://github.com/golemcloud/golem/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kmatasfp ];
    mainProgram = "golem-cli";
  };
}
