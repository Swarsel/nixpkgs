{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  fontFaceCache ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plutovg";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutovg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JP/nNHszTABIat79vcUqFdtv+/Z13D28aYKEt7BALCw=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "PLUTOVG_DISABLE_FONT_FACE_CACHE_LOAD" (!fontFaceCache))
    # the cmake package does not handle absolute CMAKE_INSTALL_INCLUDEDIR correctly
    # (setting it to an absolute path causes include files to go to $out/$out/include,
    #  because the absolute path is interpreted with root at $out).
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "plutovg" ];
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };
  };

  meta = {
    description = "Tiny 2D vector graphics library in C";
    homepage = "https://github.com/sammycage/plutovg/";
    changelog = "https://github.com/sammycage/plutovg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.eymeric ];
    pkgConfigModules = [ "plutovg" ];
  };
})
