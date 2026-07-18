{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyelectra";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "jafar-atili";
    repo = "pyelectra";
    tag = version;
    hash = "sha256-3g+6AXbHMStk77k+1Qh5kgDswUZ8I627YiA/PguUGBg=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "electrasmart" ];

  meta = {
    description = "Electra Smart Python Integration";
    homepage = "https://github.com/jafar-atili/pyelectra";
    changelog = "https://github.com/jafar-atili/pyElectra/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
