{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kaput-cli";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "davidchalifoux";
    repo = "kaput-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N+vdK9DpooPEtXVUNZtmbdjVSpN5ddYggb4FsrvyCwU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-bz7K3eWv9i50k5nXBb9k8IZ+xPIz4PSomp6K2LDSH78=";

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial CLI client for Put.io";
    homepage = "https://kaput.sh/";
    changelog = "https://github.com/davidchalifoux/kaput-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kaput";
  };
})
