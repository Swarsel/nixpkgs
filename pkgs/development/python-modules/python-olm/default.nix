{
  aspectlib,
  buildPythonPackage,
  cffi,
  isPy3k,
  olm,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  inherit (olm) src version;
  pname = "python-olm";
  buildInputs = [ olm ];

  preBuild = ''
    make include/olm/olm.h
  '';

  nativeCheckInputs = [
    aspectlib
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cffi
  ];

  disabled = !isPy3k;
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "olm" ];
  sourceRoot = "${olm.src.name}/python";

  meta = {
    inherit (olm.meta) license maintainers;
    description = "Python bindings for Olm";
    homepage = "https://gitlab.matrix.org/matrix-org/olm/tree/master/python";
  };
}
