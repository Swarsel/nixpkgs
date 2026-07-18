{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  flit-core,
  flit-scm,
  pygments,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "ssdp";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "codingjoe";
    repo = "ssdp";
    tag = finalAttrs.version;
    hash = "sha256-1LO5+lfykaepp+MfS/2mlngobhcV1nZvU19Jb0sbVzk=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    flit-core
    flit-scm
  ];

  optional-dependencies = {
    cli = [
      click
      pygments
    ];

    pygments = [ pygments ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ssdp" ];

  meta = {
    description = "Python asyncio library for Simple Service Discovery Protocol (SSDP)";
    homepage = "https://github.com/codingjoe/ssdp";
    changelog = "https://github.com/codingjoe/ssdp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ssdp";
  };
})
