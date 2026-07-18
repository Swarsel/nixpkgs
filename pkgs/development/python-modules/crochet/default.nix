{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  twisted,
  wrapt,
}:

buildPythonPackage rec {
  pname = "crochet";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "itamarst";
    repo = "crochet";
    tag = version;
    hash = "sha256-grymhvCC9zDBKhNnQC0o07hdLPV5KMWb6HSz/ntSbq8=";
  };

  # fix for python>=3.12
  postPatch = ''
    substituteInPlace versioneer.py \
      --replace-fail "SafeConfigParser()" "ConfigParser()" \
      --replace-fail "parser.readfp" "parser.read_file"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    twisted
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "crochet" ];

  meta = {
    description = "Library that makes it easier to use Twisted from regular blocking code";
    homepage = "https://github.com/itamarst/crochet";
    changelog = "https://github.com/itamarst/crochet/blob/${src.tag}/docs/news.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
