{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  # for passthru.tests
  falcon,
  fastapi,
  gradio,
  # native dependencies
  libiconv,
  mashumaro,
  # tests
  numpy,
  psutil,
  pytestCheckHook,
  python-dateutil,
  pytz,
  # build-system
  rustPlatform,
  ufolib2,
  xxhash,
}:

buildPythonPackage rec {
  pname = "orjson";
  version = "3.11.9";

  src = fetchFromGitHub {
    owner = "ijl";
    repo = "orjson";
    tag = version;
    hash = "sha256-CCwpD6pzO80GlMvjJt4HURQxbghYg53OG/6ZIJWggNU=";
  };

  patches = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    # fix architecture checks in build.rs to fix build for riscv
    ./cross-arch-compat.patch
  ];

  nativeBuildInputs = [
    cffi
  ]
  ++ (with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ]);

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  nativeCheckInputs = [
    numpy
    psutil
    pytestCheckHook
    python-dateutil
    pytz
    xxhash
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-F1TFEj26trVV0TjK6tkS8kiorWRF0uijb1jQko7RDSM=";
  };

  pyproject = true;
  pythonImportsCheck = [ "orjson" ];

  passthru.tests = {
    inherit
      falcon
      fastapi
      gradio
      mashumaro
      ufolib2
      ;
  };

  meta = {
    description = "Fast, correct Python JSON library supporting dataclasses, datetimes, and numpy";
    homepage = "https://github.com/ijl/orjson";
    changelog = "https://github.com/ijl/orjson/blob/${version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
