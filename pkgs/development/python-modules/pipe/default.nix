{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pipe";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "JulienPalard";
    repo = "Pipe";
    tag = "v${version}";
    hash = "sha256-/xMhh70g2KPOOivTjpAuyfu+Z44tBE5zAwpSIEKhK6M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # Test require network access
    "test_netcat"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pipe" ];

  meta = {
    description = "Module to use infix notation";
    homepage = "https://github.com/JulienPalard/Pipe";
    changelog = "https://github.com/JulienPalard/Pipe/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
