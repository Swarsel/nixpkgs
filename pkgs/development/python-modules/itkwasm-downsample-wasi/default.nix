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
  pname = "itkwasm-downsample-wasi";
  version = "1.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-OykKkZRlRGDw+SsK69z6dqh6LY7eUlyHGdZwmkKsMKQ=";
    pname = "itkwasm_downsample_wasi";
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
  pythonImportsCheck = [ "itkwasm_downsample_wasi" ];

  meta = {
    description = "Pipelines for downsampling images";
    homepage = "https://pypi.org/project/itkwasm-downsample-wasi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
