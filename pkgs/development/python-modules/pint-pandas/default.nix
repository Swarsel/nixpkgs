{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pandas,
  pint,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  wheel,
}:

buildPythonPackage rec {
  pname = "pint-pandas";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "hgrecco";
    repo = "pint-pandas";
    tag = version;
    hash = "sha256-B8nxGetnYpA+Nuhe//D8n+5g7rPO90Mm1iWswJ0+mPc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    pint
    pandas
    packaging
  ];

  pyproject = true;

  meta = {
    description = "Pandas support for pint";
    homepage = "https://github.com/hgrecco/pint-pandas";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
