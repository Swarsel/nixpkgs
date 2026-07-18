{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  cached-property,
  click,
  coloredlogs,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "la-panic";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "yanivhasbanidev";
    repo = "la_panic";
    tag = version;
    hash = "sha256-V9VUSp5uvj4jR3oVHdRjvnNDGB1a5bi8elu/ry4jq00=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cached-property
    click
    coloredlogs
  ];

  pyproject = true;
  pythonImportsCheck = [ "la_panic" ];

  meta = {
    description = "AppleOS Kernel Panic Parser";
    homepage = "https://gitlab.com/yanivhasbanidev/la_panic";
    changelog = "https://gitlab.com/yanivhasbanidev/la_panic/-/tags/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "la_panic";
  };
}
