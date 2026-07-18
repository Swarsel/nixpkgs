{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  packaging,
  poetry-core,
  pydantic,
  redis,
  structlog,
}:

buildPythonPackage rec {
  pname = "diffsync";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "networktocode";
    repo = "diffsync";
    tag = "v${version}";
    hash = "sha256-NkISo4AmyxA0pQEkzajq+hpxoMefgSOHQTy70kOjDl8=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    colorama
    packaging
    pydantic
    redis
    structlog
  ];

  pyproject = true;
  pythonImportsCheck = [ "diffsync" ];

  pythonRelaxDeps = [
    "packaging"
    "structlog"
  ];

  meta = {
    description = "Utility library for comparing and synchronizing different datasets";
    homepage = "https://github.com/networktocode/diffsync";
    changelog = "https://github.com/networktocode/diffsync/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ clerie ];
  };
}
