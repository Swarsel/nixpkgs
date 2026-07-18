{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tlds";
  version = "2026041800";

  src = fetchFromGitHub {
    owner = "kichik";
    repo = "tlds";
    tag = finalAttrs.version;
    hash = "sha256-HMfAMYVNz/3lwCv5XTn7jSgFQgGX2uymTGxw8JcHeUU=";
  };

  nativeBuildInputs = [ setuptools ];
  # no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "tlds" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automatically updated list of valid TLDs taken directly from IANA";
    homepage = "https://github.com/kichik/tlds";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
