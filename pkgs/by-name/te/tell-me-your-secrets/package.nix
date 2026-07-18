{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tell-me-your-secrets";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "valayDave";
    repo = "tell-me-your-secrets";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3ZJyL/V1dsW6F+PiEhnWpv/Pz2H9/UKSJWDgw68M/Z8=";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    gitignore-parser
    pandas
    pyyaml
    single-source
  ];

  pyproject = true;
  pythonImportsCheck = [ "tell_me_your_secrets" ];

  pythonRelaxDeps = [
    "pandas"
    "single-source"
  ];

  meta = {
    description = "Tools to find secrets from various signatures";
    homepage = "https://github.com/valayDave/tell-me-your-secrets";
    changelog = "https://github.com/valayDave/tell-me-your-secrets/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "tell-me-your-secrets";
  };
})
