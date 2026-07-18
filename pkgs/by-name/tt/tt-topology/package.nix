{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  versionCheckHook,
}:
python3Packages.buildPythonApplication rec {
  pname = "tt-topology";
  version = "1.2.19";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-topology";
    tag = "v${version}";
    hash = "sha256-M12MdXyEwyvXscp7roE19mWZ4+/miTAyzUH3SUtOohE=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    elasticsearch
    pydantic
    pyluwen
    tt-tools-common
    networkx
    matplotlib

    # Needed for "pkg_resources"
    setuptools
  ];

  # Tests are broken
  dontUsePytestCheck = true;
  pyproject = true;

  # Remove when https://github.com/tenstorrent/tt-topology/pull/51 is merged
  pythonRelaxDeps = [
    "elasticsearch"
    "networkx"
    "matplotlib"
    "setuptools"
  ];

  pythonRemoveDeps = [
    "black"
    "pre-commit"
  ];

  meta = {
    description = "Command line utility used to flash multiple NB cards on a system to use specific eth routing configurations";
    homepage = "https://github.com/tenstorrent/tt-topology";
    changelog = "https://github.com/tenstorrent/tt-topology/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    mainProgram = "tt-topology";
  };
}
