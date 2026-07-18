{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cansina";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "deibit";
    repo = "cansina";
    tag = finalAttrs.version;
    hash = "sha256-vDlYJSRBVFtEdE/1bN8PniFYkpggIKMcEakphHmaTos=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    asciitree
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cansina"
  ];

  meta = {
    description = "Web Content Discovery Tool";
    homepage = "https://github.com/deibit/cansina";
    changelog = "https://github.com/deibit/cansina/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cansina";
  };
})
