{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  networkx,
  numpy,
  pytest7CheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "colormath2";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "bkmgit";
    repo = "python-colormath2";
    tag = version;
    hash = "sha256-G8b0L8A2RzbVQFPNg2fuBklqTNjo3yqvek/+GnqtsHc=";
  };

  nativeCheckInputs = [ pytest7CheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    networkx
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "colormath2" ];

  meta = {
    description = "Color math and conversion library (fork)";
    homepage = "https://github.com/bkmgit/python-colormath2";
    changelog = "https://github.com/bkmgit/python-colormath2/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ apraga ];
  };
}
