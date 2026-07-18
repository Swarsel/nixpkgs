{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "docify";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "atoerien";
    repo = "docify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xp8VsDv2Wf8g2mUMPmBgWoyWpJna/r1xPgqO3SUqcR0=";
  };

  # upstream has no tests
  doCheck = false;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    libcst
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "docify" ];

  meta = {
    description = "Script to add docstrings to Python type stubs using reflection";
    homepage = "https://github.com/atoerien/docify";
    changelog = "https://github.com/atoerien/docify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "docify";
  };
})
