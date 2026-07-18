{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:

let
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      lsprotocol = self.lsprotocol_2023;
      pygls = self.pygls_1;
    }
  );
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "nginx-language-server";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "pappasam";
    repo = "nginx-language-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v9+Y8NBvN8HvTdNrK9D9YQuqDB3olIu5LfYapjlVlAM=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = with pythonPackages; [
    poetry-core
  ];

  dependencies = with pythonPackages; [
    crossplane
    lsprotocol
    pydantic
    pygls
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "nginx_language_server" ];

  pythonRelaxDeps = [
    "pydantic"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language server for nginx.conf";
    homepage = "https://github.com/pappasam/nginx-language-server";
    changelog = "https://github.com/pappasam/nginx-language-server/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "nginx-language-server";
  };
})
