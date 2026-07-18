{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage {
  pname = "assay";
  version = "0-unstable-2024-05-09";

  src = fetchFromGitHub {
    owner = "brandon-rhodes";
    repo = "assay";
    rev = "74617d70e77afa09f58b3169cf496679ac5d5621";
    hash = "sha256-zYpLtcXZ16EJWKSCqxFkSz/G9PwIZEQGBrYiJKuqnc4=";
  };

  postPatch = lib.optionalString (pythonAtLeast "3.14") ''
    substituteInPlace assay/assertion.py \
      --replace-fail "op.load_assertion_error" "op.load_common_constant"
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "assay" ];

  meta = {
    description = "Attempt to write a Python testing framework I can actually stand";
    homepage = "https://github.com/brandon-rhodes/assay";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zane ];
  };
}
