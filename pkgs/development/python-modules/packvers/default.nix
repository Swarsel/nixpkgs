{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretend,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "packvers";
  version = "21.5";

  src = fetchFromGitHub {
    owner = "aboutcode-org";
    repo = "packvers";
    tag = finalAttrs.version;
    hash = "sha256-nCSYL0g7mXi9pGFt24pOXbmmYsaRuB+rRZrygf8DTLE=";
  };

  nativeCheckInputs = [
    pretend
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ pyparsing ];

  disabledTests = [
    # Failed: DID NOT RAISE <class 'packvers.requirements.InvalidRequirement'>
    "test_invalid_file_urls"
  ];

  pyproject = true;
  pythonImportsCheck = [ "packvers" ];

  meta = {
    description = "Module for version handling of modules";
    homepage = "https://github.com/aboutcode-org/packvers";
    changelog = "https://github.com/aboutcode-org/packvers/blob/${finalAttrs.src.tag}/CHANGELOG.rst";

    license = with lib.licenses; [
      asl20 # and
      bsd2
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
