{
  buildPythonPackage,
  # build system
  hatchling,
  logfire,
}:

buildPythonPackage (finalAttrs: {
  inherit (logfire) version src;
  pname = "logfire-api";
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "logfire_api" ];
  sourceRoot = "${finalAttrs.src.name}/logfire-api";

  meta = logfire.meta // {
    description = "Shim for the Logfire SDK which does nothing unless Logfire is installed";
  };
})
