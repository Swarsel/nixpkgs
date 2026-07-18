{
  lib,
  fetchFromGitHub,
  coturn,
  nix-update-script,
  nixosTests,
  # Dependencies
  protobuf,
  rustPlatform,
  # Tests
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "turn-rs";
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "mycrl";
    repo = "turn-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tvZWLyWxdSxAKVm92Zll0jpY+9x7YA9h9uBhmfVZfvA=";
  };

  nativeBuildInputs = [
    protobuf
  ];

  cargoHash = "sha256-BPqAX1ZbUygF+luLuPlV0eNf6KRdmm/YNJMCtnuqOPo=";
  env.COTURN_UCLIENT_PATH = lib.getExe' coturn "turnutils_uclient";
  # Fix coturn needed
  nativeCheckInputs = [ coturn ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # By default, no features are enabled
  # https://github.com/mycrl/turn-rs?tab=readme-ov-file#features-1
  cargoBuildFlags = [ "--all-features" ];
  versionCheckProgram = "${placeholder "out"}/bin/turn-server";

  passthru = {
    tests.nixos = nixosTests.turn-rs;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pure rust implemented turn server";
    homepage = "https://github.com/mycrl/turn-rs";
    changelog = "https://github.com/mycrl/turn-rs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "turn-server";
  };
})
