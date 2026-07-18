{
  lib,
  fetchFromGitHub,
  bcftools,
  htslib,
  python3Packages,
  runtimeShell,
}:

let
  ssshtest = fetchFromGitHub {
    hash = "sha256-zecZHEnfhDtT44VMbHLHOhRtNsIMWeaBASupVXtmrks=";
    owner = "ryanlayer";
    repo = "ssshtest";
    rev = "d21f7f928a167fca6e2eb31616673444d15e6fd0";
  };
in
python3Packages.buildPythonApplication rec {
  pname = "truvari";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "ACEnglish";
    repo = "truvari";
    rev = "v${version}";
    hash = "sha256-SFBVatcVavBfQtFbBcXifBX3YnKsxJS669vCcyjsBA4=";
  };

  postPatch = ''
    substituteInPlace truvari/utils.py \
      --replace "/bin/bash" "${runtimeShell}"
    patchShebangs repo_utils/test_files
  '';

  nativeCheckInputs = [
    bcftools
    htslib
  ]
  ++ (with python3Packages; [
    coverage
  ]);

  checkPhase = ''
    runHook preCheck

    ln -s ${ssshtest}/ssshtest .
    bash repo_utils/truvari_ssshtests.sh

    runHook postCheck
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    pywfa
    rich
    edlib
    pysam
    intervaltree
    joblib
    numpy
    pytabix
    bwapy
    pandas
    pyabpoa
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      bcftools
      htslib
    ])
  ];

  pyproject = true;
  pythonImportsCheck = [ "truvari" ];

  meta = {
    description = "Structural variant comparison tool for VCFs";

    longDescription = ''
      Truvari is a benchmarking tool for comparison sets of SVs.
      It can calculate the recall, precision, and f-measure of a
      vcf from a given structural variant caller. The tool
      is created by Spiral Genetics.
    '';

    homepage = "https://github.com/ACEnglish/truvari";
    changelog = "https://github.com/ACEnglish/truvari/releases/tag/${src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
    ];
  };
}
