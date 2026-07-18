{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  alsa-lib,
  fetchpatch2,
  freetype,
  glew,
  libGL,
  libogg,
  libpng,
  libtheora,
  libvorbis,
  libx11,
  pkg-config,
  python3,
  tcl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openmsx";
  version = "20_0";

  src = fetchFromGitHub {
    owner = "openMSX";
    repo = "openMSX";
    tag = "RELEASE_${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-iY+oZ7fHZnnEGunM4kOxOGH2Biqj2PfdLhbT8J4mYrA=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-3wmUJQrM5P3zfFJt+HF32AchNSqCgFTnQ508Bztg4uA=";
      name = "fix_view_operator.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/fix_view_operator.patch?h=openmsx&id=aa63ce478c7f528d60b79bcf4c9427101caa3b94";
    })
  ];

  postPatch = ''
    cp ${./custom-nix.mk} build/custom.mk
  '';

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_ttf
    libx11
    alsa-lib
    freetype
    glew
    libGL
    libogg
    libpng
    libtheora
    libvorbis
    tcl
    zlib
  ];

  # Many thanks @mthuurne from OpenMSX project for providing support to
  # Nixpkgs! :)
  env.TCL_CONFIG = "${tcl}/lib/";
  dontAddPrefix = true;

  meta = {
    description = "MSX emulator that aims for perfection";

    longDescription = ''
      OpenMSX is an emulator for the MSX home computer system. Its goal is
      to emulate all aspects of the MSX with 100% accuracy.
    '';

    homepage = "https://openmsx.org";

    license = with lib.licenses; [
      bsd2
      boost
      gpl2Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "openmsx";
  };
})
