{
  lib,
  fetchFromGitHub,
  anyconfig,
  buildPythonPackage,
  isodate,
  poetry-core,
  poetry-dynamic-versioning,
  pytestCheckHook,
  pyyaml,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "pysolcast";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "mcaulifn";
    repo = "solcast";
    tag = "v${version}";
    hash = "sha256-VNT86sZyQBNCA4jq+uYp2sBd/FLN0c5tp2u4/PjVGnA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    anyconfig
    isodate
    pyyaml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysolcast" ];

  pythonRelaxDeps = [
    "isodate"
    "responses"
  ];

  meta = {
    description = "Python library for interacting with the Solcast API";
    homepage = "https://github.com/mcaulifn/solcast";
    changelog = "https://github.com/mcaulifn/solcast/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
