{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fetchpatch,
  glew,
  glfw2,
  libGL,
  libGLU,
  libglut,
  libx11,
  libxi,
  libxmu,
  libxrandr,
  xorgproto,
}:

stdenv.mkDerivation rec {
  pname = "chipmunk";
  version = "${majorVersion}.0.3";

  src = fetchurl {
    url = "https://chipmunk-physics.net/release/Chipmunk-${majorVersion}.x/Chipmunk-${version}.tgz";
    sha256 = "06j9cfxsyrrnyvl7hsf55ac5mgff939mmijliampphlizyg0r2q4";
  };

  patches = [
    (fetchpatch {
      sha256 = "0ps8bjba1k544vcdx5w0qk7gcjq94yfigxf67j50s63yf70k2n70";
      url = "https://github.com/slembcke/Chipmunk2D/commit/9a051e6fb970c7afe09ce2d564c163b81df050a8.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libglut
    libGLU
    libGL
    glfw2
    glew
    libx11
    xorgproto
    libxi
    libxmu
    libxrandr
  ];

  postInstall = ''
    mkdir -p $out/bin
    cp demo/chipmunk_demos $out/bin
  '';

  majorVersion = "7";

  meta = {
    description = "Fast and lightweight 2D game physics library";
    homepage = "http://chipmunk2d.net/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix; # supports Windows and MacOS as well, but those require more work
    mainProgram = "chipmunk_demos";
  };
}
