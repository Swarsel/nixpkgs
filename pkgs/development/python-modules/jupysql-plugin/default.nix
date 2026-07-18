{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  jupyterlab,
  ploomber-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupysql-plugin";
  version = "0.4.5";

  # using pypi archive which includes pre-built assets
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-cIXheImO4BL00zn101ZDIzKl2qkIDsTNswZOCs54lNY=";
    pname = "jupysql_plugin";
  };

  # testing requires a circular dependency over jupysql
  doCheck = false;

  build-system = [
    hatchling
    hatch-jupyter-builder
    hatch-nodejs-version
    jupyterlab
  ];

  dependencies = [ ploomber-core ];
  pyproject = true;
  pythonImportsCheck = [ "jupysql_plugin" ];

  meta = {
    description = "Better SQL in Jupyter";
    homepage = "https://github.com/ploomber/jupysql-plugin";
    changelog = "https://github.com/ploomber/jupysql-plugin/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ euxane ];
  };
})
