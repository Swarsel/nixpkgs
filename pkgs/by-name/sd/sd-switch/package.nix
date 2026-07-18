{
  lib,
  fetchFromSourcehut,
  nix-update-script,
  rustPlatform,
}:

let
  version = "0.6.4";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "sd-switch";

  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = "sd-switch";
    rev = version;
    hash = "sha256-OtxoAo+S8iuVa2jhschSQCVQ51fy80zIlYAuZvPpbBw=";
  };

  cargoHash = "sha256-SEh9Me4Bkxv4T6R31VEBtzutpbfR+PtQXH7PmOfWeuc=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Systemd unit switcher for Home Manager";
    homepage = "https://git.sr.ht/~rycee/sd-switch";
    changelog = "https://git.sr.ht/~rycee/sd-switch/refs/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rycee ];
    platforms = lib.platforms.linux;
    mainProgram = "sd-switch";
  };
}
