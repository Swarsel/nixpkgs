{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  poetry-core,
  pycountry,
  pyrate-limiter,
  requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "psnawp";
  version = "3.0.3";

  src = fetchFromCodeberg {
    owner = "YoshikageKira";
    repo = "psnawp";
    tag = "v${version}";
    hash = "sha256-vAz1HDvPRWgrWMKwWNMA2nhA2wLCN92lDb06ZQiZnO0=";
  };

  # tests access the actual PlayStation Network API
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    pycountry
    pyrate-limiter
    requests
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "psnawp_api" ];

  pythonRelaxDeps = [
    "pycountry"
  ];

  meta = {
    description = "Python API Wrapper for PlayStation Network API";
    homepage = "https://codeberg.org/YoshikageKira/psnawp";
    changelog = "https://codeberg.org/YoshikageKira/psnawp/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
