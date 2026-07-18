{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  itkwasm,
  itkwasm-downsample-emscripten,
  itkwasm-downsample-wasi,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "itkwasm-downsample";
  version = "1.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-tKkct5+39p5jM/vBj3RTSM1YZZoLnajh85Eon4/wavs=";
    pname = "itkwasm_downsample";
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
    itkwasm-downsample-emscripten
    itkwasm-downsample-wasi
  ];

  pyproject = true;
  pythonImportsCheck = [ "itkwasm_downsample" ];

  meta = {
    description = "Pipelines for downsampling images";
    homepage = "https://pypi.org/project/itkwasm-downsample";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
