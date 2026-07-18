{
  lib,
  fetchFromGitHub,
  buildOctavePackage,
  datatypes,
  gnuplot,
  io,
  makeFontsConf,
  writableTmpDirAsHomeHook,
}:

buildOctavePackage rec {
  pname = "statistics";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "statistics";
    tag = "release-${version}";
    hash = "sha256-1u/uXrbRNT14TbW89J8noCnwShD/B/Wz0cpurmsTzTU=";
  };

  __structuredAttrs = true;

  nativeOctavePkgTestInputs = [
    gnuplot
    writableTmpDirAsHomeHook
  ];

  octavePkgTestEnv.FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

  requiredOctavePackages = [
    io
    datatypes
  ];

  meta = {
    description = "Statistics package for GNU Octave";
    homepage = "https://packages.octave.org/statistics";

    license = with lib.licenses; [
      gpl3Plus
      publicDomain
    ];

    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
