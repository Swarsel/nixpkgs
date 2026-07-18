{
  buildPythonPackage,
  lzallright,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (lzallright) version src;
  pname = "lzallright-tests";

  nativeCheckInputs = [
    lzallright
    pytestCheckHook
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
