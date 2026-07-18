{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "multi-key-dict";
  version = "2.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3uvewXqjChxDLLP0N+gfhiHhwFQqDAYXp09x4jLpk54=";
    pname = "multi_key_dict";
  };

  nativeBuildInputs = [ setuptools ];
  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "multi_key_dict" ];

  meta = {
    description = "Multi_key_dict";
    homepage = "https://github.com/formiaczek/multi_key_dict";
    license = lib.licenses.mit;
  };
}
