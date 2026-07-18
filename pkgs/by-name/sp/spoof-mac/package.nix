{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "spoof-mac";
  version = "0-unstable-2018-01-27";

  src = fetchFromGitHub {
    owner = "feross";
    repo = "SpoofMAC";
    rev = "2cfc796150ef48009e9b765fe733e37d82c901e0";
    hash = "sha256-Qiu0URjUyx8QDVQQUFGxPax0J80e2m4+bPJeqFoKxX8=";
  };

  propagatedBuildInputs = [ python3Packages.docopt ];
  # No tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "spoofmac" ];

  meta = {
    description = "Change your MAC address for debugging purposes";
    homepage = "https://github.com/feross/SpoofMAC";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
