{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  # dependencies
  lxml,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "yaxmldiff";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "latk";
    repo = "yaxmldiff.py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AOXnK1d+b/ae50ofBfgxiDS6Dj6TIeHMrE9ME95Yj1Q=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [ lxml ];
  pyproject = true;

  meta = {
    description = "Yet Another XML Differ";
    homepage = "https://github.com/latk/yaxmldiff.py";
    changelog = "https://github.com/latk/yaxmldiff.py/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
