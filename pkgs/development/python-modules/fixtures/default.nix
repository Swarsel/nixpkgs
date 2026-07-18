{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  mock,
  pytestCheckHook,
  testtools,
}:

buildPythonPackage rec {
  pname = "fixtures";
  version = "4.2.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6hRlZKZmYQbEgffDX5ek1lSFyEsMyGpQdZcWS2zA2Ek=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.streams;

  build-system = [
    hatchling
    hatch-vcs
  ];

  optional-dependencies = {
    streams = [ testtools ];
  };

  pyproject = true;

  meta = {
    description = "Reusable state for writing clean tests and more";
    homepage = "https://github.com/testing-cabal/fixtures";
    changelog = "https://github.com/testing-cabal/fixtures/blob/${version}/NEWS";
    license = lib.licenses.asl20;
  };
}
