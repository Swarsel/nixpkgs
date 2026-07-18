{
  buildPythonPackage,
  cmake,
  libzint,
  libzxing-cpp,
  numpy,
  pillow,
  pybind11,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  inherit (libzxing-cpp) src version meta;
  pname = "zxing-cpp";

  # we don't need pybind11 in the root environment
  # https://pybind11.readthedocs.io/en/stable/installing.html#include-with-pypi
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pybind11[global]" "pybind11"

    substituteInPlace setup.py \
      --replace-fail "cfg = 'Debug' if self.debug else 'Release'" "cfg = 'Release'" \
      --replace-fail " '-DVERSION_INFO=' + self.distribution.get_version()]" " '-DVERSION_INFO=' + self.distribution.get_version(), '-DZXING_DEPENDENCIES=LOCAL', '-DZXING_USE_BUNDLED_ZINT=OFF']"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ libzint ];

  nativeCheckInputs = [
    pillow
    pytestCheckHook
  ];

  build-system = [
    setuptools-scm
    pybind11
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "zxingcpp" ];
  sourceRoot = "${src.name}/wrappers/python";
}
