{
  lib,
  stdenv,
  fetchFromCodeberg,
  glib,
  libqmi,
  meson,
  ninja,
  pkg-config,
  protobuf,
  protobufc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libssc";
  version = "0.2.2";

  src = fetchFromCodeberg {
    owner = "DylanVanAssche";
    repo = "libssc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vc3phLAURKXAVD/o4uiGkBtJ3wsbLEfkwygMltEhqug=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    protobuf
    protobufc
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    glib
    protobufc
  ];

  propagatedBuildInputs = [
    libqmi
  ];

  meta = {
    description = "Library for exposing Qualcomm Sensor Core sensors to Linux";
    homepage = "https://codeberg.org/DylanVanAssche/libssc";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.all;
    mainProgram = "libssc";
  };
})
