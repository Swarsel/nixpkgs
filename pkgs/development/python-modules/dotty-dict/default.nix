{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "dotty-dict";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "pawelzny";
    repo = "dotty_dict";
    tag = "v${version}";
    hash = "sha256-kY7o9wgfsV7oc5twOeuhG47C0Js6JzCt02S9Sd8dSGc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "dotty_dict" ];

  meta = {
    description = "Dictionary wrapper for quick access to deeply nested keys";
    homepage = "https://dotty-dict.readthedocs.io";
    changelog = "https://github.com/pawelzny/dotty_dict/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
