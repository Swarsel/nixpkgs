{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  decorator,
  dunamai,
  funcy,
  git,
  hatch-vcs,
  hatchling,
  iteration-utilities,
  jinja2,
  jinja2-ansible-filters,
  mkdocs-material,
  mkdocs-mermaid2-plugin,
  mkdocstrings,
  nix-update-script,
  packaging,
  pathspec,
  plumbum,
  pydantic,
  pygments,
  pyyaml,
  pyyaml-include,
  questionary,
}:

buildPythonPackage rec {
  pname = "copier";
  version = "9.17.0";

  src = fetchFromGitHub {
    owner = "copier-org";
    repo = "copier";
    tag = "v${version}";
    hash = "sha256-I98GGrFSKgDlFQU3dAYsu7Z2mtO8NWPT0CoMtdw/EI8=";

    # Conflict on APFS on darwin
    postFetch = ''
      rm $out/tests/demo/doc/ma*ana.txt
    '';
  };

  env.POETRY_DYNAMIC_VERSIONING_BYPASS = version;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    colorama
    decorator
    dunamai
    funcy
    iteration-utilities
    jinja2
    jinja2-ansible-filters
    mkdocs-material
    mkdocs-mermaid2-plugin
    mkdocstrings
    packaging
    pathspec
    plumbum
    pydantic
    pygments
    pyyaml
    pyyaml-include
    questionary
  ];

  makeWrapperArgs = [ "--suffix PATH : ${lib.makeBinPath [ git ]}" ];
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library and command-line utility for rendering projects templates";
    homepage = "https://copier.readthedocs.io";
    changelog = "https://github.com/copier-org/copier/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      greg
      savtrip
    ];

    mainProgram = "copier";
  };
}
