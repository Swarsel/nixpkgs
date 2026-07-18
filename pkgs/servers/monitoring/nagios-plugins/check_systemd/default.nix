{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "check-systemd";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "Josef-Friedrich";
    repo = "check_systemd";
    tag = "v${version}";
    hash = "sha256-i9lMF8SZwTxVCQaHQcEWqdKiOQ4ghcp5H/S+frfZXRw=";
  };

  postPatch = ''
    substituteInPlace tests/test_argparse.py \
      --replace-fail "./check_systemd.py" "check_systemd"
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  # needs to be able to run check_systemd from PATH
  preCheck = ''
    export PATH=$PATH:$out/bin
  '';

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    nagiosplugin
  ];

  pyproject = true;

  meta = {
    description = "Nagios / Icinga monitoring plugin to check systemd for failed units";
    homepage = "https://github.com/Josef-Friedrich/check_systemd";
    changelog = "https://github.com/Josef-Friedrich/check_systemd/releases";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ symphorien ];
    platforms = lib.platforms.linux;
    mainProgram = "check_systemd";
  };
}
