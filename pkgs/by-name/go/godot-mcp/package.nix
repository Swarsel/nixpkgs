{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "godot-mcp";
  version = "0-unstable-2026-01-30";

  src = fetchFromGitHub {
    owner = "Coding-Solo";
    repo = "godot-mcp";
    rev = "f341234dfe44613e1d48fe4fbc8bfb9bf2e8e9eb";
    hash = "sha256-cUGaO+6zP+3oUuB4Ni1HfBkb7QVxk9tznUkoxfQqH+s=";
  };

  npmDepsHash = "sha256-9F2QW8+IQiL+qZ4EXSq1pgk3DMmES8aAP3CAwL+fDfc=";
  doCheck = false;

  npmBuildFlags = [
    "run"
    "build"
  ];

  npmInstallFlags = [
    "--ignore-scripts"
  ];

  meta = {
    description = "MCP server for interfacing with Godot game engine";

    longDescription = ''
      A Model Context Protocol (MCP) server for interacting with the Godot
      game engine. Enables AI assistants to launch the Godot editor, run
      projects, capture debug output, and control project execution.
    '';

    homepage = "https://github.com/Coding-Solo/godot-mcp";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "godot-mcp";
  };
}
