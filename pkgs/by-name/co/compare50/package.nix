{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "compare50";
  version = "1.2.13";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "compare50";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qRESVE9242Leo6js+YrRrLff7C3IjWFKSN2/GsC/8VA=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail \
      'scripts=["bin/compare50"]' 'entry_points={"console_scripts": ["compare50=compare50.__main__:main"]}'
    # auto included in current python version, no install needed
    substituteInPlace setup.py --replace-fail \
      'importlib' ' '
  '';

  nativeCheckInputs = [ versionCheckHook ];

  # repo does not use pytest
  checkPhase = ''
    runHook preCheck

    ${python3Packages.python.interpreter} -m tests

    runHook postCheck
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    attrs
    intervaltree
    jinja2
    lib50
    numpy
    packaging
    pygments
    termcolor
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "compare50" ];

  pythonRelaxDeps = [
    "attrs"
    "numpy"
    "termcolor"
  ];

  meta = {
    description = "Tool for detecting similarity in code supporting over 300 languages";
    homepage = "https://cs50.readthedocs.io/projects/compare50/en/latest/";
    changelog = "https://github.com/cs50/compare50/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "compare50";
    downloadPage = "https://github.com/cs50/compare50";
  };
})
