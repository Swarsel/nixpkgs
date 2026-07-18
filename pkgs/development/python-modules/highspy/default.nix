{
  lib,
  buildPythonPackage,
  cmake,
  highs,
  ninja,
  numpy,
  pathspec,
  pybind11,
  pytestCheckHook,
  scikit-build-core,
}:
buildPythonPackage {
  inherit (highs) src;
  pname = "highspy";
  version = highs.version;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cmake
    ninja
    pathspec
    scikit-build-core
    pybind11
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "highspy" ];

  meta = {
    description = "Linear optimization software";
    homepage = "https://github.com/ERGO-Code/HiGHS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ renesat ];
  };
}
