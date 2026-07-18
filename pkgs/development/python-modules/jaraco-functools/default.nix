{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  jaraco-classes,
  more-itertools,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-functools";
  version = "4.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2iGTOwQXuJUVViZWVHp3tJMfmBdusXNkTA01Ayoz1rs=";
    pname = "jaraco_functools";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  nativeCheckInputs = [
    jaraco-classes
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ more-itertools ];
  # test is flaky on darwin
  disabledTests = if stdenv.hostPlatform.isDarwin then [ "test_function_throttled" ] else null;
  pyproject = true;
  pythonImportsCheck = [ "jaraco.functools" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Additional functools in the spirit of stdlib's functools";
    homepage = "https://github.com/jaraco/jaraco.functools";
    changelog = "https://github.com/jaraco/jaraco.functools/blob/v${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
