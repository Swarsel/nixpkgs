{
  lib,
  astunparse,
  build,
  buildPythonPackage,
  execnb,
  fastcore,
  fastgit,
  fetchPypi,
  ghapi,
  ipywidgets,
  pyyaml,
  setuptools,
  watchdog,
}:

buildPythonPackage (finalAttrs: {
  pname = "nbdev";
  version = "3.0.15";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-CSpEJr8IYUFa54VGdPy0p8erNh5qKrGBTsfNYvE3uIo=";
  };

  # no real tests
  doCheck = false;

  build-system = [
    build
    setuptools
  ];

  dependencies = [
    astunparse
    execnb
    fastcore
    fastgit
    ghapi
    ipywidgets
    pyyaml
    watchdog
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbdev" ];
  pythonRelaxDeps = [ "ipywidgets" ];

  meta = {
    description = "Create delightful software with Jupyter Notebooks";
    homepage = "https://github.com/AnswerDotAI/nbdev";
    changelog = "https://github.com/AnswerDotAI/nbdev/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rxiao ];
  };
})
