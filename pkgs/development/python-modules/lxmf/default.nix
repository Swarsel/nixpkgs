{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  qrcode,
  rns,
  setuptools,
  versionCheckHook,
  # rns optionally depends on lxmf but we can't have two versions of rns in a closure
  propagateRns ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "lxmf";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "lxmf";
    tag = finalAttrs.version;
    hash = "sha256-Lx7eG7idbqjJrOE15/OJ8kh++4STQHxNVMTRVXdAEYE=";
  };

  buildInputs = lib.optionals (!propagateRns) [
    rns
  ];

  nativeCheckInputs = lib.optionals propagateRns [
    versionCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    qrcode
  ]
  ++ lib.optionals propagateRns [
    rns
  ];

  pyproject = true;
  pythonImportsCheck = [ "LXMF" ];

  meta = {
    description = "Lightweight Extensible Message Format for Reticulum";
    homepage = "https://github.com/markqvist/lxmf";
    changelog = "https://github.com/markqvist/LXMF/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.reticulum;

    maintainers = with lib.maintainers; [
      drupol
      fab
    ];

    mainProgram = "lxmd";
  };
})
