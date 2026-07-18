{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  numpy,
  pytestCheckHook,
  six,
  sphinx,
}:

buildPythonPackage {
  pname = "sphinx-fortran";
  version = "unstable-2022-03-02";

  src = fetchFromGitHub {
    owner = "VACUMM";
    repo = "sphinx-fortran";
    rev = "394ae990b43ed43fcff8beb048632f5e99794264";
    hash = "sha256-IVKu5u9gqs7/9EZrf4ZYd12K6J31u+/B8kk4+8yfohM=";
  };

  propagatedBuildInputs = [
    future
    numpy
    sphinx
    six
  ];

  # Tests are failing because reference files are not updated
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "sphinxfortran" ];

  meta = {
    description = "Fortran domain and autodoc extensions to Sphinx";
    homepage = "http://sphinx-fortran.readthedocs.org/";
    license = lib.licenses.cecill21;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
}
