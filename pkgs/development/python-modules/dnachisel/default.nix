{
  lib,
  fetchFromGitHub,
  biopython,
  buildPythonPackage,
  docopt,
  flametree,
  genome-collector,
  matplotlib,
  numpy,
  primer3,
  proglog,
  pytestCheckHook,
  python-codon-tables,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dnachisel";
  version = "3.2.16";

  src = fetchFromGitHub {
    owner = "Edinburgh-Genome-Foundry";
    repo = "DnaChisel";
    tag = "v${version}";
    hash = "sha256-F+G7dwehUCHYKSGsLQR4OZg2NQ4677XMlN6jOcmz8No=";
  };

  nativeCheckInputs = [
    primer3
    genome-collector
    matplotlib
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    biopython
    docopt
    flametree
    numpy
    proglog
    python-codon-tables
  ];

  # Disable tests which requires network access
  disabledTests = [
    "test_circular_sequence_optimize_with_report"
    "test_constraints_reports"
    "test_optimize_with_report"
    "test_optimize_with_report_no_solution"
    "test_avoid_blast_matches_with_list"
    "test_avoid_phage_blast_matches"
    "test_avoid_matches_with_list"
    "test_avoid_matches_with_phage"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dnachisel" ];

  meta = {
    description = "Optimize DNA sequences under constraints";
    homepage = "https://github.com/Edinburgh-Genome-Foundry/DnaChisel";
    changelog = "https://github.com/Edinburgh-Genome-Foundry/DnaChisel/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
