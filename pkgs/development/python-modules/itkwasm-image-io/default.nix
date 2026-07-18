{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  itkwasm,
  itkwasm-image-io-emscripten,
  itkwasm-image-io-wasi,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "itkwasm-image-io";
  version = "1.6.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Iwb6Xd+N3P+QsWhhu5q1Dx/joUClNgHBaWrgUalx0V4=";
    pname = "itkwasm_image_io";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  # No tests available
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    itkwasm
    itkwasm-image-io-emscripten
    itkwasm-image-io-wasi
  ];

  pyproject = true;
  pythonImportsCheck = [ "itkwasm_image_io" ];

  meta = {
    description = "Input and output for scientific and medical image file formats";
    homepage = "https://pypi.org/project/itkwasm-image-io";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
