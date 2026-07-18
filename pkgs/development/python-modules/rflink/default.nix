{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  pyserial,
  pyserial-asyncio-fast,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rflink";
  version = "0.0.68";

  src = fetchFromGitHub {
    owner = "aequitas";
    repo = "python-rflink";
    tag = version;
    hash = "sha256-0mMBZYN3xzRotVuLw2HgzSVhsXUv531x3i97B2lI5KE=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "version=version_from_git()" "version='${version}'"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    docopt
    pyserial
    pyserial-asyncio-fast
  ];

  pyproject = true;
  pythonImportsCheck = [ "rflink.protocol" ];

  meta = {
    description = "Library and CLI tools for interacting with RFlink 433MHz transceiver";
    homepage = "https://github.com/aequitas/python-rflink";
    changelog = "https://github.com/aequitas/python-rflink/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
