{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  mdformat,
  mdit-py-plugins,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-gfm-alerts";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "KyleKing";
    repo = "mdformat-gfm-alerts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hfi4Ek91G8WHAWjv7m52ZnT5Je9QyZT4yWSecaeTcvA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = [
    mdformat
    mdit-py-plugins
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_gfm_alerts" ];

  meta = {
    description = "Format 'GitHub Markdown Alerts', which use blockquotes to render admonitions";
    homepage = "https://github.com/KyleKing/mdformat-gfm-alerts";
    changelog = "https://github.com/KyleKing/mdformat-gfm-alerts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
