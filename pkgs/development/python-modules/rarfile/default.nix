{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libarchive,
  pytestCheckHook,
  setuptools,
  unrar,
  # unrar is non-free software
  useUnrar ? false,
}:

assert useUnrar -> unrar != null;
assert !useUnrar -> libarchive != null;

buildPythonPackage rec {
  pname = "rarfile";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "markokr";
    repo = "rarfile";
    tag = "v${version}";
    hash = "sha256-ZiwD2LG25fMd4Z+QWsh/x3ceG5QRBH4s/TZDwMnfpNI=";
  };

  # The tests only work with the standard unrar package
  doCheck = useUnrar;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  prePatch = ''
    substituteInPlace rarfile.py \
  ''
  + (
    if useUnrar then
      ''
        --replace 'UNRAR_TOOL = "unrar"' "UNRAR_TOOL = \"${unrar}/bin/unrar\""
      ''
    else
      ''
        --replace 'ALT_TOOL = "bsdtar"' "ALT_TOOL = \"${libarchive}/bin/bsdtar\""
      ''
  )
  + "";

  pyproject = true;
  pythonImportsCheck = [ "rarfile" ];

  meta = {
    description = "RAR archive reader for Python";
    homepage = "https://github.com/markokr/rarfile";
    changelog = "https://github.com/markokr/rarfile/releases/tag/v${version}";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
