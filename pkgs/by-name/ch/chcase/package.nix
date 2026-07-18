{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chcase";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "ryonakano";
    repo = "chcase";
    tag = finalAttrs.version;
    hash = "sha256-nvvfmw4tM3LuBAg503wu+EPg6iOLgd5XJ/ncdonbGnA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    blueprint-compiler
  ];

  meta = {
    description = "Small library to convert case of a given string";
    homepage = "https://github.com/ryonakano/chcase";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
