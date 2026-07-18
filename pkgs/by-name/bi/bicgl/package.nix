{
  lib,
  stdenv,
  fetchFromGitHub,
  bicpl,
  cmake,
  libGLU,
  libglut,
  libminc,
}:

stdenv.mkDerivation rec {
  pname = "bicgl";
  version = "unstable-2018-04-06";

  src = fetchFromGitHub {
    inherit owner;
    repo = "bicgl";
    rev = "61a035751c9244fcca1edf94d6566fa2a709ce90";
    sha256 = "0lzirdi1mf4yl8srq7vjn746sbydz7h0wjh7wy8gycy6hq04qrg4";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libminc
    bicpl
    libGLU
    libglut
  ];

  cmakeFlags = [
    "-DLIBMINC_DIR=${libminc}/lib/cmake"
    "-DBICPL_DIR=${bicpl}/lib"
  ];

  owner = "BIC-MNI";

  meta = {
    description = "Brain Imaging Centre graphics library";
    homepage = "https://github.com/${owner}/bicgl";
    license = lib.licenses.hpndUc;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
}
