{
  lib,
  fetchFromGitHub,
  aerosandbox,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "neuralfoil";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "peterdsharpe";
    repo = "NeuralFoil";
    rev = "46cda4041134d1b1794d3a81761d8d3e63f20855";
    hash = "sha256-kbPHPJh8xcIdPYIiaxwYqpfcnYzzDD6F0tG3flR0j3M=";
  };

  nativeBuildInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    aerosandbox
  ];

  pyproject = true;
  pythonImportsCheck = [ "neuralfoil" ];

  meta = {
    description = "Airfoil aerodynamics analysis tool using physics-informed machine learning, in pure Python/NumPy";
    homepage = "https://github.com/peterdsharpe/NeuralFoil";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
}
