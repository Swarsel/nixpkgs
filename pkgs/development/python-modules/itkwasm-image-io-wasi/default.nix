{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  importlib-resources,
  itkwasm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "itkwasm-image-io-wasi";
  version = "1.6.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-g3w/OPU9N1GxJkW9kKrOvGtVPRVb6zTy5n2nB5WU7+Q=";
    pname = "itkwasm_image_io_wasi";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  # No tests available
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    importlib-resources
    itkwasm
  ];

  pyproject = true;
  pythonImportsCheck = [ "itkwasm_image_io_wasi" ];

  meta = {
    description = "Input and output for scientific and medical image file formats";
    homepage = "https://pypi.org/project/itkwasm-image-io-wasi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
