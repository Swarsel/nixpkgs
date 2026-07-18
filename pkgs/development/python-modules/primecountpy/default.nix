{
  lib,
  buildPythonPackage,
  cysignals,
  cython,
  fetchPypi,
  meson-python,
  pkg-config,
  primecount,
  # Reverse dependency
  sage,
}:

buildPythonPackage rec {
  pname = "primecountpy";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-iIcGq2XMCJ+5g95GOTYN3ccouqTZh3p62LEW9kVlCzk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ primecount ];

  propagatedBuildInputs = [
    cysignals
  ];

  # depends on pytest-cython for "pytest --doctest-cython"
  doCheck = false;

  build-system = [
    meson-python
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "primecountpy" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Cython interface for C++ primecount library";
    homepage = "https://github.com/dimpase/primecountpy/";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.sage ];
  };
}
