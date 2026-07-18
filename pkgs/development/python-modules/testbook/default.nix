{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipykernel,
  nbclient,
  nbformat,
  pandas,
  pytestCheckHook,
  setuptools,
  traitlets,
}:

buildPythonPackage rec {
  pname = "testbook";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "nteract";
    repo = "testbook";
    rev = version;
    hash = "sha256-qaDgae/5TRpjmjOf7aom7TC5HLHp0PHM/ds47AKtq8U=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    nbclient
    nbformat
  ];

  nativeCheckInputs = [
    ipykernel
    pandas
    pytestCheckHook
    traitlets
  ];

  pyproject = true;
  pythonImportsCheck = [ "testbook" ];

  meta = {
    description = "Unit testing framework extension for testing code in Jupyter Notebooks";
    homepage = "https://testbook.readthedocs.io/";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ djacu ];
  };
}
