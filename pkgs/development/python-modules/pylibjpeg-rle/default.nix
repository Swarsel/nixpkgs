{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  numpy,
  pydicom,
  pylibjpeg-data,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "pylibjpeg-rle";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "pydicom";
    repo = "pylibjpeg-rle";
    tag = "v${version}";
    hash = "sha256-hAtseH4akBCKhlWsPGXeQRYUK0BiytFrLFCmeg7nUXY=";
  };

  nativeCheckInputs = [
    pydicom
    pylibjpeg-data
    pytestCheckHook
  ];

  preCheck = ''
    mv rle/tests .
    rm -r rle
  '';

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-QprjrR/AelrC+6n7uWZicO9QH0OAJCR7DSE1JuQOMCI=";
  };

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "rle"
    "rle.rle"
    "rle.utils"
  ];

  meta = {
    description = "Fast DICOM RLE plugin for pylibjpeg";
    homepage = "https://github.com/pydicom/pylibjpeg-rle";
    changelog = "https://github.com/pydicom/pylibjpeg-rle/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
