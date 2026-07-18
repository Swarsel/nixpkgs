{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  irctokens,
  pendulum,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "ircstates";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "jesopo";
    repo = "ircstates";
    rev = "v${version}";
    hash = "sha256-Mq9aOj6PXzPjaz3ofoPcAbur59oUWffmEg8aHt0v+0Q=";
  };

  nativeCheckInputs = [
    freezegun
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    irctokens
    pendulum
  ];

  pyproject = true;
  pythonImportsCheck = [ "ircstates" ];
  pythonRelaxDeps = [ "pendulum" ];

  meta = {
    description = "sans-I/O IRC session state parsing library";
    homepage = "https://github.com/jesopo/ircstates";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
