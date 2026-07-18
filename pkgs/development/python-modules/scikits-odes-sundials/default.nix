{
  buildPythonPackage,
  cython,
  numpy,
  pkgconfig,
  pytestCheckHook,
  scikits-odes-core,
  setuptools,
  sundials,
}:

buildPythonPackage rec {
  inherit (scikits-odes-core) version src;
  pname = "scikits-odes-sundials";
  buildInputs = [ sundials ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    numpy
    pkgconfig
    setuptools
  ];

  dependencies = [
    numpy
    scikits-odes-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "scikits_odes_sundials" ];
  sourceRoot = "${src.name}/packages/scikits-odes-sundials";

  meta = scikits-odes-core.meta // {
    description = "Sundials wrapper module for scikits-odes";
    homepage = "https://github.com/bmcage/odes/blob/master/packages/scikits-odes-sundials";
  };
}
