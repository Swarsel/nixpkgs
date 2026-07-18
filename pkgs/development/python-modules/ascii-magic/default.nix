{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  pillow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ascii-magic";
  version = "2.7.4";

  src = fetchFromGitHub {
    owner = "LeandroBarone";
    repo = "python-ascii_magic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-werCg7LW7MKMoYp/QxZU74MSc6WmscwWfvGRG4Dn60c=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    ln -s ascii_magic/tests/*.{jpg,png} ./
  '';

  build-system = [ setuptools ];

  dependencies = [
    colorama
    pillow
  ];

  disabledTests = [
    # Test requires network access
    "test_from_url"
    "test_quick_test"
    "test_wrong_url"
    # No clipboard in the sandbox
    "test_from_clipboard"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ascii_magic" ];

  meta = {
    description = "Python module to converts pictures into ASCII art";
    homepage = "https://github.com/LeandroBarone/python-ascii_magic";
    changelog = "https://github.com/LeandroBarone/python-ascii_magic#changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
