{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  libsodium,
  libxeddsa,
  nix-update-script,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "xeddsa";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-xeddsa";
    tag = "v${version}";
    hash = "sha256-FHZ9oo9Ps+98dWyPfu3RcmFqZ26zCmO3wNhw+hzuB+w=";
  };

  buildInputs = [
    libsodium
    libxeddsa
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "xeddsa" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python bindings to libxeddsa";
    homepage = "https://github.com/Syndace/python-xeddsa";
    changelog = "https://github.com/Syndace/python-xeddsa/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    teams = with lib.teams; [ ngi ];
  };
}
