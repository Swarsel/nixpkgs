{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustmission";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "intuis";
    repo = "rustmission";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vQ6MBbzmOBgD1kcF62NmQys737QEN9isvFN7L7mP8mk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-GwSf/o90RO6LURIcm/kYA8oXmnCJ1OkM+eHkyZduOt0=";
  # There is no tests
  doCheck = false;

  meta = {
    description = "TUI for the Transmission daemon";
    homepage = "https://github.com/intuis/rustmission";
    changelog = "https://github.com/intuis/rustmission/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "rustmission";
  };
})
