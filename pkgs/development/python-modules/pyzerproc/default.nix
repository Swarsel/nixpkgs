{
  lib,
  fetchFromGitHub,
  bleak,
  buildPythonPackage,
  click,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyzerproc";
  version = "0.4.12";

  src = fetchFromGitHub {
    owner = "emlove";
    repo = "pyzerproc";
    tag = version;
    hash = "sha256-vS0sk/KjDhWispZvCuGlmVLLfeFymHqxwNzNqNRhg6k=";
  };

  patches = [ ./bleak-compat.patch ];
  doCheck = false; # tries to access dbus, which leads to FileNotFoundError
  build-system = [ setuptools ];

  dependencies = [
    bleak
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyzerproc" ];

  meta = {
    description = "Python library to control Zerproc Bluetooth LED smart string lights";
    homepage = "https://github.com/emlove/pyzerproc";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
    mainProgram = "pyzerproc";
  };
}
