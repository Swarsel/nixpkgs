{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  mdformat,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-simple-breaks";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "csala";
    repo = "mdformat-simple-breaks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w0qPxIlCFMvs7p2Lya/ATkQN9wVt8ipsePZgonN/qpc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  dependencies = [
    mdformat
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_simple_breaks" ];

  meta = {
    description = "Mdformat plugin to render thematic breaks using three dashes";
    homepage = "https://github.com/csala/mdformat-simple-breaks";
    changelog = "https://github.com/csala/mdformat-simple-breaks/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldoborrero ];
  };
})
