{
  buildPythonPackage,
  gfortran,
  meson-python,
  numpy,
  scikits-odes-core,
}:

buildPythonPackage rec {
  inherit (scikits-odes-core) version src;
  pname = "scikits-odes-daepack";
  nativeBuildInputs = [ gfortran ];
  # https://github.com/bmcage/odes/pull/204
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  # no tests
  doCheck = false;

  build-system = [
    meson-python
    numpy
  ];

  dependencies = [
    numpy
    scikits-odes-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "scikits_odes_daepack" ];
  sourceRoot = "${src.name}/packages/scikits-odes-daepack";

  meta = scikits-odes-core.meta // {
    description = "Wrapper around daepack";
    homepage = "https://github.com/bmcage/odes/blob/master/packages/scikits-odes-daepack";
  };
}
