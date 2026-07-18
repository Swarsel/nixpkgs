{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycolorecho,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyloggermanager";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "coldsofttech";
    repo = "pyloggermanager";
    rev = version;
    hash = "sha256-1hfcmMLH2d71EV71ExKqjZ7TMcqVd1AQrEwJhmEWOVU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pycolorecho ];
  pyproject = true;
  pythonImportsCheck = [ "pyloggermanager" ];

  meta = {
    description = "Logging framework for Python applications";
    homepage = "https://github.com/coldsofttech/pyloggermanager";
    changelog = "https://github.com/coldsofttech/pyloggermanager/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ShamrockLee ];
  };
}
