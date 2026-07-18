{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  flex,
  libpng,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rgbds";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "gbdev";
    repo = "rgbds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-amTlFuk+j4lupBmXt+2A2XNn3CIqKhar+JfpFFhg834=";
  };

  postPatch = ''
    patchShebangs --host src/bison.sh
  '';

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ];

  buildInputs = [ libpng ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Free assembler/linker package for the Game Boy and Game Boy Color";

    longDescription = ''
      RGBDS (Rednex Game Boy Development System) is a free assembler/linker package for the Game Boy and Game Boy Color. It consists of:

        - rgbasm (assembler)
        - rgblink (linker)
        - rgbfix (checksum/header fixer)
        - rgbgfx (PNG‐to‐Game Boy graphics converter)

      This is a fork of the original RGBDS which aims to make the programs more like other UNIX tools.
    '';

    homepage = "https://rgbds.gbdev.io/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      NieDzejkob
      mattcurrie
    ];

    platforms = lib.platforms.all;
  };
})
