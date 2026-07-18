{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ghauri";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "r0oth3x49";
    repo = "ghauri";
    tag = finalAttrs.version;
    hash = "sha256-GEUuQMtp8XO32uOIILWiMfngPXx/3vCKk+YbA0E13rg=";
  };

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    chardet
    colorama
    requests
    tldextract
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ghauri"
  ];

  meta = {
    description = "Tool for detecting and exploiting SQL injection security flaws";
    homepage = "https://github.com/r0oth3x49/ghauri";
    changelog = "https://github.com/r0oth3x49/ghauri/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ghauri";
  };
})
