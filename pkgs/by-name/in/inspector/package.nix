{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  desktop-file-utils,
  gettext,
  gobject-introspection,
  iproute2,
  libadwaita,
  meson,
  ninja,
  pciutils,
  python3Packages,
  usbutils,
  util-linux,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication rec {
  pname = "inspector";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Nokse22";
    repo = "inspector";
    rev = "v${version}";
    hash = "sha256-tjQCF2Tyv7/NWgrwHu+JPpnLECfDmQS77EVLBt+cRTs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    gettext
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
  ];

  dependencies = [
    python3Packages.pygobject3
    iproute2
    util-linux
    coreutils
    usbutils
    pciutils
  ];

  pyproject = false;

  meta = {
    description = "Gtk4 Libadwaita wrapper for various system info cli commands";
    homepage = "https://github.com/Nokse22/inspector";

    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];

    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "inspector";
  };
}
