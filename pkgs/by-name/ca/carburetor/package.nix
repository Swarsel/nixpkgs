{
  lib,
  fetchFromGitLab,
  appstream,
  desktop-file-utils,
  fetchpatch2,
  gobject-introspection,
  libadwaita,
  meson,
  pkg-config,
  python3Packages,
  tractor,
  wrapGAppsHook4,
}:
let
  # This package should be updated together with pkgs/by-name/tr/tractor/package.nix
  version = "5.1.1";
in
python3Packages.buildPythonApplication {

  inherit version;
  pname = "carburetor";

  src = fetchFromGitLab {
    owner = "tractor";
    repo = "carburetor";
    tag = version;
    hash = "sha256-mHuD9fxHTmTfEdAsiqTtFVzxXEjD8VIDNDKF2RjcAUg=";
    domain = "framagit.org";
  };

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    gobject-introspection
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [ libadwaita ];

  preFixup = ''
    substituteInPlace $out/share/applications/io.frama.tractor.carburetor.desktop \
      --replace-fail "Exec=gapplication launch io.frama.tractor.carburetor" "Exec=$out/bin/carburetor"
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = [
    meson
    python3Packages.meson-python
  ];

  dependencies = [
    python3Packages.pycountry
    python3Packages.pygobject3
    tractor
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Graphical settings app for Tractor in GTK";
    homepage = "https://framagit.org/tractor/carburetor";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "carburetor";
  };
}
