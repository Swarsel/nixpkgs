{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "infrared-protocols";
  version = "6.3.1";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "infrared-protocols";
    tag = finalAttrs.version;
    hash = "sha256-6kyb0a0cCwVSS4evDGg0Z7wLGhDUHnLeXUJ9PW+fhHk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "infrared_protocols" ];

  meta = {
    description = "Library to decode and encode infrared signals";
    homepage = "https://github.com/home-assistant-libs/infrared-protocols";
    changelog = "https://github.com/home-assistant-libs/infrared-protocols/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
