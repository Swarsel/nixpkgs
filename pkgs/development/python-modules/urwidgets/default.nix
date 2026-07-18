{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  urwid,
}:

buildPythonPackage rec {
  pname = "urwidgets";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "AnonymouX47";
    repo = "urwidgets";
    tag = "v${version}";
    hash = "sha256-RgY7m0smcdUspGkCdzepxruEMDq/mAsVFNjHMLoWAyc=";
  };

  build-system = [ setuptools ];
  dependencies = [ urwid ];
  pyproject = true;
  pythonImportsCheck = [ "urwidgets" ];
  pythonRelaxDeps = [ "urwid" ];

  meta = {
    description = "Collection of widgets for urwid";
    homepage = "https://github.com/AnonymouX47/urwidgets";
    changelog = "https://github.com/AnonymouX47/urwidgets/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ huyngo ];
  };
}
