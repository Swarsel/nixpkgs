{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  desktop-file-utils,
  gjs,
  gobject-introspection,
  gsound,
  gst_all_1,
  libadwaita,
  libgda6,
  libportal-gtk4,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation {
  pname = "pomodoro-gtk";
  version = "1.4.1";

  src = fetchFromGitLab {
    owner = "idevecore";
    repo = "pomodoro";
    rev = "44b724557539084991f3eb55b9593053a2c73eba"; # author didn't make a tag
    hash = "sha256-krVRVMrrzuqPY/3P9dCz7rVCCW7/j5cpT95XniGpBEs=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs --build troll/gjspack/bin/gjspack
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gjs # runtime for gjspack
    gobject-introspection
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    gjs
    libadwaita
    libgda6
    gsound
    gst_all_1.gst-plugins-base
    libportal-gtk4
  ];

  meta = {
    description = "Simple and intuitive timer application (also named Planytimer)";
    homepage = "https://gitlab.com/idevecore/pomodoro";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "pomodoro";
  };
}
