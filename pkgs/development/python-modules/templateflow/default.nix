{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # dependenices
  nipreps-versions,
  platformdirs,
  pybids,
  requests,
  setuptools-scm,
  tqdm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "templateflow";
  version = "25.1.2";

  src = fetchFromGitHub {
    owner = "templateflow";
    repo = "python-client";
    tag = finalAttrs.version;
    hash = "sha256-fpmpTvA0Q6VvXkTlALbzZl+fy4oJmnUF/WYzr2CFkFg=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  doCheck = false; # most tests try to download data

  build-system = [
    hatch-vcs
    hatchling
    setuptools-scm
  ];

  dependencies = [
    nipreps-versions
    platformdirs
    pybids
    requests
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "templateflow" ];

  meta = {
    description = "Python API to query TemplateFlow via pyBIDS";
    homepage = "https://templateflow.org/python-client";
    changelog = "https://github.com/templateflow/python-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
