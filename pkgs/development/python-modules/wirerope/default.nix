{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "wirerope";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "wirerope";
    rev = version;
    hash = "sha256-oojnv+2+nwL/TJhN+QZ5eiV6WGHC3SCxBQrCri0aHQc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "wirerope" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wrappers for class callables";
    homepage = "https://github.com/youknowone/wirerope";
    changelog = "https://github.com/youknowone/wirerope/releases/tag/${version}";
    license = lib.licenses.bsd2WithViews;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
