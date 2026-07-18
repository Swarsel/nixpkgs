{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  glib,
  gobject-introspection,
  libqalculate,
  meson,
  ninja,
  pkg-config,
  rofi-unwrapped,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-calc";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "svenstaro";
    repo = "rofi-calc";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-adDHONoLQeZP4Oi7yx/tSAaMHAaipj2UrG+xZz7EiQ4=";
  };

  postPatch = ''
    substituteInPlace src/calc.c --replace-fail \
      "qalc_binary = \"qalc\"" \
      "qalc_binary = \"${lib.getExe libqalculate}\""

    substituteInPlace src/meson.build --replace-fail \
      "rofi.get_variable('pluginsdir')" \
      "'$out/lib/rofi'"
  '';

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    wrapGAppsHook3
    meson
    ninja
  ];

  buildInputs = [
    rofi-unwrapped
    libqalculate
    glib
    cairo
  ];

  mesonBuildType = "release";

  meta = {
    description = "Do live calculations in rofi";
    homepage = "https://github.com/svenstaro/rofi-calc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ albakham ];
    platforms = with lib.platforms; linux;
  };
})
