{
  lib,
  fetchFromGitHub,
  astunparse,
  buildPythonPackage,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "frilouz";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "QuantStack";
    repo = "frilouz";
    rev = version;
    sha256 = "0w2qzi4zb10r9iw64151ay01vf0yzyhh0bsjkx1apxp8fs15cdiw";
  };

  nativeCheckInputs = [ astunparse ];
  preCheck = "cd test";

  checkPhase = ''
    runHook preCheck
    python -m unittest
    runHook postCheck
  '';

  disabled = !isPy3k;
  format = "setuptools";
  pythonImportsCheck = [ "frilouz" ];

  meta = {
    description = "Python AST parser adapter with partial error recovery";
    homepage = "https://github.com/QuantStack/frilouz";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
