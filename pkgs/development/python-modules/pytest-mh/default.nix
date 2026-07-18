{
  lib,
  fetchFromGitHub,
  ansible-pylibssh,
  buildPythonPackage,
  colorama,
  gitUpdater,
  hatch-requirements-txt,
  hatch-vcs,
  hatchling,
  pytest,
  pyyaml,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-mh";
  version = "1.0.29";

  src = fetchFromGitHub {
    owner = "next-actions";
    repo = "pytest-mh";
    tag = finalAttrs.version;
    hash = "sha256-1QaqHDS+eU1O2aLWtdd6XWxErwqONAPngKe8FqYAmJY=";
  };

  # Patch requirements.txt out of the package
  postInstall = ''
    rm -f $out/lib/python*/site-packages/requirements.txt
  '';

  build-system = [
    hatchling
    hatch-vcs
    hatch-requirements-txt
  ];

  dependencies = [
    ansible-pylibssh
    colorama
    pytest
    pyyaml
  ];

  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "pytest plugin that allows you to run shell commands and scripts over SSH on remote Linux or Windows hosts";
    homepage = "https://github.com/next-actions/pytest-mh";
    changelog = "https://github.com/next-actions/pytest-mh/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ joaosreis ];
  };
})
