{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  poetry-core,
  scaleway-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "scaleway";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "scaleway";
    repo = "scaleway-sdk-python";
    tag = finalAttrs.version;
    hash = "sha256-v/dN0vLXr+vCobcrH9E6wXS61qMHsESHyL5BEpsJPkM=";
  };

  # Tests require credentials
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ poetry-core ];
  dependencies = [ scaleway-core ];
  pyproject = true;
  pythonImportsCheck = [ "scaleway" ];
  sourceRoot = "${finalAttrs.src.name}/${finalAttrs.pname}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Integrate Scaleway with your Python applications";
    homepage = "https://github.com/scaleway/scaleway-sdk-python";
    changelog = "https://github.com/scaleway/scaleway-sdk-python/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
