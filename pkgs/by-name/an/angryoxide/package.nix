{
  lib,
  fetchFromGitHub,
  libxkbcommon,
  pkg-config,
  rustPlatform,
  sqlite,
  wayland,
  zlib,
}:

let
  libwifi = fetchFromGitHub {
    hash = "sha256-2X/TZyLX9Tb54c6Sdla4bsWdq05NU72MVSuPvNfxySk=";
    owner = "Ragnt";
    repo = "libwifi";
    rev = "71268e1898ad88b8b5d709e186836db417b33e81";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "angryoxide";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "Ragnt";
    repo = "AngryOxide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OMNpAp+SmwFlNFlsL3DVgUYja+4o26B7AbR8JMz/4JA=";
  };

  postPatch = ''
    rm -r libs/libwifi
    ln -s ${libwifi} libs/libwifi
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
    sqlite
    wayland
    zlib
  ];

  cargoHash = "sha256-dktJEcX4IbhwDyfptA6PZaAcvF6RRC+jWTspnHaof4s=";

  meta = {
    description = "802.11 Attack Tool";
    homepage = "https://github.com/Ragnt/AngryOxide/";
    changelog = "https://github.com/Ragnt/AngryOxide/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fvckgrimm ];
    platforms = lib.platforms.linux;
    mainProgram = "angryoxide";
  };
})
