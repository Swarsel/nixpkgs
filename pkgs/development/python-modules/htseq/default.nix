{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  matplotlib,
  nix-update-script,
  numpy,
  pandas,
  pysam,
  pytestCheckHook,
  setuptools,
  swig,
}:
buildPythonPackage rec {
  pname = "htseq";
  version = "2.0.9";

  src = fetchFromGitHub {
    owner = "htseq";
    repo = "htseq";
    rev = "release_${version}";
    hash = "sha256-i83BY7/p98/pfYzebolNW/6yNwtb2R5ARCSG3rAq2/M=";
  };

  nativeBuildInputs = [ swig ];

  nativeCheckInputs = [
    pandas
    pytestCheckHook
  ]
  ++ optional-dependencies.htseq-qa;

  preCheck = ''
    rm -r src HTSeq
    export PATH=$out/bin:$PATH
  '';

  build-system = [
    cython
    numpy
    pysam
    setuptools
  ];

  dependencies = [
    numpy
    pysam
  ];

  optional-dependencies = {
    htseq-qa = [ matplotlib ];
  };

  pyproject = true;
  pythonImportsCheck = [ "HTSeq" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "release_(.+)"
    ];
  };

  meta = {
    description = "Framework to work with high-throughput sequencing data";
    homepage = "https://htseq.readthedocs.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ unode ];
  };
}
