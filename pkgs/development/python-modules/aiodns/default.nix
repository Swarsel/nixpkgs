{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycares,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiodns";
  version = "4.0.4";

  src = fetchFromGitHub {
    owner = "saghul";
    repo = "aiodns";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TLiiSRhZaEbHeyrQPk8uvj10VEttRanYEgkBy7DxH4Y=";
  };

  # Could not contact DNS servers
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pycares ];
  pyproject = true;
  pythonImportsCheck = [ "aiodns" ];

  meta = {
    description = "Simple DNS resolver for asyncio";
    homepage = "https://github.com/saghul/aiodns";
    changelog = "https://github.com/saghul/aiodns/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
