{
  lib,
  buildPythonPackage,
  # dependencies
  hydra-core,
  joblib,
  # test
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  inherit (hydra-core) version src;
  pname = "hydra-joblib-launcher";

  # get rid of deprecated "read_version" dependency, no longer in Nixpkgs:
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail ', "read-version"' ""
    substituteInPlace setup.py  \
      --replace-fail 'from read_version import read_version' ""  \
      --replace-fail 'version=read_version("hydra_plugins/hydra_joblib_launcher", "__init__.py"),' 'version="${finalAttrs.version}",'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    hydra-core
    joblib
  ];

  # _pickle.PicklingError: Could not pickle the task to send it to the workers
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  # tries to write to source directory otherwise:
  pytestFlags = [ "-pno:cacheprovider" ];
  sourceRoot = "${finalAttrs.src.name}/plugins/hydra_joblib_launcher";

  meta = {
    inherit (hydra-core.meta) changelog license;
    description = "Hydra launcher supporting parallel execution based on Joblib.Parallel";
    homepage = "https://hydra.cc/docs/plugins/joblib_launcher";
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
