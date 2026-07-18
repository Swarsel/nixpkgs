{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "octosuite";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "bellingcat";
    repo = "octosuite";
    tag = finalAttrs.version;
    hash = "sha256-bgTAGIJbxOa8q8lMsWa8dHwNZ/jXiWGQOp921sd2Vdo=";
  };

  postPatch = ''
    # pyreadline3 is Windows-only
    substituteInPlace pyproject.toml \
      --replace-fail '"pyreadline3",' ""
  '';

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    psutil
    requests
    rich
  ];

  pyproject = true;

  pythonImportsCheck = [
    "octosuite"
  ];

  meta = {
    description = "Advanced Github OSINT framework";
    homepage = "https://github.com/bellingcat/octosuite";
    changelog = "https://github.com/bellingcat/octosuite/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "octosuite";
  };
})
