{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "mpfshell";
  version = "0.9.3-unstable-2025-01-09";

  src = fetchFromGitHub {
    owner = "wendlers";
    repo = "mpfshell";
    rev = "d290096ede985e8730b2ed02d130befdb65fde4e";
    hash = "sha256-+AUlBHCzxDKatXrDmmBsf0g4cKZaa9Ui92M0d+49rKo=";
  };

  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyserial
    colorama
    websocket-client
    standard-telnetlib # Python no longer provides telnetlib since python313
  ];

  pyproject = true;
  pythonImportsCheck = [ "mp.mpfshell" ];

  meta = {
    description = "Simple shell based file explorer for ESP8266 Micropython based devices";
    homepage = "https://github.com/wendlers/mpfshell";
    license = lib.licenses.mit;
    mainProgram = "mpfshell";
  };
}
