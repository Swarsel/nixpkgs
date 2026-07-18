{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "reason";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "jaywonchung";
    repo = "reason";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oytRquZJgb1sfpZil1bSGwIIvm+5N4mkVmIMzWyzDco=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-LXVP8cAbPCPCE3DNBX2znyFn/E/cN2civX0qT0B5FVw=";

  meta = {
    description = "Shell for research papers";
    homepage = "https://github.com/jaywonchung/reason";
    changelog = "https://github.com/jaywonchung/reason/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "reason";
  };
})
