{
  lib,
  stdenv,
  fetchFromGitHub,
  ilmbase,
  libGL,
  libGLU,
  openexr,
  openfx,
  re2,
  zlib,
}:

stdenv.mkDerivation {
  pname = "openexrid-unstable";
  version = "2017-09-17";

  src = fetchFromGitHub {
    owner = "MercenariesEngineering";
    repo = "openexrid";
    rev = "bec0081548a096f9bcdd1504970c96264b0fc050";
    sha256 = "0h4b74lv59p4hhrvrqdmlnchn2i0v5id4kl8xc7j26l9884q0383";
  };

  outputs = [
    "dev"
    "out"
    "lib"
  ];

  patches = [ ./openexrid.patch ];

  postPatch = ''
    substituteInPlace openexrid/makefile \
        --replace g++ c++
  '';

  buildInputs = [
    re2
    openfx
    zlib
    ilmbase
    libGLU
    libGL
    openexr
  ];

  env.NIX_CFLAGS_COMPILE = ''
    -I${ilmbase.dev}/include/OpenEXR
    -I${openexr.dev}/include/OpenEXR
    -I${openfx.dev}/include/OpenFX
  '';

  buildPhase = ''
    mkdir openexrid/release

    PREFIX=$out make -C openexrid install

    mkdir $dev;
    mkdir $lib;
  '';

  installPhase = ''
    find $out
    mv $out/include $dev/
    mv $out/lib $lib/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "OpenEXR files able to isolate any object of a CG image with a perfect antialiazing";
    homepage = "https://github.com/MercenariesEngineering/openexrid";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.guibou ];
    platforms = lib.platforms.all;
  };
}
