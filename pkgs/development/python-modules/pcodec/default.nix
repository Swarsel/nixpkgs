{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pcodec";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "pcodec";
    repo = "pcodec";
    tag = "v${version}";
    hash = "sha256-fL+UCaQ8GdIe7e4Y7VeaWkjoNwuXXqaW2fHkaWs+1Lw=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  buildAndTestSubdir = "pco_python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-4RRN4gyEQdnpiljxa1kPM2/naarpFrKMoTVLpXD3f4A=";
  };

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "pcodec" ];

  meta = {
    description = "Lossless codec for numerical data";
    homepage = "https://github.com/pcodec/pcodec";
    changelog = "https://github.com/pcodec/pcodec/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      flokli
    ];
  };
}
