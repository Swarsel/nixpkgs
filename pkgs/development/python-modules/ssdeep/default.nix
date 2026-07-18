{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  pytestCheckHook,
  setuptools,
  six,
  ssdeep,
}:

buildPythonPackage (finalAttrs: {
  pname = "ssdeep";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "DinoTools";
    repo = "python-ssdeep";
    tag = finalAttrs.version;
    hash = "sha256-I5ci5BS+B3OE0xdLSahu3HCh99jjhnRHJFz830SvFpg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner"' ""
  '';

  buildInputs = [ ssdeep ];
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    cffi
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "ssdeep" ];

  meta = {
    description = "Python wrapper for the ssdeep library";
    homepage = "https://github.com/DinoTools/python-ssdeep";
    changelog = "https://github.com/DinoTools/python-ssdeep/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
