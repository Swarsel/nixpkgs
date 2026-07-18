{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  mock,
  pendulum,
  poetry-core,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "plotille";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "tammoippen";
    repo = "plotille";
    tag = "v${version}";
    hash = "sha256-P2qwd935aaYgwLAKpTA2OAuohxVVzKwzYqjsuPSOSHs=";
  };

  patches = [
    # To remove when PR https://github.com/tammoippen/plotille/pull/63 has landed
    (fetchpatch {
      hash = "sha256-8vBVKrcH7R1d9ol3D7RLVtAzZbpMsB9rA1KHD7t3Ydc=";
      name = "add-build-information";
      url = "https://github.com/tammoippen/plotille/commit/db744e1fa9c141290966476ddf22a5e7d9a00c0a.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail poetry.masonry.api poetry.core.masonry.api \
      --replace-fail "poetry>=" "poetry-core>="
  '';

  nativeCheckInputs = [
    mock
    pendulum
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
  ];

  build-system = [
    poetry-core
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "plotille"
  ];

  meta = {
    description = "Plot in the terminal using braille dots";
    homepage = "https://github.com/tammoippen/plotille";
    changelog = "https://github.com/tammoippen/plotille/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
