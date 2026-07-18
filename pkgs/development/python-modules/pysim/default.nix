{
  lib,
  fetchFromGitHub,
  bidict,
  buildPythonPackage,
  cmd2,
  colorlog,
  construct,
  gsm0338,
  jsonpath-ng,
  packaging,
  pycryptodomex,
  pyscard,
  pyserial,
  pytestCheckHook,
  pytlv,
  pyyaml,
  setuptools,
  smpp-pdu,
  termcolor,
}:

buildPythonPackage {
  pname = "pysim";
  version = "unstable-2023-08-13";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "pysim";
    rev = "09ff0e2b433b7143d5b40b4494744569b805e554";
    hash = "sha256-7IwIovGR0GcS1bidSqoytmombK6NkLSVAfKB2teW2JU=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace 'smpp.pdu @ git+https://github.com/hologram-io/smpp.pdu' 'smpp.pdu'
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    bidict
    cmd2
    colorlog
    construct
    gsm0338
    jsonpath-ng
    packaging
    pycryptodomex
    pyscard
    pyserial
    pytlv
    pyyaml
    smpp-pdu
    termcolor
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pySim" ];

  meta = {
    description = "Python tool to program SIMs / USIMs / ISIMs";
    homepage = "https://github.com/osmocom/pysim";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
