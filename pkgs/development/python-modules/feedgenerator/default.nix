{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "feedgenerator";
  version = "2.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DqqVXx8Ly1uHrBla90Dwb/n/9KQO0wuKfGu+uyZNTdE=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "feedgenerator" ];

  meta = {
    description = "Standalone version of Django's feedgenerator module";
    homepage = "https://github.com/getpelican/feedgenerator";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
