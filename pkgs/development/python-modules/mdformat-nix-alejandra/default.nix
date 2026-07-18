{
  lib,
  fetchFromGitHub,
  alejandra,
  buildPythonPackage,
  mdformat,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-nix-alejandra";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "aldoborrero";
    repo = "mdformat-nix-alejandra";
    tag = finalAttrs.version;
    hash = "sha256-jUXApGsxCA+pRm4m4ZiHWlxmVkqCPx3A46oQdtyKz5g=";
  };

  postPatch = ''
    substituteInPlace mdformat_nix_alejandra/__init__.py \
      --replace-fail '"alejandra"' '"${lib.getExe alejandra}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ mdformat ];
  pyproject = true;
  pythonImportsCheck = [ "mdformat_nix_alejandra" ];

  pythonRelaxDeps = [
    "mdformat"
  ];

  meta = {
    description = "Mdformat plugin format Nix code blocks with alejandra";
    homepage = "https://github.com/aldoborrero/mdformat-nix-alejandra";
    changelog = "https://github.com/aldoborrero/mdformat-nix-alejandra/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldoborrero ];
  };
})
