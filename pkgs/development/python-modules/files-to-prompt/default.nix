{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  pytestCheckHook,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "files-to-prompt";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "files-to-prompt";
    tag = version;
    hash = "sha256-LWp/DNP3bsh7/goQGkpi4x2N11tRuhLVh2J8H6AUH0w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ click ];
  disabledTests = [ "test_binary_file_warning" ];
  pyproject = true;

  meta = {
    description = "Concatenate a directory full of files into a single prompt for use with LLMs";
    homepage = "https://github.com/simonw/files-to-prompt";
    changelog = "https://github.com/simonw/files-to-prompt/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      erethon
      philiptaron
    ];

    mainProgram = "files-to-prompt";
  };
}
