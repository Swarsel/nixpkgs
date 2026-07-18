{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyweatherflowrest";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "briis";
    repo = "pyweatherflowrest";
    tag = "v${version}";
    hash = "sha256-l1V3HgzqnnoY6sWHwfgBtcIR782RwKhekY2qOLrUMNY=";
  };

  # Module has no tests. test.py is a demo script
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyweatherflowrest" ];

  meta = {
    description = "Python module to get data from WeatherFlow Weather Stations";
    homepage = "https://github.com/briis/pyweatherflowrest";
    changelog = "https://github.com/briis/pyweatherflowrest/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
