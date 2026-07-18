{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cwcwidth";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "sebastinas";
    repo = "cwcwidth";
    tag = "v${version}";
    hash = "sha256-mkyBtqAFqu7dxpb46qMOnXmXpUV3qtpknfIgVQQt5nY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # prevent import shadow
    rm -rf cwcwidth

    # locale settings used by upstream, has the effect of skipping otherwise-failing tests on darwin
    export LC_ALL='C.UTF-8'
    export LANG='C.UTF-8'
  '';

  build-system = [
    cython
    setuptools
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # Despite setting the locales above, this test fails with:
    # AssertionError: Tuples differ: (1, 1, 1, 1) != (1, 1, 1, 0)
    "test_combining_spacing"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cwcwidth" ];

  meta = {
    description = "Python bindings for wc(s)width";
    homepage = "https://github.com/sebastinas/cwcwidth";
    changelog = "https://github.com/sebastinas/cwcwidth/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
