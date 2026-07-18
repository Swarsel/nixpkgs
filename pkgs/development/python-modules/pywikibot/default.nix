{
  lib,
  buildPythonPackage,
  fetchPypi,
  mwparserfromhell,
  packaging,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pywikibot";
  version = "10.7.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/hHfZRLoEgaPKZLus9x/d5O62GnwU/1A7PAsebGj634=";
  };

  # Tests attempt to install a tool using pip, which fails due to the sandbox
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    mwparserfromhell
    requests
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywikibot" ];

  meta = {
    description = "Python MediaWiki bot framework";
    homepage = "https://www.mediawiki.org/wiki/Manual:Pywikibot";
    changelog = "https://doc.wikimedia.org/pywikibot/master/changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomodachi94 ];
    mainProgram = "pwb";
  };
}
