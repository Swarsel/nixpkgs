{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxpm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xosview";
  version = "1.25";

  src = fetchFromGitHub {
    owner = "hills";
    repo = "xosview";
    rev = finalAttrs.version;
    hash = "sha256-lAVMpdVeYENtJrnRiCVgMbti7fKdQusTBsNCVdJZJkA=";
  };

  outputs = [
    "out"
    "man"
  ];

  buildInputs = [
    libx11
    libxpm
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "PLATFORM=linux"
  ];

  dontConfigure = true;

  meta = {
    description = "Classic system monitoring tool";
    homepage = "http://www.pogo.org.uk/~mark/xosview/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "xosview";
  };
})
