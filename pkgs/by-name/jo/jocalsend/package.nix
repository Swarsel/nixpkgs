{
  lib,
  fetchFromGitea,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jocalsend";
  version = "1.618033988";

  src = fetchFromGitea {
    owner = "nebkor";
    repo = "joecalsend";
    tag = finalAttrs.version;
    hash = "sha256-nzsvVC1e8ENh0bpQwiogGew823NNmSNXN+VZZHfVFIY=";
    domain = "git.kittencollective.com";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-5V/a6rj08Ucu6S+SBukYQktWLVnnbXeoGan1oYTozHc=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust terminal client for Localsend";
    homepage = "https://git.kittencollective.com/nebkor/joecalsend";
    changelog = "https://git.kittencollective.com/nebkor/joecalsend/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ unfreeRedistributable ];
    maintainers = with lib.maintainers; [ Cameo007 ];
    mainProgram = "jocalsend";
  };
})
