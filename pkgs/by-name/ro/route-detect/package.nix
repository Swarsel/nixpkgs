{
  lib,
  fetchFromGitHub,
  python3,
  semgrep,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "route-detect";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "mschwager";
    repo = "route-detect";
    tag = finalAttrs.version;
    hash = "sha256-4WkYjAQyteHJTJvSZoSfVUnBvsDQ3TWb5Ttp3uCgvdU=";
  };

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ poetry-core ];
  dependencies = [ semgrep ];
  pyproject = true;
  pythonImportsCheck = [ "routes" ];

  meta = {
    description = "Find authentication (authn) and authorization (authz) security bugs in web application routes";
    homepage = "https://github.com/mschwager/route-detect";
    changelog = "https://github.com/mschwager/route-detect/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "routes";
  };
})
