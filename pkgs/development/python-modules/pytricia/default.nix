{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytricia";
  version = "1.3.0";

  # no tags on git repo
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HDo9aQnhDUycLw/kVCokgeEJ0pqrmcwCfKf+k/jIhT8=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pytricia" ];

  meta = {
    description = "Library for fast IP address lookup in Python";
    homepage = "https://github.com/jsommers/pytricia";
    license = with lib.licenses; [ lgpl3Plus ];
    maintainers = with lib.maintainers; [ mkg ];
  };
}
