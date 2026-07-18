{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxcb,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  patches,
  xcbutilxrm,
}:

stdenv.mkDerivation rec {
  # Allow users set their own list of patches
  inherit patches;
  pname = "2bwm";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "venam";
    repo = "2bwm";
    rev = "v${version}";
    sha256 = "1xwib612ahv4rg9yl5injck89dlpyp5475xqgag0ydfd0r4sfld7";
  };

  buildInputs = [
    libxcb
    libxcb-keysyms
    libxcb-wm
    libx11
    libxcb-util
    xcbutilxrm
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  installPhase = "make install DESTDIR=$out PREFIX=\"\"";

  meta = {
    description = "Fast floating WM written over the XCB library and derived from mcwm";
    homepage = "https://github.com/venam/2bwm";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
  };
}
