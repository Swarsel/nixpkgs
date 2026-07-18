{
  buildPythonPackage,
  pluggy,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (pluggy) version;
  inherit (pluggy) src;
  pname = "pluggy-tests";

  nativeCheckInputs = [
    pluggy
    pytestCheckHook
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
