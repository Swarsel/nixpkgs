{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
}:

buildPythonPackage rec {
  pname = "tailer";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "six8";
    repo = "pytailer";
    rev = version;
    sha256 = "1s5p5m3q9k7r1m0wx5wcxf20xzs0rj14qwg1ydwhf6adr17y2w5y";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m doctest -v src/tailer/__init__.py
    runHook postCheck
  '';

  format = "setuptools";
  pythonImportsCheck = [ "tailer" ];

  meta = {
    description = "Python implementation implementation of GNU tail and head";
    homepage = "https://github.com/six8/pytailer";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pytail";
  };
}
