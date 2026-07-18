{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-scm,
  packaging,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "nipreps-versions";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "nipreps";
    repo = "version-schemes";
    tag = version;
    hash = "sha256-B2wtLurzgk59kTooH51a2dewK7aEyA0dAm64Wp+tqhM=";
  };

  nativeBuildInputs = [
    flit-scm
    setuptools-scm
  ];

  propagatedBuildInputs = [ packaging ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "nipreps_versions" ];

  meta = {
    description = "Setuptools_scm plugin for nipreps version schemes";
    homepage = "https://github.com/nipreps/version-schemes";
    changelog = "https://github.com/nipreps/version-schemes/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
