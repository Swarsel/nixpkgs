{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pysmt";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "pysmt";
    repo = "pysmt";
    rev = "v${version}";
    hash = "sha256-HmEdCJOF04h0z5UPpfYa07b78EEBj5KyVAk6aNRFPEo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pysmt" ];

  meta = {
    description = "Python library for SMT formulae manipulation and solving";
    homepage = "https://github.com/pysmt/pysmt";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pysmt-install";
  };
}
