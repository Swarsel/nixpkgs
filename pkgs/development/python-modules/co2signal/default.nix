{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "co2signal";
  version = "0.4.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-8YdYbknLICRrZloGUZuscv5e1LIDZBcCPKZs6EMaNuo=";
    pname = "CO2Signal";
  };

  # Modules has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "CO2Signal" ];

  meta = {
    description = "Package to access the CO2 Signal API";
    homepage = "https://github.com/danielsjf/CO2Signal";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ plabadens ];
  };
})
