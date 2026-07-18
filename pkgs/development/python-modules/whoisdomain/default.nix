{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "whoisdomain";
  version = "1.20260326.1";

  src = fetchFromGitHub {
    owner = "mboot-github";
    repo = "WhoisDomain";
    tag = finalAttrs.version;
    hash = "sha256-4EWxQq88RWH3yQYVfo07U7jG5ws+SJ7SAq2Mc8nyeRU=";
  };

  # Tests require network access
  doCheck = false;
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "whoisdomain" ];

  meta = {
    description = "Module to perform whois lookups";
    homepage = "https://github.com/mboot-github/WhoisDomain";
    changelog = "https://github.com/mboot-github/WhoisDomain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "whoisdomain";
  };
})
