{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python3,
  validatePkgConfig,
  enableStatic ? stdenv.hostPlatform.isStatic,
  secureMemory ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jsoncpp";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "open-source-parsers";
    repo = "jsoncpp";
    tag = finalAttrs.version;
    hash = "sha256-5cH9G4/TVCM5HX6QSk3P4m5+cwuK4x8hP9FohBcmjik=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
    validatePkgConfig
  ];

  cmakeFlags = [
    "-DJSONCPP_USE_SECURE_MEMORY=${if secureMemory then "ON" else "OFF"}"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_OBJECT_LIBS=OFF"
    "-DJSONCPP_WITH_CMAKE_PACKAGE=ON"
    "-DBUILD_STATIC_LIBS=${if enableStatic then "ON" else "OFF"}"
  ]
  # the test's won't compile if secureMemory is used because there is no
  # comparison operators and conversion functions between
  # std::basic_string<..., Json::SecureAllocator<char>> vs.
  # std::basic_string<..., [default allocator]>
  ++ lib.optional (
    (stdenv.buildPlatform != stdenv.hostPlatform) || secureMemory
  ) "-DJSONCPP_WITH_TESTS=OFF";

  __structuredAttrs = true;

  /*
    During darwin bootstrap, we have a cp that doesn't understand the
    --reflink=auto flag, which is used in the default unpackPhase for dirs
  */
  unpackPhase = ''
    cp -a ${finalAttrs.src} ${finalAttrs.src.name}
    chmod -R +w ${finalAttrs.src.name}
    export sourceRoot=${finalAttrs.src.name}
  '';

  meta = {
    description = "C++ library for interacting with JSON";
    homepage = "https://github.com/open-source-parsers/jsoncpp";
    changelog = "https://github.com/open-source-parsers/jsoncpp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = lib.platforms.all;
  };
})
