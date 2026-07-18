{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tuhi";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "tuhiproject";
    repo = "tuhi";
    rev = finalAttrs.version;
    sha256 = "sha256-NwyG2KhOrAKRewgmU23OMO0+A9SjkQZsDL4SGnLVCvo=";
  };

  strictDeps = false;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    appstream-glib
    desktop-file-utils
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    glib
  ];

  propagatedBuildInputs = with python3Packages; [
    svgwrite
    pyxdg
    pycairo
    pygobject3
    setuptools-scm
  ];

  preConfigure = ''
    substituteInPlace meson_install.sh \
      --replace "/usr/bin/env sh" "sh"
  '';

  nativeCheckInputs = with python3Packages; [
    flake8
    pytest
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out ''${pythonPath[*]}"
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "DBus daemon to access Wacom SmartPad devices";
    homepage = "https://github.com/tuhiproject/tuhi";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ lammermann ];
    platforms = lib.platforms.linux;
    mainProgram = "tuhi";
  };
})
