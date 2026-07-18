{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  curl,
  fetchpatch,
  flex,
  libxml2,
  libxslt,
  perl,
  pkg-config,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation rec {
  pname = "raptor2";
  version = "2.0.16";

  src = fetchFromGitHub {
    owner = "dajobe";
    repo = "raptor";
    rev = "${pname}_${underscoredVersion}";
    sha256 = "sha256-Eic63pV2p154YkSmkqWr86fGTr+XmVGy5l5/6q14LQM=";
  };

  patches = [
    # pull upstream fix for libxml2-2.11 API compatibility, part of unreleased 2.0.17
    #   https://github.com/dajobe/raptor/pull/58
    (fetchpatch {
      hash = "sha256-fHfvncGymzMtxjwtakCNSr/Lem12UPIHAAcAac648w4=";
      name = "libxml2-2.11.patch";
      url = "https://github.com/dajobe/raptor/commit/4dbc4c1da2a033c497d84a1291c46f416a9cac51.patch";
    })
  ];

  # Fix the build with CMake 4.
  #
  # See: <https://github.com/dajobe/raptor/issues/75>
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'CMAKE_MINIMUM_REQUIRED(VERSION 2.8.7)' \
        'CMAKE_MINIMUM_REQUIRED(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
    bison
    flex
  ];

  buildInputs = [
    curl
    libxml2
    libxslt
  ];

  cmakeFlags = [
    # Build defaults to static libraries.
    "-DBUILD_SHARED_LIBS=${if static then "OFF" else "ON"}"
  ];

  underscoredVersion = lib.strings.replaceStrings [ "." ] [ "_" ] version;

  meta = {
    description = "RDF Parser Toolkit";
    homepage = "https://librdf.org/raptor";

    license = with lib.licenses; [
      lgpl21
      asl20
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "rapper";
  };
}
