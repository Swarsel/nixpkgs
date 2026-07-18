{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glm,
  icu,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  libwebp,
  libx11,
  libxcomposite,
  libxext,
  libxfixes,
  libxrandr,
  pkg-config,
  slop,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maim";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "naelstrof";
    repo = "maim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bbjV3+41cxAlKCEd1/nvnZ19GhctWOr5Lu4X+Vg3EAk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    zlib
    libpng
    libjpeg
    libwebp
    libGLU
    libGL
    glm
    libx11
    libxext
    libxfixes
    libxrandr
    libxcomposite
    slop
    icu
  ];

  # TODO: drop -DCMAKE_POLICY_VERSION_MINIMUM once maim adds CMake 4 support
  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.10" ];
  doCheck = false;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Command-line screenshot utility";

    longDescription = ''
      maim (make image) takes screenshots of your desktop. It has options to
      take only a region, and relies on slop to query for regions. maim is
      supposed to be an improved scrot.
    '';

    changelog = "https://github.com/naelstrof/maim/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "maim";
  };
})
