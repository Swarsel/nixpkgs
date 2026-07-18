{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  greenlet,
  isPyPy,
  msgpack,
  pythonOlder,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pynvim";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "neovim";
    repo = "pynvim";
    tag = version;
    hash = "sha256-Wxn4g/lFelAJx0Zz2yaeXqX56xeOWUJNb2p8EiJgKE0=";
  };

  # Tests require pkgs.neovim which we cannot add because of circular dependency
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msgpack
  ]
  ++ lib.optionals (!isPyPy) [ greenlet ]
  ++ lib.optionals (pythonOlder "3.12") [ typing-extensions ];

  pyproject = true;
  pythonImportsCheck = [ "pynvim" ];

  meta = {
    description = "Python client for Neovim";
    homepage = "https://github.com/neovim/pynvim";
    changelog = "https://github.com/neovim/pynvim/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
