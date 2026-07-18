{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mkdocs,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-custom-tags-attributes";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "Mara-Li";
    repo = "mkdocs-custom-tags-attributes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AtjUMk7v3+QI76nnPslqW/8LO11ld0YLSacHI6eaurs=";
  };

  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    mkdocs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "custom_attributes"
  ];

  meta = {
    description = "A mkdocs plugin to create custom attributes using hashtags";
    homepage = "https://github.com/Mara-Li/mkdocs-custom-tags-attributes";
    changelog = "https://github.com/Mara-Li/mkdocs-custom-tags-attributes/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "mkdocs-custom-tags-attributes";
  };
})
