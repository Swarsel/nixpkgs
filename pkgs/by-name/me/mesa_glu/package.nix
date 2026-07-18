{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  libGLX,
  meson,
  ninja,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glu";
  version = "9.0.3";

  src =
    let
      inherit (finalAttrs) pname version;
    in
    fetchurl {
      url = "https://mesa.freedesktop.org/archive/glu/glu-${version}.tar.xz";
      hash = "sha256-vUP+EvN0sRkusV/iDkX/RWubwmq1fw7ukZ+Wyg+KMw8=";
    };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [ libGLX ];

  mesonFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-Dgl_provider=gl" # glvnd is default
  ];

  enableParallelBuilding = true;

  passthru = {
    tests = {
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = gitUpdater {
      rev-prefix = "glu-";
      # No nicer place to find latest release.
      url = "https://gitlab.freedesktop.org/mesa/glu";
    };
  };

  meta = {
    description = "OpenGL utility library";
    homepage = "https://cgit.freedesktop.org/mesa/glu/";
    license = lib.licenses.sgi-b-20;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isAndroid;
    pkgConfigModules = [ "glu" ];
  };
})
