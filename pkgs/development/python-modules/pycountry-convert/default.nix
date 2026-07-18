{
  lib,
  buildPythonPackage,
  fetchPypi,
  pycountry,
  repoze-lru,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycountry-convert";
  version = "0.7.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CV0xD3Rr8qXvcTs6gu6iiicmIoYiN2Wx576KXE+n6bk=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  propagatedBuildInputs = [
    pycountry
    repoze-lru
  ];

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pycountry_convert" ];

  pythonRemoveDeps = [
    "pprintpp"
    "pytest"
    "pytest-cov"
    "repoze-lru"
    "pytest-mock"
  ];

  meta = {
    description = "Python conversion functions between ISO country codes, countries, and continents";
    homepage = "https://github.com/jefftune/pycountry-convert";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
