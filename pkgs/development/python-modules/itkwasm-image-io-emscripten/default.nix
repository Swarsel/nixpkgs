{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  itkwasm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "itkwasm-image-io-emscripten";
  version = "1.6.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-lFYLpPM4LVSPANpKGg7WSYrrfvpmE2T1w4igidUUL3I=";
    pname = "itkwasm_image_io_emscripten";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ itkwasm ];
  pyproject = true;
  pythonImportsCheck = [ "itkwasm_image_io_emscripten" ];

  meta = {
    description = "Input and output for scientific and medical image file formats";
    homepage = "https://pypi.org/project/itkwasm-image-io-emscripten";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
