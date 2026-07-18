{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  cairo,
  cmake,
  ctestCheckHook,
  double-conversion,
  glib,
  gsl,
  gtest,
  inkscape,
  ninja,
  pkg-config,
  pkgsCross,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lib2geom";
  version = "1.4";

  src = fetchFromGitLab {
    owner = "inkscape";
    repo = "lib2geom";
    tag = finalAttrs.version;
    hash = "sha256-kbcnefzNhUj/ZKZaB9r19bpI68vxUKOLVAwUXSr/zz0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    glib
    gsl
    cairo
    double-conversion
  ];

  cmakeFlags = [
    "-D2GEOM_BUILD_SHARED=ON"
    # For cross compilation.
    (lib.cmakeBool "2GEOM_TESTING" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  checkInputs = [
    gtest
  ];

  disabledTests =
    lib.optionals stdenv.hostPlatform.isMusl [
      # Fails due to rounding differences
      # https://gitlab.com/inkscape/lib2geom/-/issues/70
      "circle-test"
    ]
    ++ lib.optionals (stdenv.hostPlatform.system != "x86_64-linux") [
      # Broken on all platforms, test just accidentally passes on some.
      # https://gitlab.com/inkscape/lib2geom/-/issues/63
      "elliptical-arc-test"

      # https://gitlab.com/inkscape/lib2geom/-/issues/69
      "polynomial-test"

      # https://gitlab.com/inkscape/lib2geom/-/issues/75
      "line-test"

      # Failure observed on i686
      "angle-test"
      "self-intersections-test"

      # Failure observed on aarch64-darwin
      "bezier-test"
      "ellipse-test"
    ];

  dontUseNinjaCheck = true;

  passthru = {
    tests = {
      inherit inkscape;
    }
    # Make sure x86_64-linux -> aarch64-linux cross compilation works
    // lib.optionalAttrs (stdenv.buildPlatform.system == "x86_64-linux") {
      aarch64-cross = pkgsCross.aarch64-multiplatform.lib2geom;
    };
  };

  meta = {
    description = "Easy to use 2D geometry library in C++";
    homepage = "https://gitlab.com/inkscape/lib2geom";

    license = [
      lib.licenses.lgpl21Only
      lib.licenses.mpl11
    ];

    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
})
