{
  lib,
  stdenv,
  fetchFromGitLab,
  adwaita-icon-theme,
  gtkmm4,
  intltool,
  json-glib,
  libcanberra-gtk3,
  libpulseaudio,
  libsigcxx,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  # Since version 6.1, libcanberra is optional
  withLibcanberra ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pavucontrol";
  version = "6.2";

  src = fetchFromGitLab {
    owner = "pulseaudio";
    repo = "pavucontrol";
    tag = "v${finalAttrs.version}";
    hash = "sha256-If76Qt2BFgGMYt2PSzDQWmNPsbzneZ6zW9yYnS3lo84=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
    wrapGAppsHook4
    meson
    ninja
  ];

  buildInputs = [
    libpulseaudio
    gtkmm4
    libsigcxx
    (lib.optionals withLibcanberra libcanberra-gtk3)
    json-glib
    adwaita-icon-theme
  ];

  mesonFlags = [
    "--prefix=${placeholder "out"}"
    (lib.mesonEnable "lynx" false)
  ];

  enableParallelBuilding = true;

  meta = {
    description = "PulseAudio Volume Control";

    longDescription = ''
      PulseAudio Volume Control (pavucontrol) provides a GTK
      graphical user interface to connect to a PulseAudio server and
      easily control the volume of all clients, sinks, etc.
    '';

    homepage = "http://freedesktop.org/software/pulseaudio/pavucontrol/";
    changelog = "https://freedesktop.org/software/pulseaudio/pavucontrol/#news";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "pavucontrol";
  };
})
