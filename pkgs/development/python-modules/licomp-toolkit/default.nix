{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  # dependencies
  foss-flame,
  licomp,
  licomp-doubleopen,
  licomp-dwheeler,
  licomp-gnuguide,
  licomp-hermione,
  licomp-osadl,
  licomp-oslc-handbook,
  licomp-proprietary,
  licomp-reclicense,
  # tests
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "licomp-toolkit";
  version = "0.5.20";

  src = fetchFromGitea {
    owner = "software-compliance-org";
    repo = "licomp-toolkit";
    tag = finalAttrs.version;
    hash = "sha256-E6ehhQj1EcpW+8Cf2b+dtYSCH7fQ/AgS8uWIN4ipeCQ=";
    domain = "codeberg.org";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    foss-flame
    licomp
    licomp-doubleopen
    licomp-dwheeler
    licomp-gnuguide
    licomp-hermione
    licomp-osadl
    licomp-oslc-handbook
    licomp-proprietary
    licomp-reclicense
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "licomp_toolkit"
  ];

  meta = {
    description = "Python module and program to check compatibility between two licenses with context";
    homepage = "https://codeberg.org/software-compliance-org/licomp-toolkit";

    license = with lib.licenses; [
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    # TODO: remove when this is resolved:
    # https://github.com/hesa/licomp-oslc-handbook/issues/4
    badPlatforms = lib.platforms.darwin;
    mainProgram = "licomp-toolkit";
    teams = with lib.teams; [ ngi ];
  };
})
