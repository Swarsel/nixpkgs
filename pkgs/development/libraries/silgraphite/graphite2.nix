{
  lib,
  stdenv,
  fetchurl,
  cmake,
  freetype,
  llvmPackages,
  pkg-config,
  python3,
  testers,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "graphite2";
  version = "1.3.15";

  src = fetchurl {
    url =
      with finalAttrs;
      "https://github.com/silnrsi/graphite/releases/download/${version}/${pname}-${version}.tgz";

    hash = "sha256-xryLQlJyRmUpf3ytDFWJcoXGc/m45ts1IqzoM1k/4LE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./macosx.patch ];

  postPatch = ''
    # disable broken 'nametabletest' test, fails on gcc-13:
    #   https://github.com/silnrsi/graphite/pull/74
    substituteInPlace tests/CMakeLists.txt \
      --replace 'add_subdirectory(nametabletest)' '#add_subdirectory(nametabletest)'

    # support cross-compilation by using target readelf binary:
    substituteInPlace Graphite.cmake \
      --replace 'readelf' "${stdenv.cc.targetPrefix}readelf"

    # headers are located in the dev output:
    substituteInPlace CMakeLists.txt \
      --replace-fail ' ''${CMAKE_INSTALL_PREFIX}/include' " ${placeholder "dev"}/include"
  '';

  nativeBuildInputs = [
    pkg-config
    (python3.withPackages (ps: [ ps.fonttools ]))
    cmake
  ];

  buildInputs = [
    freetype
  ]
  ++ lib.optional (stdenv.targetPlatform.useLLVM or false) (
    llvmPackages.compiler-rt.override {
      doFakeLibgcc = true;
    }
  );

  cmakeFlags = lib.optionals static [
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  # Remove a test that fails to statically link (undefined reference to png and
  # freetype symbols)
  postConfigure = lib.optionalString static ''
    sed -e '/freetype freetype.c/d' -i ../tests/examples/CMakeLists.txt
  '';

  doCheck = true;

  passthru.tests = {
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Advanced font engine";
    homepage = "https://graphite.sil.org/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "gr2fonttest";
    pkgConfigModules = [ "graphite2" ];
  };
})
