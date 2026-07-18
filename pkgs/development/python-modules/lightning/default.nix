{
  buildPythonPackage,
  # tests
  psutil,
  pytestCheckHook,
  # dependencies
  pytorch-lightning,
}:

buildPythonPackage {
  inherit (pytorch-lightning)
    version
    src
    build-system
    meta
    ;

  pname = "lightning";
  # Some packages are not in nixpkgs; other tests try to build distributed
  # models, which doesn't work in the sandbox.
  doCheck = false;

  nativeCheckInputs = [
    psutil
    pytestCheckHook
  ];

  __structuredAttrs = true;
  dependencies = pytorch-lightning.dependencies ++ [ pytorch-lightning ];
  pyproject = true;

  pythonImportsCheck = [
    "lightning"
    "lightning.pytorch"
  ];
}
