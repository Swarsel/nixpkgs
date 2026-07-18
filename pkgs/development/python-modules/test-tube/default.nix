{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  imageio,
  numpy,
  pandas,
  pytestCheckHook,
  tensorboard,
  torch,
}:

buildPythonPackage rec {
  pname = "test-tube";
  version = "0.628";

  src = fetchFromGitHub {
    owner = "williamFalcon";
    repo = "test-tube";
    rev = version;
    sha256 = "0w60xarmcw06gc4002sy7bjfykdz34gbgniswxkl0lw8a1v0xn2m";
  };

  propagatedBuildInputs = [
    future
    imageio
    numpy
    pandas
    torch
    tensorboard
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Framework-agnostic library to track and parallelize hyperparameter search in machine learning experiments";
    homepage = "https://github.com/williamFalcon/test-tube";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
