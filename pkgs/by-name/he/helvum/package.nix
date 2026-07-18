{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "helvum";
  version = "0.6.2";

  src = fetchFromGitLab {
    owner = "pipewire";
    repo = "helvum";
    rev = version;
    hash = "sha256-fDsVYFJ2fm5dLpcCp7Pm4s3+jqTx4r9IQokoVQ0sM04=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    rustPlatform.bindgenHook
    wrapGAppsHook4
  ];

  buildInputs = [
    desktop-file-utils
    glib
    gtk4
    libadwaita
    pipewire
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-cpRPJap/U20vkfShuTav10IoPIxDKueviFKTDM4jrGs=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK patchbay for pipewire";
    homepage = "https://gitlab.freedesktop.org/pipewire/helvum";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fufexan
      luminarleaf
    ];

    platforms = lib.platforms.linux;
    mainProgram = "helvum";
  };
}
