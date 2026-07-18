{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "render50";
  version = "9.2.10";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "render50";
    tag = "v${version}";
    hash = "sha256-YaLLWrae8vgOYLmfFlPa6WkKGNlUj+n76NRpg0qm6QI=";
  };

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    backports-shutil-which
    braceexpand
    beautifulsoup4
    natsort
    pygments
    pypdf
    requests
    six
    termcolor
    weasyprint
  ];

  pyproject = true;

  # no pytest checks
  meta = {
    description = "Generate syntax-highlighted PDFs of source code";
    homepage = "https://cs50.readthedocs.io/render50/";
    changelog = "https://github.com/cs50/render50/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "render50";
    downloadPage = "https://github.com/cs50/render50";
  };
}
