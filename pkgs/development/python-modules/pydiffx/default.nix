{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  kgb,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pydiffx";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "beanbaginc";
    repo = "diffx";
    tag = "pydiffx/release-${version}";
    hash = "sha256-oJjHrg1X02SmNJKbWbTPc0kycI+jLj0C4eUFFXwb+TA=";
  };

  postPatch = ''
    substituteInPlace pydiffx/tests/testcases.py \
      --replace-fail "assertRaisesRegexp" "assertRaisesRegex"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    kgb
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "pydiffx" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "DiffX file format and utilities";
    homepage = "https://github.com/beanbaginc/diffx";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
