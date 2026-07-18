{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pdm-pep517,
}:

buildPythonPackage rec {
  pname = "imeon-inverter-api";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Imeon-Inverters-for-Home-Assistant";
    repo = "inverter-api";
    tag = version;
    hash = "sha256-8tecWWDYFq+kAqWM9vKhM15LKnEVqaDBkH6jh0xwIsE=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ pdm-pep517 ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "imeon_inverter_api" ];

  pythonRemoveDeps = [
    # https://github.com/Imeon-Inverters-for-Home-Assistant/inverter-api/pull/1
    "async-timeout"
  ];

  meta = {
    description = "Standalone API to collect data from the Imeon Energy Inverters that uses HTTP POST/GET";
    homepage = "https://github.com/Imeon-Inverters-for-Home-Assistant/inverter-api";
    changelog = "https://github.com/Imeon-Inverters-for-Home-Assistant/inverter-api/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
