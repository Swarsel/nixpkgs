{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gast";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "gast";
    tag = version;
    hash = "sha256-paaXVdhstNlLc/zv/L1tHuv9IZ0Vz/vz2x2y2ePpXRc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gast" ];

  meta = {
    description = "Compatibility layer between the AST of various Python versions";
    homepage = "https://github.com/serge-sans-paille/gast/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      cpcloud
    ];
  };
}
