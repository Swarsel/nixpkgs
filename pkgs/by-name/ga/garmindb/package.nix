{
  lib,
  fetchFromGitHub,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "garmindb";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "tcgoetz";
    repo = "garmindb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iqZHm4C3MB4Qfkg8fBHu+fvt0tQ+2AyBziwrC5ZkcyU=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    sqlalchemy
    python-dateutil
    cached-property
    tqdm
    garminconnect
    fitfile
    tcxfile
    idbutils
    tornado
  ];

  # require data files
  disabledTestPaths = [
    "test/test_activities_db.py"
    "test/test_config.py"
    "test/test_copy.py"
    "test/test_db_base.py"
    "test/test_fit_file.py"
    "test/test_garmin_db.py"
    "test/test_garmin_db_objects.py"
    "test/test_garmin_summary_db.py"
    "test/test_monitoring_db.py"
    "test/test_profile_file.py"
    "test/test_summary_db.py"
    "test/test_summary_db_base.py"
    "test/test_tcx_file.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "garmindb" ];

  pythonRelaxDeps = [
    "sqlalchemy"
    "cached-property"
    "garminconnect"
    "tqdm"
    "fitfile"
    "tcxfile"
    "idbutils"
  ];

  meta = {
    description = "Download and parse data from Garmin Connect or a Garmin watch";
    homepage = "https://github.com/tcgoetz/GarminDB";
    changelog = "https://github.com/tcgoetz/GarminDB/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      ethancedwards8
      matthiasbeyer
    ];

    platforms = lib.platforms.unix;
    mainProgram = "garmindb";
  };
})
