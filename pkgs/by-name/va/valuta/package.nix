{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  gst_all_1,
  gtk4,
  libadwaita,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "valuta";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "ideveCore";
    repo = "Valuta";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1vcjmSXEKy6XTEPV5jiz+ZxzFFUhVnmLK6MDjqoWTHs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gst_all_1.gstreamer
    libsoup_3
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    babel
    dbus-python
    pygobject3
  ];

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple application for converting currencies, with support for various APIs";
    homepage = "https://github.com/ideveCore/Valuta";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "currencyconverter";
    teams = [ lib.teams.gnome-circle ];
  };
})
