{
  lib,
  stdenv,
  cmake,
  fetchgit,
  libGL,
  libGLU,
  libx11,
}:

stdenv.mkDerivation rec {
  pname = "glee";
  version = "20170205-${lib.strings.substring 0 7 rev}";

  src = fetchgit {
    inherit rev;
    url = "https://git.code.sf.net/p/glee/glee";
    sha256 = "13mf3s7nvmj26vr2wbcg08l4xxqsc1ha41sx3bfghvq8c5qpk2ph";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 2.8)' \
      'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libGLU
    libGL
    libx11
  ];

  preInstall = ''
    sed -i 's/readme/Readme/' cmake_install.cmake
  '';

  configureScript = ''
    cmake
  '';

  rev = "f727ec7463d514b6279981d12833f2e11d62b33d";

  meta = {
    description = "GL Easy Extension Library";
    homepage = "https://sourceforge.net/p/glee/glee/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ crertel ];
    platforms = lib.platforms.linux;
  };
}
