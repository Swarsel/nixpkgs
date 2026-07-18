{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  numpy,
  py7zr,
  pytestCheckHook,
  pythonOlder,
  stdlib-list,
  torch,
  torchvision,
}:

buildPythonPackage (finalAttrs: {
  pname = "fickling";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "fickling";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7wbQdInnKFnI76UNmF1/qwFO+2pFt9BXGPnrzHK8rYI=";
  };

  # Tests fail upstream in pytorch under python 3.14
  doCheck = pythonOlder "3.14";

  nativeCheckInputs = [
    py7zr
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    hatchling
  ];

  dependencies = [
    stdlib-list
  ];

  optional-dependencies = {
    torch = [
      numpy
      torch
      torchvision
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fickling" ];
  pythonRelaxDeps = [ "stdlib-list" ];

  meta = {
    description = "Python pickling decompiler and static analyzer";
    homepage = "https://github.com/trailofbits/fickling";
    changelog = "https://github.com/trailofbits/fickling/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
