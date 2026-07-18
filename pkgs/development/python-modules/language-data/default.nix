{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  marisa-trie,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "language-data";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "georgkrause";
    repo = "language_data";
    tag = "v${version}";
    hash = "sha256-cWjeb2toGrnNSsK566e18NgWhv6YdQrKEzFPilmBdoA=";
  };

  # No unittests
  doCheck = false;
  build-system = [ setuptools-scm ];
  dependencies = [ marisa-trie ];
  pyproject = true;
  pythonImportsCheck = [ "language_data" ];

  meta = {
    description = "Supplement module for langcodes";
    homepage = "https://github.com/georgkrause/language_data";
    changelog = "https://github.com/georgkrause/language_data/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
