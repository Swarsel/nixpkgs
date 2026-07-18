{
  lib,
  fetchFromGitHub,
  python312Packages,
}:

# ao3downloader explicitly does not support Python 3.13 yet
# https://github.com/nianeyna/ao3downloader/blob/f8399bb8aca276ae7359157b90afd13925c90056/pyproject.toml#L8
python312Packages.buildPythonApplication (finalAttrs: {
  pname = "ao3downloader";
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "nianeyna";
    repo = "ao3downloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cyn4bWHKKfRGade8A1kAJRJzdcXCY46nGgVw5i0OUyQ=";
  };

  nativeCheckInputs = with python312Packages; [
    pytestCheckHook
    syrupy
    pythonImportsCheckHook
  ];

  build-system = with python312Packages; [
    hatchling
  ];

  dependencies = with python312Packages; [
    beautifulsoup4
    mobi
    pdfquery
    requests
    six
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ao3downloader"
  ];

  pythonRelaxDeps = [
    "requests"
  ];

  meta = {
    description = "Utility for downloading fanfiction in bulk from the Archive of Our Own";
    homepage = "https://nianeyna.dev/ao3downloader";
    changelog = "https://github.com/nianeyna/ao3downloader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.samasaur ];
    mainProgram = "ao3downloader";
  };
})
