{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "systemdgenie";
  version = "0.99.0-unstable-2026-07-03";

  src = fetchFromGitLab {
    owner = "system";
    repo = "SystemdGenie";
    rev = "5e30259b7a234291bb0e337c7c9e5b4892304c99";
    hash = "sha256-C6CwoHYqc3GS5xvIJA+Jv2cbe7iw7vqdxwh9Sh67ucw=";
    domain = "invent.kde.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.kirigami-addons
    kdePackages.kio
    kdePackages.ktexteditor
    kdePackages.kxmlgui
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Systemd management utility";
    homepage = "https://kde.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.pasqui23 ];
    platforms = lib.platforms.linux;
    mainProgram = "systemdgenie";
  };
}
