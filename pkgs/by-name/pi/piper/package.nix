{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  appstream-glib,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "piper";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "libratbag";
    repo = "piper";
    rev = finalAttrs.version;
    hash = "sha256-j58fL6jJAzeagy5/1FmygUhdBm+PAlIkw22Rl/fLff4=";
  };

  postPatch = ''
    chmod +x meson_install.sh # patchShebangs requires executable file
    patchShebangs meson_install.sh data/generate-piper-gresource.xml.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
    appstream-glib
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    glib
    adwaita-icon-theme
    python3
    librsvg
  ];

  propagatedBuildInputs = with python3.pkgs; [
    lxml
    evdev
    pygobject3
  ];

  mesonFlags = [
    "-Druntime-dependency-checks=false"
  ];

  pyproject = false;

  meta = {
    description = "GTK frontend for ratbagd mouse config daemon";
    homepage = "https://github.com/libratbag/piper";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
    mainProgram = "piper";
  };
})
