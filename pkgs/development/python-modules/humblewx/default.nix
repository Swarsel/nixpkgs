{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  wxpython,
}:

buildPythonPackage rec {
  pname = "humblewx";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "thetimelineproj";
    repo = "humblewx";
    rev = version;
    sha256 = "0fv8gwlbcj000qq34inbwgxf0xgibs590dsyqnw0mmyb7f1iq210";
  };

  propagatedBuildInputs = [ wxpython ];
  # Unable to access the X Display, is $DISPLAY set properly?
  # would have to use nixos module tests, but it is not worth it
  doCheck = false;

  checkPhase = ''
    runHook preCheck
    for i in examples/*; do
      ${python.interpreter} $i
    done
    runHook postCheck
  '';

  format = "setuptools";
  pythonImportsCheck = [ "humblewx" ];

  meta = {
    description = "Library that simplifies creating user interfaces with wxPython";
    homepage = "https://github.com/thetimelineproj/humblewx";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ davidak ];
  };
}
