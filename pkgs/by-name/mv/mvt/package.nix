{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mvt";
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "mvt-project";
    repo = "mvt";
    tag = "v${version}";
    hash = "sha256-xDUjyvOsiweRqibTe7V8I/ABeaahCoR/d5w23qixp9A";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest-mock
    stix2
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    adb-shell
    appdirs
    click
    cryptography
    libusb1
    iosbackup
    packaging
    pyahocorasick
    pyyaml
    requests
    rich
    simplejson
    tld
  ];

  pyproject = true;

  meta = {
    description = "Tool to facilitate the consensual forensic analysis of Android and iOS devices";
    homepage = "https://docs.mvt.re/en/latest/";
    changelog = "https://github.com/mvt-project/mvt/releases/tag/v${version}";
    # https://github.com/mvt-project/mvt/blob/main/LICENSE
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ PapayaJackal ];
  };
}
