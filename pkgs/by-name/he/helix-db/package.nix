{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "helix-db";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "HelixDB";
    repo = "helix-db";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2dhCTMCgB7vbGa3URbPGJTPJQXcAUQjlTshemZqWH8E=";
  };

  patches = [
    #There are no feature yet
    ./disable-updates.patch
  ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];
  cargoHash = "sha256-Nx30s7530W7JDizLKAHxf1aoe78QApNBJL97vO0FDZA=";
  env.OPENSSL_NO_VENDOR = true;
  #There are no tests
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "-p"
    "helix-cli"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source graph-vector database built from scratch in Rust";
    homepage = "https://github.com/HelixDB/helix-db";
    changelog = "https://github.com/HelixDB/helix-db/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "helix";
  };
})
