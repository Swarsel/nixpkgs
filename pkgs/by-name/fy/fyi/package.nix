{
  lib,
  stdenv,
  dbus,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fyi";
  version = "1.0.4";

  src = fetchFromCodeberg {
    owner = "dnkl";
    repo = "fyi";
    rev = finalAttrs.version;
    hash = "sha256-UGkShHziREQTkQUlbFXT1144BiBApFVbCvu5A1DuoMI=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    scdoc
  ];

  buildInputs = [ dbus ];
  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Command line utility to create desktop notifications";
    homepage = "https://codeberg.org/dnkl/fyi";
    changelog = "https://codeberg.org/dnkl/fyi/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ marnym ];
    platforms = lib.platforms.linux;
    mainProgram = "fyi";
  };
})
