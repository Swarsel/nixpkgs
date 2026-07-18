{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pillow,
  pytestCheckHook,
  rich,
  syrupy,
}:

buildPythonPackage rec {
  pname = "rich-pixels";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "darrenburns";
    repo = "rich-pixels";
    tag = version;
    hash = "sha256-Sqs0DOyxJBfZmm/SVSTMSmaaeRlusiSp6VBnJjKYjgQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    pillow
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "rich_pixels" ];
  pythonRelaxDeps = [ "pillow" ];

  meta = {
    description = "Rich-compatible library for writing pixel images and ASCII art to the terminal";
    homepage = "https://github.com/darrenburns/rich-pixels";
    changelog = "https://github.com/darrenburns/rich-pixels/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
