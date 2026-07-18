{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plog";
  version = "1.1.11";

  src = fetchFromGitHub {
    owner = "SergiusTheBest";
    repo = "plog";
    rev = finalAttrs.version;
    hash = "sha256-/H7qNL6aPjmFYk0X1sx4CCSZWrAMQgPo8I9X/P50ln0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DPLOG_BUILD_SAMPLES=NO"
  ];

  meta = {
    description = "Portable, simple and extensible C++ logging library";
    homepage = "https://github.com/SergiusTheBest/plog";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      raphaelr
      erdnaxe
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
