{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  keyring,
  lz4,
  pbkdf2,
  pyaes,
  pycryptodomex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "browser-cookie3";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "borisbabic";
    repo = "browser_cookie3";
    tag = version;
    hash = "sha256-3EmFx+9LQFuS26mUPH/etc6hkUXqmNOOipbldhjorDE=";
  };

  # No tests implemented
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    lz4
    keyring
    pbkdf2
    pyaes
    pycryptodomex
  ];

  pyproject = true;
  pythonImportsCheck = [ "browser_cookie3" ];

  meta = {
    description = "Loads cookies from your browser into a cookiejar object";
    homepage = "https://github.com/borisbabic/browser_cookie3";
    changelog = "https://github.com/borisbabic/browser_cookie3/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ borisbabic ];
  };
}
