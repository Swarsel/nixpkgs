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
  pname = "itkwasm-downsample-emscripten";
  version = "1.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-kF851K6cy1jozPxd5zE8XVnBAHMljmOqtvpmfmQDZy4=";
    pname = "itkwasm_downsample_emscripten";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  # No tests available
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ itkwasm ];
  pyproject = true;
  pythonImportsCheck = [ "itkwasm_downsample_emscripten" ];

  meta = {
    description = "Pipelines for downsampling images";
    homepage = "https://pypi.org/project/itkwasm-downsample-emscripten";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
