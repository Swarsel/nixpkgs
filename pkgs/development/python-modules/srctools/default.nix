{
  lib,
  attrs,
  buildPythonPackage,
  cython,
  dirty-equals,
  fetchPypi,
  meson,
  meson-python,
  pillow,
  pytest-regressions,
  pytestCheckHook,
  setuptools,
  useful-types,
}:
let
  pname = "srctools";
  version = "2.7.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ht+PUHzOjUNlllan1NvmvRRI7TGq3ws8Uwg8G/yJ9ZE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "meson-python == 0.18.0" "meson-python >= 0.18.0"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pillow
    pytest-regressions
    dirty-equals
    setuptools # required for pythoncapi-compat tests
  ];

  postCheck = ''
    python3 src/pythoncapi-compat/runtests.py --current
  '';

  build-system = [
    meson
    meson-python
    cython
  ];

  dependencies = [
    attrs
    useful-types
  ];

  # pythoncpai-comat tests are incompatible with pytest so we run their tests manually
  # see https://github.com/python/pythoncapi-compat/pull/169
  disabledTestPaths = [
    "src/pythoncapi-compat"
  ];

  pyproject = true;
  pythonImportsCheck = [ "srctools" ];

  meta = {
    description = "Modules for working with Valve's Source Engine file formats";
    homepage = "https://github.com/TeamSpen210/srctools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ different-name ];
  };
}
