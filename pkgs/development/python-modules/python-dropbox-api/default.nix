{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-dropbox-api";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "bdr99";
    repo = "python-dropbox-api";
    tag = finalAttrs.version;
    hash = "sha256-Ry2FsatM2pOxcnwdlPr1RFaHCEvbsaa+RAHxpav5leM=";
  };

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "python_dropbox_api" ];

  meta = {
    description = "Lightweight wrapper for the Dropbox API intended for use in Home Assistant";
    homepage = "https://github.com/bdr99/python-dropbox-api";
    changelog = "https://github.com/bdr99/python-dropbox-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
