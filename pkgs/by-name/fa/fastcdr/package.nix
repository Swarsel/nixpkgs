{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  graphviz-nox,
  gtest,
  withDocs ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastcdr";
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Fast-CDR";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s0cIb/83dD5W8vN/2bEBxRD35NpfCSHEpsJQjtr94aE=";
  };

  outputs = [ "out" ] ++ lib.optional withDocs "doc";

  patches = [
    ./0001-Do-not-require-wget-and-unzip.patch
  ];

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals withDocs [
    doxygen
    graphviz-nox
  ];

  cmakeFlags =
    lib.optional (stdenv.hostPlatform.isStatic) "-DBUILD_SHARED_LIBS=OFF"
    # upstream turns BUILD_TESTING=OFF by default and doesn't honor cmake's default (=ON)
    ++ lib.optional (finalAttrs.finalPackage.doCheck) "-DBUILD_TESTING=ON"
    ++ lib.optional withDocs "-DBUILD_DOCUMENTATION=ON";

  doCheck = true;
  checkInputs = [ gtest ];

  meta = {
    description = "Serialization library for OMG's Common Data Representation (CDR)";

    longDescription = ''
      A C++ library that provides two serialization mechanisms. One is the
      standard CDR serialization mechanism, while the other is a faster
      implementation that modifies the standard.
    '';

    homepage = "https://github.com/eProsima/Fast-CDR";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ panicgh ];
    platforms = lib.platforms.unix;
  };
})
