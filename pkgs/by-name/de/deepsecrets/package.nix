{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "deepsecrets";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "avito-tech";
    repo = "deepsecrets";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VfIsPgStHcIYGbfrOs1mvgoq0ZoVSZwILFVBeMt/5Jc=";
  };

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    dotwiz
    mmh3
    ordered-set
    pydantic_1
    pygments
    pyyaml
    regex
  ];

  disabledTests = [
    # assumes package is built in /app (docker?), and not /build/${finalAttrs.src.name} (nix sandbox)
    "test_1_cli"
    "test_config"
    "test_basic_info"
  ];

  pyproject = true;
  pythonImportsCheck = [ "deepsecrets" ];

  pythonRelaxDeps = [
    "pyyaml"
    "regex"
    "mmh3"
  ];

  meta = {
    description = "Secrets scanner that understands code";
    homepage = "https://github.com/avito-tech/deepsecrets";
    changelog = "https://github.com/avito-tech/deepsecrets/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "deepsecrets";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
