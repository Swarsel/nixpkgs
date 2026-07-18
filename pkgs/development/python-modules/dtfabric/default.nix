{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "dtfabric";
  version = "20260506";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-n/z2OD3vZrEKoYC3eRVIx6XpgKwTbTaKqp2O2cg11fs=";
  };

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} run_tests.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "dtfabric" ];
  pythonRemoveDeps = [ "pip" ];

  meta = {
    description = "Project to manage data types and structures, as used in the libyal projects";
    homepage = "https://github.com/libyal/dtfabric";
    changelog = "https://github.com/libyal/dtfabric/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jayrovacsek ];
    downloadPage = "https://github.com/libyal/dtfabric/releases";
  };
})
