{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  distro,
  jsonschema,
  mock,
  packaging,
  parameterized,
  pytestCheckHook,
  setuptools,
  testfixtures,
  zipfile2,
}:

buildPythonPackage rec {
  pname = "okonomiyaki";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "enthought";
    repo = "okonomiyaki";
    tag = version;
    hash = "sha256-xAF9Tdr+IM3lU+mcNcAWATJLZOVvbx0llqznqHLVqDc=";
  };

  nativeCheckInputs = [
    packaging
    parameterized
    pytestCheckHook
    testfixtures
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    substituteInPlace okonomiyaki/runtimes/tests/test_runtime.py \
      --replace-fail 'runtime_info = PythonRuntime.from_running_python()' 'raise unittest.SkipTest() #'
    substituteInPlace okonomiyaki/platforms/_platform.py \
      --replace-fail 'name.split()[0]' '(name.split() or [""])[0]'
  '';

  build-system = [ setuptools ];

  optional-dependencies = {
    all = [
      attrs
      distro
      jsonschema
      zipfile2
    ];

    formats = [
      attrs
      distro
      jsonschema
      zipfile2
    ];

    platforms = [
      attrs
      distro
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "okonomiyaki" ];

  meta = {
    description = "Experimental library aimed at consolidating a lot of low-level code used for Enthought's eggs";
    homepage = "https://github.com/enthought/okonomiyaki";
    changelog = "https://github.com/enthought/okonomiyaki/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
