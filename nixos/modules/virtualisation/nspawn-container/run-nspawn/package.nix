{
  lib,
  buildPythonApplication,
  e2fsprogs,
  iproute2,
  ruff,
  setuptools,
  systemd,
  ty,
}:

buildPythonApplication {
  build-system = [
    setuptools
  ];

  checkPhase = ''
    echo -e "\x1b[32m## run ty\x1b[0m"
    ty check --error-on-warning run_nspawn
    echo -e "\x1b[32m## run ruff check\x1b[0m"
    ruff check .
    echo -e "\x1b[32m## run ruff format\x1b[0m"
    ruff format --check --diff .
  '';

  doCheck = true;

  nativeCheckInputs = [
    ruff
    ty
  ];

  pname = "run-nspawn";

  postPatch = ''
    substituteInPlace run_nspawn/__init__.py \
      --replace-fail "@ip@" "${lib.getExe' iproute2 "ip"}" \
      --replace-fail "@systemd-nspawn@" "${lib.getExe' systemd "systemd-nspawn"}" \
      --replace-fail "@chattr@" "${lib.getExe' e2fsprogs "chattr"}"
  '';

  propagatedBuildInputs = [
    systemd
    iproute2
  ];

  pyproject = true;
  src = ./src;
  version = "1.0";

  meta = {
    mainProgram = "run-nspawn";
  };
}
