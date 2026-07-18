{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "glob";
  version = "10.3.3";

  src = fetchFromGitHub {
    owner = "isaacs";
    repo = "node-glob";
    rev = "v${version}";
    hash = "sha256-oLlNhQOnu/hlKjNWa5vjqslz1EarZJOpUEXUB+vGQvc=";
  };

  npmDepsHash = "sha256-78oODw+CBCk5JRJbDqLqVmzTVImP7Z7o6jRIimDxZDQ=";
  dontNpmBuild = true;

  meta = {
    description = "Little globber for Node.js";
    homepage = "https://github.com/isaacs/node-glob";
    changelog = "https://github.com/isaacs/node-glob/blob/${src.rev}/changelog.md";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "glob";
  };
}
