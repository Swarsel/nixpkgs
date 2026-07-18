{
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "arxiv-latex-cleaner";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "google-research";
    repo = "arxiv-latex-cleaner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q3vNGF9uOForLawJtp424Tv3MaVfUSqk4orv9gojm3M=";
  };

  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest arxiv_latex_cleaner.tests.arxiv_latex_cleaner_test
    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pillow
    pyyaml
    regex
    absl-py
  ];

  pyproject = true;

  meta = {
    description = "Easily clean the LaTeX code of your paper to submit to arXiv";
    homepage = "https://github.com/google-research/arxiv-latex-cleaner";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arkivm ];
    mainProgram = "arxiv_latex_cleaner";
  };
})
