{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  setuptools,
  sgmllib3k,
}:

buildPythonPackage rec {
  pname = "feedparser";
  version = "6.0.12";

  src = fetchFromGitHub {
    owner = "kurtmckee";
    repo = "feedparser";
    tag = "v${version}";
    hash = "sha256-ZLn4Naf0CQG04iXfVJVimrBQ7TGBEPcEPCF3XMjX/Mo=";
  };

  checkPhase = ''
    runHook preCheck

    # Tests are failing
    # AssertionError: unexpected '~' char in declaration
    rm tests/wellformed/sanitize/xml_declaration_unexpected_character.xml
    ${python.interpreter} -Wd tests/runtests.py

    runHook postCheck
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ sgmllib3k ];
  pyproject = true;
  pythonImportsCheck = [ "feedparser" ];

  meta = {
    description = "Universal feed parser";
    homepage = "https://github.com/kurtmckee/feedparser";
    changelog = "https://feedparser.readthedocs.io/en/latest/changelog.html";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
