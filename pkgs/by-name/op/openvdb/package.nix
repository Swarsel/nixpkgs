{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  c-blosc,
  cmake,
  jemalloc,
  onetbb,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openvdb";
  version = "12.1.0";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "openvdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-28vrIlruPl1tvw2JhjIAARtord45hqCqnA9UNnu4Z70=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    onetbb
    jemalloc
    c-blosc
    zlib
  ];

  cmakeFlags = [
    "-DOPENVDB_CORE_STATIC=OFF"
    "-DOPENVDB_BUILD_NANOVDB=ON"
  ];

  postFixup = ''
    substituteInPlace $dev/lib/cmake/OpenVDB/FindOpenVDB.cmake \
      --replace \''${OPENVDB_LIBRARYDIR} $out/lib \
      --replace \''${OPENVDB_INCLUDEDIR} $dev/include
  '';

  meta = {
    description = "Open framework for voxel";
    homepage = "https://www.openvdb.org";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.guibou ];
    platforms = lib.platforms.unix;
    mainProgram = "vdb_print";
  };
})
