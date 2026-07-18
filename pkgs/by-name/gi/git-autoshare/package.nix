{
  lib,
  fetchFromGitHub,
  git,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-autoshare";
  version = "1.0.0b6";

  src = fetchFromGitHub {
    owner = "acsone";
    repo = "git-autoshare";
    rev = finalAttrs.version;
    hash = "sha256-F8wcAayIR6MH8e0cQSwFJn/AVSLG3tVil80APjcFG/0=";
  };

  # Tests require network
  doCheck = false;
  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    appdirs
    click
    pyyaml
  ];

  makeWrapperArgs = [ "--set-default GIT_AUTOSHARE_GIT_BIN ${lib.getExe git}" ];
  pyproject = true;
  pythonImportsCheck = [ "git_autoshare" ];

  meta = {
    description = "Git clone wrapper that automatically uses --reference to save disk space and download time";
    homepage = "https://github.com/acsone/git-autoshare";
    changelog = "https://github.com/acsone/git-autoshare/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ yajo ];
  };
})
