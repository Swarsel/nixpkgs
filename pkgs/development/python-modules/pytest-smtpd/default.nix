{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest,
  pytestCheckHook,
  smtpdfix,
}:

buildPythonPackage rec {
  pname = "pytest-smtpd";
  version = "0.1.0";

  # Pypi tarball doesn't include tests/
  src = fetchFromGitHub {
    owner = "bebleo";
    repo = "pytest-smtpd";
    tag = "v${version}";
    hash = "sha256-Vu2D2hfxBYxgXQ4Gjr+jFpac9fjpLL2FftBhnqrcQaA=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    smtpdfix
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_smtpd" ];

  meta = {
    description = "Pytest fixture that creates an SMTP server";
    homepage = "https://github.com/bebleo/pytest-smtpd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
