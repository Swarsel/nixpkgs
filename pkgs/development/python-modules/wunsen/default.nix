{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  khanaa,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "wunsen";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "cakimpei";
    repo = "wunsen";
    tag = "v${version}";
    hash = "sha256-lMEhtcWG+S3vAz+Y/qDxhaZslsO0pbs5xUn5QgZNs2U=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ khanaa ];
  pyproject = true;
  pythonImportsCheck = [ "wunsen" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Transliterate/transcribe other languages into Thai Topics";
    homepage = "https://github.com/cakimpei/wunsen";
    changelog = "https://github.com/cakimpei/wunsen/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
