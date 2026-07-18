{
  lib,
  fetchFromGitHub,
  bwa,
  fermi2,
  python3Packages,
  ropebwt2,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tiddit";
  version = "3.9.5";

  src = fetchFromGitHub {
    owner = "SciLifeLab";
    repo = "TIDDIT";
    tag = "TIDDIT-${finalAttrs.version}";
    hash = "sha256-6uJZzetqRS0czX4qjjPgiSaPun7BkrPYllDdFWNK84k=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    cython
    joblib
    numpy
    pysam
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        bwa
        fermi2
        ropebwt2
      ]
    }"
    "--set PYTHONPATH $PYTHONPATH"
  ];

  pyproject = true;

  meta = {
    description = "Identify chromosomal rearrangements using Mate Pair or Paired End sequencing data";
    homepage = "https://github.com/SciLifeLab/TIDDIT";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ apraga ];
    platforms = lib.platforms.unix;
    mainProgram = "tiddit";
  };
})
