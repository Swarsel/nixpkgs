{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

let
  pname = "rpi-bad-power";
  version = "0.1.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = "rpi-bad-power";
    rev = "v${version}";
    hash = "sha256:1yvfz28blq4fdnn614n985vbs5hcw1gm3i9am53k410sfs7ilvkk";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "rpi_bad_power" ];

  meta = {
    description = "Python library to detect bad power supply on Raspberry Pi";
    homepage = "https://github.com/shenxn/rpi-bad-power";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
  };
}
