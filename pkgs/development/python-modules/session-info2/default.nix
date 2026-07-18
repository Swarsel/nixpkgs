{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coverage,
  hatch-docstring-description,
  hatch-vcs,
  hatchling,
  ipykernel,
  jupyter-client,
  pytest-asyncio,
  pytest-subprocess,
  pytestCheckHook,
  testing-common-database,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "session-info2";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "scverse";
    repo = "session-info2";
    tag = "v${version}";
    hash = "sha256-n568j109rnWxCWLsdu0RS7huVfUebzFshAd84i6ALM4=";
  };

  nativeCheckInputs = [
    coverage
    ipykernel
    jupyter-client
    pytestCheckHook
    pytest-asyncio
    pytest-subprocess
    testing-common-database
    writableTmpDirAsHomeHook
  ];

  build-system = [
    hatch-docstring-description
    hatch-vcs
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "session_info2"
  ];

  meta = {
    description = "Report Python session information";
    homepage = "https://session-info2.readthedocs.io";
    changelog = "https://github.com/scverse/session-info2/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
