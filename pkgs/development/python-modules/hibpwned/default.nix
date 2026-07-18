{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hibpwned";
  version = "1.3.9";

  src = fetchFromGitHub {
    owner = "plasticuproject";
    repo = "hibpwned";
    tag = finalAttrs.version;
    hash = "sha256-d3EhRu7HcvbyjWWHVSax0j39yE4+hJp8zvtyRKoh4sY=";
  };

  # Test require network access
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "hibpwned" ];

  meta = {
    description = "Python API wrapper for haveibeenpwned.com";
    homepage = "https://github.com/plasticuproject/hibpwned";
    changelog = "https://github.com/plasticuproject/hibpwned/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
