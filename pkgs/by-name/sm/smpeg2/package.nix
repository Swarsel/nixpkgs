{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoconf,
  automake,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "smpeg2";
  version = "unstable-2022-05-26";

  src = fetchFromGitHub {
    owner = "icculus";
    repo = "smpeg";
    rev = "c5793e5f3f2765fc09c24380d7e92136a0e33d3b";
    sha256 = "sha256-Z0u83K1GIXd0jUYo5ZyWUH2Zt7Hn8z+yr06DAtAEukw=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    autoconf
    automake
    makeWrapper
    pkg-config
  ];

  buildInputs = [ SDL2 ];

  preConfigure = ''
    sh autogen.sh
  '';

  postInstall = ''
    moveToOutput bin/smpeg2-config "$dev"
    wrapProgram $dev/bin/smpeg2-config \
      --prefix PATH ":" "${pkg-config}/bin" \
      --prefix PKG_CONFIG_PATH ":" "${lib.getDev SDL2}/lib/pkgconfig"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "SDL2 MPEG Player Library";
    homepage = "https://icculus.org/smpeg/";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
