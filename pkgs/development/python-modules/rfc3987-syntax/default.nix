{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lark,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rfc3987-syntax";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "willynilly";
    repo = "rfc3987-syntax";
    tag = "v${version}";
    hash = "sha256-6jA/x8KnwBvyW2k384/EB/NJ8BmJJTEHA8YUlQP+1Y4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    lark
  ];

  pyproject = true;

  pythonImportsCheck = [
    "rfc3987_syntax"
  ];

  meta = {
    description = "Helper functions to syntactically validate strings according to RFC 3987";
    homepage = "https://github.com/willynilly/rfc3987-syntax";
    changelog = "https://github.com/willynilly/rfc3987-syntax/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
