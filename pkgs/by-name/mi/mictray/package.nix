{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  libgee,
  libnotify,
  meson,
  ninja,
  pkg-config,
  pulseaudio,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "mictray";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "Junker";
    repo = "mictray";
    rev = "1f879aeda03fbe87ae5a761f46c042e09912e1c0";
    sha256 = "0achj6r545c1sigls79c8qdzryz3sgldcyzd3pwak1ymim9i9c74";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libgee
    libnotify
    pulseaudio
  ];

  doCheck = true;

  meta = {
    description = "System tray application for microphone";

    longDescription = ''
      MicTray is a Lightweight system tray application which lets you control the microphone state and volume.
    '';

    homepage = "https://github.com/Junker/mictray";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.anpryl ];
    platforms = lib.platforms.linux;
    mainProgram = "mictray";
  };
}
