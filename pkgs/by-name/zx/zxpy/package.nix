{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  deterministic-uname,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "zxpy";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "tusharsadhwani";
    repo = "zxpy";
    tag = finalAttrs.version;
    hash = "sha256-/VITHN517lPUmhLYgJHBYYvvlJdGg2Hhnwk47Mp9uc0=";
  };

  nativeCheckInputs =
    with python3Packages;
    [
      deterministic-uname
      pytestCheckHook
    ]
    ++ [
      addBinToPathHook
    ];

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "zx" ];

  meta = {
    description = "Shell scripts made simple";
    homepage = "https://github.com/tusharsadhwani/zxpy";
    changelog = "https://github.com/tusharsadhwani/zxpy/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "zxpy";
  };
})
