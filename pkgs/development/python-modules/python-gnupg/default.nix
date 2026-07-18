{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gnupg,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-gnupg";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "vsajip";
    repo = "python-gnupg";
    tag = finalAttrs.version;
    hash = "sha256-ztwITune/rO4c3wUCsw6wBN09jnpWpElgwQx7JCXsVw=";
  };

  postPatch = ''
    substituteInPlace gnupg.py \
      --replace "gpgbinary='gpg'" "gpgbinary='${lib.getExe gnupg}'"
    substituteInPlace test_gnupg.py \
      --replace "os.environ.get('GPGBINARY', 'gpg')" "os.environ.get('GPGBINARY', '${lib.getExe gnupg}')"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # network access
    "test_search_keys"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gnupg" ];

  meta = {
    description = "API for the GNU Privacy Guard (GnuPG)";
    homepage = "https://github.com/vsajip/python-gnupg";
    changelog = "https://github.com/vsajip/python-gnupg/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
