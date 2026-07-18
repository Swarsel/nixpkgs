{
  lib,
  buildPythonPackage,
  fetchPypi,
  playwright,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "playwright-stealth";
  version = "2.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-HY5Ij73Y8ZDxJp6oz11X0U3zqfGvEAHEHuNYiyqsMTM=";
    pname = "playwright_stealth";
  };

  build-system = [ poetry-core ];
  dependencies = [ playwright ];
  pyproject = true;
  pythonImportsCheck = [ "playwright_stealth" ];

  meta = {
    description = "Make your playwright instance stealthy";
    homepage = "https://github.com/AtuboDad/playwright_stealth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
