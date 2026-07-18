{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  markdown-it-py,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "mdformat";
    tag = finalAttrs.version;
    hash = "sha256-fo4xO4Y89qPAggEjwuf6dnTyu1JzhZVdJyUqGNpti7g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ markdown-it-py ];
  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "mdformat" ];

  passthru = {
    withPlugins = throw "Use pkgs.mdformat.withPlugins, i.e. the top-level attribute.";
  };

  meta = {
    description = "CommonMark compliant Markdown formatter";
    homepage = "https://mdformat.rtfd.io/";
    changelog = "https://github.com/executablebooks/mdformat/blob/${finalAttrs.src.tag}/docs/users/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      aldoborrero
    ];

    mainProgram = "mdformat";
  };
})
