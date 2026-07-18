{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xwin";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Jake-Shadle";
    repo = "xwin";
    tag = finalAttrs.version;
    hash = "sha256-p7rrZ2yxSpGKNuddcSO2wlvsIFj8LYG91tCK1mWO+NY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-e2uYAE2veYDNZpHr40bpIbplg7orW8oIxgZORhPpbFY=";
  doCheck = true;

  # Requires network access
  checkFlags = [
    "--skip=verify_compiles"
    "--skip=verify_deterministic"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildFeatures = [
    "native-tls"
  ];

  buildNoDefaultFeatures = true;
  versionCheckProgram = placeholder "out" + "/bin/xwin";

  meta = {
    description = "Utility for downloading the Microsoft CRT & Windows SDK libraries";
    homepage = "https://github.com/Jake-Shadle/xwin";
    changelog = "https://github.com/Jake-Shadle/xwin/releases/tag/" + finalAttrs.version;

    license = [
      lib.licenses.mit
      lib.licenses.asl20
    ];

    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "xwin";
  };
})
