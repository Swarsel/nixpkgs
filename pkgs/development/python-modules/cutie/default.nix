{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  # tests
  pytestCheckHook,
  # dependencies
  readchar,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cutie";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "kamik423";
    repo = "cutie";
    tag = finalAttrs.version;
    hash = "sha256-Z9GNvTrCgb+EDqlhHcOjn78Pli0Uc1HuVN2FrjTQobs=";
  };

  # https://docs.python.org/3/whatsnew/3.12.html#whatsnew312-removed-imp
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "import imp" "import types" \
      --replace-fail \
        'cutie = imp.new_module("cutie")' \
        'cutie = types.ModuleType("cutie")'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    colorama
    readchar
  ];

  pyproject = true;
  pythonImportsCheck = [ "cutie" ];

  meta = {
    description = "Command line User Tools for Input Easification";
    homepage = "https://github.com/kamik423/cutie";
    changelog = "https://github.com/kamik423/cutie/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gigahawk
    ];
  };
})
