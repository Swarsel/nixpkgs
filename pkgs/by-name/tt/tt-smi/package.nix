{
  lib,
  fetchFromGitHub,
  pre-commit,
  python3Packages,
  tt-umd,
  versionCheckHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tt-smi";
  version = "5.3.1";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-smi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lZ9fd8tkwfmWHEAJ8+cwBja3U7vxAVWQWrgope9/VO4=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    distro
    elasticsearch
    pydantic
    pyluwen
    rich
    textual
    pre-commit
    importlib-resources
    tt-tools-common
    setuptools
    tomli
    tt-umd
  ];

  # Fails due to having no tests
  dontUsePytestCheck = true;
  pyproject = true;
  pythonRelaxDeps = [ "tt-umd" ];

  meta = {
    description = "Tenstorrent console based hardware information program";
    homepage = "https://github.com/tenstorrent/tt-smi";
    changelog = "https://github.com/tenstorrent/tt-smi/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    mainProgram = "tt-smi";
  };
})
