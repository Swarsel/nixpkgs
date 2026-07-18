{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "annotated-types";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "annotated-types";
    repo = "annotated-types";
    tag = "v${version}";
    hash = "sha256-I1SPUKq2WIwEX5JmS3HrJvrpNrKDu30RWkBRDFE+k9A=";
  };

  nativeBuildInputs = [ hatchling ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "annotated_types" ];

  meta = {
    description = "Reusable constraint types to use with typing.Annotated";
    homepage = "https://github.com/annotated-types/annotated-types";
    changelog = "https://github.com/annotated-types/annotated-types/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
