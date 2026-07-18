{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  jsonpath-ng,
  jsonschema,
  matplotlib,
  poetry-core,
  pytestCheckHook,
  python,
  python-docx,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "sarif-tools";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "sarif-tools";
    tag = "v${version}";
    hash = "sha256-Dt8VcYIIpujRp2sOlK2JPGzy5cYZDXdXgnvT/+h3DuU=";
  };

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    jinja2
    jsonpath-ng
    matplotlib
    python
    python-docx
    pyyaml
  ];

  disabledTests = [
    # Broken, re-enable once https://github.com/microsoft/sarif-tools/pull/41 is merged
    "test_version"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sarif" ];
  pythonRelaxDeps = [ "python-docx" ];

  meta = {
    description = "Set of command line tools and Python library for working with SARIF files";
    homepage = "https://github.com/microsoft/sarif-tools";
    changelog = "https://github.com/microsoft/sarif-tools/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puzzlewolf ];
    mainProgram = "sarif";
  };
}
