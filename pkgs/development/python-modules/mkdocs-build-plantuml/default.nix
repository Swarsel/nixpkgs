{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httplib2,
  mkdocs,
  pkgs, # Only for pkgs.plantuml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkdocs-build-plantuml";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "christo-ph";
    repo = "mkdocs_build_plantuml";
    tag = version;
    hash = "sha256-KTtZXeMZwbrx1M6Keu9BzT3GmarsVx9kEmn63rwHatI=";
  };

  # There's only one substitution, no patch is needed.
  postPatch = ''
    substituteInPlace mkdocs_build_plantuml_plugin/plantuml.py \
      --replace-fail "shutil.which('plantuml') or 'plantuml'" "'${lib.getExe pkgs.plantuml}'"
  '';

  # No tests available
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    httplib2
    mkdocs
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_build_plantuml_plugin" ];

  meta = {
    description = "MkDocs plugin to help generate your plantuml images locally or remotely as files (NOT inline)";
    homepage = "https://github.com/christo-ph/mkdocs_build_plantuml";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
