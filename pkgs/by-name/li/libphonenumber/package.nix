{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  buildPackages,
  cmake,
  gtest,
  icu,
  jre,
  pkg-config,
  protobuf,
  enableTests ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libphonenumber";
  version = "9.0.34";

  src = fetchFromGitHub {
    owner = "google";
    repo = "libphonenumber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KWn58r2Dnh9DMwiESmrF/pN5LPuYe0G7z3TeM+Zp6ZA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # An earlier version of this patch was submitted upstream but did not get
    # any interest there - https://github.com/google/libphonenumber/pull/2921
    ./build-reproducibility.patch
    # Fix include directory in generated cmake files with split outputs
    ./cmake-include-dir.patch
    # Finding `boost_system` fails because the stub compiled library of
    # Boost.System, which has been a header-only library since 1.69, was
    # removed in 1.89.
    # Upstream PR: https://github.com/google/libphonenumber/pull/3903
    ./boost-1.89.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ]
  ++ lib.optionals enableTests [
    jre
  ];

  buildInputs = [
    icu
    protobuf
  ]
  ++ lib.optionals enableTests [
    gtest
  ];

  propagatedBuildInputs = lib.optionals enableTests [
    boost
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-Wno-error=deprecated-declarations")
  ]
  ++ lib.optionals (!enableTests) [
    (lib.cmakeBool "REGENERATE_METADATA" false)
    (lib.cmakeBool "USE_BOOST" false)
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    (lib.cmakeFeature "CMAKE_CROSSCOMPILING_EMULATOR" (stdenv.hostPlatform.emulator buildPackages))
    (lib.cmakeFeature "PROTOC_BIN" (lib.getExe buildPackages.protobuf))
  ];

  doCheck = enableTests;
  checkTarget = "tests";
  cmakeDir = "../cpp";

  meta = {
    description = "Google's i18n library for parsing and using phone numbers";
    homepage = "https://github.com/google/libphonenumber";
    changelog = "https://github.com/google/libphonenumber/blob/${finalAttrs.src.rev}/release_notes.txt";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      illegalprime
      wegank
    ];
  };
})
