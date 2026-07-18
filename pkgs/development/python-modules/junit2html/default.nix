{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  jinja2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "junit2html";
  version = "31.1.4";

  src = fetchFromGitLab {
    owner = "inorton";
    repo = "junit2html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GUlRGv4+tRslrvSWvb3Fe5DcMFeYgL7HCyAHzrksJeQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ jinja2 ];
  pyproject = true;
  pythonImportsCheck = [ "junit2htmlreport" ];

  meta = {
    description = "Generate HTML reports from Junit results";
    homepage = "https://gitlab.com/inorton/junit2html";
    changelog = "https://gitlab.com/inorton/junit2html/-/releases/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "junit2html";
  };
})
