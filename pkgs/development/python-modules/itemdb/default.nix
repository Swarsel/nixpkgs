{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
}:

buildPythonPackage rec {
  pname = "itemdb";
  version = "1.3.0";

  # PyPI tarball doesn't include tests directory
  src = fetchFromGitHub {
    owner = "almarklein";
    repo = "itemdb";
    tag = "v${version}";
    sha256 = "sha256-HXdOERq2td6CME8zWN0DRVkSlmdqTg2po7aJrOuITHE=";
  };

  nativeBuildInputs = [
    flit-core
  ];

  pyproject = true;

  meta = {
    description = "Easy transactional database for Python dicts, backed by SQLite";
    homepage = "https://itemdb.readthedocs.io";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.matthiasbeyer ];
  };
}
