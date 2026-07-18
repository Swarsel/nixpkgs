{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyyaml,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "irctokens";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "jesopo";
    repo = "irctokens";
    rev = "v${version}";
    hash = "sha256-Y9NBqxGUkt48hnXxsmfydHkJmWWb+sRrElV8C7l9bpw=";
  };

  nativeCheckInputs = [
    pyyaml
    unittestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "irctokens" ];

  meta = {
    description = "RFC1459 and IRCv3 protocol tokeniser library for python3";
    homepage = "https://github.com/jesopo/irctokens";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
