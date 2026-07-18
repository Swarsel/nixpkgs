{
  lib,
  fetchFromGitHub,
  blast,
  diamond,
  mafft,
  python3Packages,
  raxml,
  trimal,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "phylophlan";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "biobakery";
    repo = "phylophlan";
    tag = finalAttrs.version;
    hash = "sha256-rPTEdu0W3LD27tDIWCOQ3K+RJuj97I9aEeYFdM77jOs=";
  };

  # It has no tests
  doCheck = false;

  postInstall = ''
    # Not revelant in this context
    rm -f $out/bin/phylophlan_write_default_configs.sh
  '';

  preFixup = ''
    # Minimum needed external tools
    # See https://github.com/biobakery/phylophlan/wiki#dependencies
    makeWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        raxml
        mafft
        trimal
        blast
        diamond
      ]
    }
    )
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    biopython
    dendropy
    matplotlib
    numpy
    pandas
    seaborn
    distutils
    requests
    scipy
    tqdm
  ];

  pyproject = true;

  meta = {
    description = "Precise phylogenetic analysis of microbial isolates and genomes from metagenomes";
    homepage = "https://github.com/biobakery/phylophlan";
    changelog = "https://github.com/biobakery/phylophlan/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "phylophlan";
  };
})
