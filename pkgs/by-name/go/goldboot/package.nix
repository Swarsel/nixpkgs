{
  lib,
  fetchFromGitHub,
  OVMF,
  nix-update-script,
  openssl,
  pkg-config,
  qemu,
  qemu-utils,
  rustPlatform,
  versionCheckHook,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "goldboot";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "fossable";
    repo = "goldboot";
    rev = "goldboot-v${finalAttrs.version}";
    hash = "sha256-O9yhyJZpjQxC0HP43RsOgPMOKp6d23SNhMLiGtmwXzs=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    zstd
    OVMF
    qemu
    qemu-utils
    openssl
  ];

  cargoHash = "sha256-NF0Fj+r6qWcM4VEIm1fzveZuz6MIaG32Z+zBfSMC/t4=";
  # Tests require networking, so skip them for now
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "goldboot";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Immutable infrastructure for the desktop";
    homepage = "https://github.com/fossable/goldboot";
    changelog = "https://github.com/fossable/goldboot/releases/tag/goldboot-v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ cilki ];
    platforms = lib.platforms.unix;
    mainProgram = "goldboot";
  };
})
