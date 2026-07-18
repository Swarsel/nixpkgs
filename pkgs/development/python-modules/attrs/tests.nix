{
  attrs,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (attrs) version;
  pname = "attrs-tests";

  nativeCheckInputs = [
    attrs
    hypothesis
    pytestCheckHook
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
  srcs = attrs.testout;
}
