{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  tempora,
}:

buildPythonPackage rec {
  pname = "jaraco-logging";
  version = "3.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-59bcg2hHfOaesdbthR2AWJahypQs4/0Xc1gDEbC3dfs=";
    pname = "jaraco_logging";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ tempora ];
  # test no longer packaged with pypi
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "jaraco.logging" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Support for Python logging facility";
    homepage = "https://github.com/jaraco/jaraco.logging";
    changelog = "https://github.com/jaraco/jaraco.logging/blob/v${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
