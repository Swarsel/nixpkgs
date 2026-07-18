{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  withTls ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "simple-http-server";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "TheWaWaR";
    repo = "simple-http-server";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-JG9dqc8E8rUjSG3pBypamjNqFpM87r7cK+zP+PSyMCQ=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optional withTls openssl;
  cargoHash = "sha256-3DelxN2oTFZzoSke7uLbSKYJnF2Bq4MWDvfnKTIsbGk=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildFeatures = lib.optional withTls "tls";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple HTTP server in Rust";
    homepage = "https://github.com/TheWaWaR/simple-http-server";
    changelog = "https://github.com/TheWaWaR/simple-http-server/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mephistophiles
      progrm_jarvis
    ];

    mainProgram = "simple-http-server";
  };
})
