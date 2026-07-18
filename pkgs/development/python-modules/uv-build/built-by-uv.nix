{
  anyio,
  buildPythonPackage,
  pytestCheckHook,
  uv-build,
}:
buildPythonPackage {
  pname = "built-by-uv";
  version = "0.1.0";
  src = "${uv-build.src}/test/packages/built-by-uv";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  dependencies = [ anyio ];
  pyproject = true;
  pythonImportsCheck = [ "built_by_uv" ];
}
