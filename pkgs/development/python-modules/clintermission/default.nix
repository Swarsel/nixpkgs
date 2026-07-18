{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  prompt-toolkit,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "clintermission";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "sebageek";
    repo = "clintermission";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e7C9IDr+mhVSfU8lMywjX1BYwFo/qegPNzabak7UPcY=";
  };

  # repo contains no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ prompt-toolkit ];
  pyproject = true;
  pythonImportsCheck = [ "clintermission" ];

  meta = {
    description = "Non-fullscreen command-line selection menu";
    homepage = "https://github.com/sebageek/clintermission";
    changelog = "https://github.com/sebageek/clintermission/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
