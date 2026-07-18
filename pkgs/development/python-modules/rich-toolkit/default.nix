{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  # build-system
  hatchling,
  # tests
  inline-snapshot,
  pydantic,
  pytestCheckHook,
  rich,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "rich-toolkit";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "patrick91";
    repo = "rich-toolkit";
    tag = finalAttrs.version;
    hash = "sha256-XYSksCMCCxO6wzsEEJ6X340iT32hU5n/EikKLZ2m7A0=";
  };

  postPatch = ''
    # the commit updating the version happens only after tagging
    sed -i 's/version = ".*"/version = "${finalAttrs.version}"/' pyproject.toml
  '';

  nativeCheckInputs = [
    inline-snapshot
    pydantic
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    click
    rich
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "rich_toolkit" ];

  meta = {
    description = "Rich toolkit for building command-line applications";
    homepage = "https://github.com/patrick91/rich-toolkit/";
    changelog = "https://github.com/patrick91/rich-toolkit/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
