{
  lib,
  fetchFromGitHub,
  djhtml,
  libclang,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "style50";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "style50";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D2ucfVVGZFzmcAUyOfu97QJ8x9pzRo1hYrwZlV8MRN8=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        libclang # clang-format
      ]
    })
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    autopep8
    cssbeautifier
    djhtml
    icdiff
    jinja2
    jsbeautifier
    pycodestyle
    python-magic
    sqlparse
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "style50" ];

  pythonRelaxDeps = [
    "pycodestyle"
  ];

  pythonRemoveDeps = [
    "clang-format"
  ];

  meta = {
    description = "Tool for checking code against the CS50 style guide";
    homepage = "https://cs50.readthedocs.io/style50/";
    changelog = "https://github.com/cs50/style50/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "style50";
    downloadPage = "https://github.com/cs50/style50";
  };
})
