{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  lexbor,
  modest,
  pytestCheckHook,
  replaceVars,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "selectolax";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "rushter";
    repo = "selectolax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kLzeAz5dEUnD9zMN2iWt2FOCoF7MFpkjloB35wnB7VU=";
  };

  patches = [
    (replaceVars ./0001-setup.py-devendor-modest-and-lexbor.patch {
      lexbor = lib.getDev lexbor;
      modest = lib.getDev modest;
    })
  ];

  buildInputs = [
    modest
    lexbor
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # shadows name and breaks imports in tests
  preCheck = ''
    rm -rf selectolax
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;

  pythonImportsCheck = [
    "selectolax"
  ];

  meta = {
    description = "Python binding to Modest and Lexbor engines. Fast HTML5 parser with CSS selectors for Python";
    homepage = "https://github.com/rushter/selectolax";
    changelog = "https://github.com/rushter/selectolax/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcel ];
  };
})
