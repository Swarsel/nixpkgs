{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libGL,
  libGLU,
  libglut,
  libx11,
  libxext,
  libxi,
  libxmu,
  libxt,
}:

stdenv.mkDerivation rec {
  pname = "gle";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "linas";
    repo = "glextrusion";
    tag = "${pname}-${version}";
    sha256 = "sha256-yvCu0EOwxOMN6upeHX+C2sIz1YVjjB/320g+Mf24S6g=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libGLU
    libGL
    libglut
    libx11
    libxt
    libxmu
    libxi
    libxext
  ];

  meta = {
    description = "Tubing and extrusion library";
    homepage = "https://www.linas.org/gle/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
  };
}
