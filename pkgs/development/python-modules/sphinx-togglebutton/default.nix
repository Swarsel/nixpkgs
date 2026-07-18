{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  setuptools,
  sphinx,
  wheel,
}:

buildPythonPackage rec {
  pname = "sphinx-togglebutton";
  version = "0.4.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-yHDfvTvG4Rm1D/mjemT4mRkCJp6FZyiTHH2Jh36NSz0=";
    pname = "sphinx_togglebutton";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    docutils
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_togglebutton" ];

  meta = {
    description = "Toggle page content and collapse admonitions in Sphinx";
    homepage = "https://github.com/executablebooks/sphinx-togglebutton";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
