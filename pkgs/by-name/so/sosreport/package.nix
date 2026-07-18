{
  lib,
  fetchFromGitHub,
  gettext,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "sosreport";
  version = "4.11.2";

  src = fetchFromGitHub {
    owner = "sosreport";
    repo = "sos";
    tag = version;
    hash = "sha256-abMH0s+ZfLAURBJrZtTmDczuS5Id3ko0lTKfvp3OJqU=";
  };

  patches = [
    ./os-release.patch
  ];

  nativeBuildInputs = [
    gettext
  ];

  # requires avocado-framework 94.0, latest version as of writing is 96.0
  doCheck = false;

  preCheck = ''
    export PYTHONPATH=$PWD/tests:$PYTHONPATH
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    packaging
    pexpect
    python-magic
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "sos" ];

  meta = {
    description = "Unified tool for collecting system logs and other debug information";
    homepage = "https://github.com/sosreport/sos";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
