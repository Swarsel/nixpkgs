{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simdjson";
  version = "4.6.4";

  src = fetchFromGitHub {
    owner = "simdjson";
    repo = "simdjson";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8oQzsR7DSaNTN9su1uI9tRQ9HvOwXShPwSrnQj8+lGM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "SIMDJSON_DEVELOPER_MODE" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ]
  ++ lib.optionals (with stdenv.hostPlatform; isPower && isBigEndian) [
    # Assume required CPU features are available, since otherwise we
    # just get a failed build.
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-mpower8-vector")
  ];

  meta = {
    description = "Parsing gigabytes of JSON per second";
    homepage = "https://simdjson.org/";
    changelog = "https://github.com/simdjson/simdjson/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chessai ];
    platforms = lib.platforms.all;
  };
})
