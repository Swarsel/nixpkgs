{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pybase64";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "mayeut";
    repo = "pybase64";
    tag = "v${version}";
    hash = "sha256-cR8Ht6QbHXCED86xCbiLg4bxt1Hkv4Ota7R+voZE3yo=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.optionals (pythonOlder "3.12") [ typing-extensions ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pybase64" ];

  meta = {
    description = "Fast Base64 encoding/decoding";
    homepage = "https://github.com/mayeut/pybase64";
    changelog = "https://github.com/mayeut/pybase64/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "pybase64";
  };
}
