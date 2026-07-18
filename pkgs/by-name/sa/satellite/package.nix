{
  lib,
  fetchFromCodeberg,
  gobject-introspection,
  libadwaita,
  modemmanager,
  nix-update-script,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "satellite";
  version = "0.9.2";

  src = fetchFromCodeberg {
    owner = "tpikonen";
    repo = "satellite";
    tag = finalAttrs.version;
    hash = "sha256-DubLxsqJsvCbfFD9jNkKHGd2Ur/bT7Ea5bHLijciwtI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    modemmanager
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    gpxpy
    pygobject3
    pynmea2
  ];

  pyproject = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Program for showing navigation satellite data";

    longDescription = ''
      Satellite is an adaptive GTK3 / libhandy application which displays global navigation satellite system (GNSS: GPS et al.) data obtained from ModemManager or gnss-share.
      It can also save your position to a GPX-file.
    '';

    homepage = "https://codeberg.org/tpikonen/satellite";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Luflosi ];
    platforms = lib.platforms.linux;
    mainProgram = "satellite";
  };
})
