{
  lib,
  fetchFromGitHub,
  hydra-cli,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hydra-cli";
  version = "0.3.0-unstable-2023-12-20";

  src = fetchFromGitHub {
    owner = "nlewo";
    repo = "hydra-cli";
    rev = "dbb6eaa45c362969382bae7142085be769fa14e6";
    hash = "sha256-6L+5rkXzjXH9JtLsrJkuV8ZMsm64Q+kcb+2pr1coBK4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-JnfonNdy87Ol6j8x3270RrVv/13vNLEa1n+/aeEbc7U=";
  __darwinAllowLocalNetworking = true;
  sourceRoot = "${finalAttrs.src.name}/hydra-cli";

  passthru.tests.version = testers.testVersion {
    version = "0.3.0";
    package = hydra-cli;
  };

  meta = {
    description = "Client for the Hydra CI";
    homepage = "https://github.com/nlewo/hydra-cli";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      lewo
      aleksana
    ];

    mainProgram = "hydra-cli";
  };
})
