{
  lib,
  astropy,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  pytest-astropy,
  pytestCheckHook,
  scipy,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "radio-beam";
  version = "0.3.9";

  src = fetchPypi {
    inherit version;
    hash = "sha256-m1/qe8ybJlQyE3hGM7MugWMMnAhVB3t6v0tGz42E5kQ=";
    pname = "radio_beam"; # Tarball was uploaded with an underscore in this version
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    astropy
    numpy
    scipy
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
    matplotlib
    pytest-astropy
  ];

  pyproject = true;
  pythonImportsCheck = [ "radio_beam" ];

  meta = {
    description = "Tools for Beam IO and Manipulation";
    homepage = "http://radio-astro-tools.github.io";
    changelog = "https://github.com/radio-astro-tools/radio-beam/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ smaret ];
  };
}
