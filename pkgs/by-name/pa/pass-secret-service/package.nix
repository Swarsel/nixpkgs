{
  lib,
  fetchFromGitHub,
  coreutils,
  dbus,
  gnupg,
  nix-update-script,
  nixosTests,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "pass-secret-service";
  # PyPI has old alpha version. Since then the project has switched from using a
  # seemingly abandoned D-Bus package pydbus and started using maintained
  # dbus-next. So let's use latest from GitHub.
  version = "0-unstable-2023-12-16";

  src = fetchFromGitHub {
    owner = "mdellweg";
    repo = "pass_secret_service";
    rev = "6335c85d9a790a6472e3de6eff87a15208caa5dc";
    hash = "sha256-SSmI3HJCUWuwFXCu3Zg66X18POlzp3ADRj7HeE8GRio=";
  };

  # Need to specify session.conf file for tests because it won't be found under
  # /etc/ in check phase.
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "dbus-run-session" "dbus-run-session --config-file=${dbus}/share/dbus-1/session.conf" \
      --replace-fail '-p $(relpassstore)' '-p $(PASSWORD_STORE_DIR)'

    substituteInPlace systemd/org.freedesktop.secrets.service \
      --replace-fail "/bin/false" "${coreutils}/bin/false"
    substituteInPlace systemd/dbus-org.freedesktop.secrets.service \
      --replace-fail "/usr/local" "$out"
  '';

  nativeCheckInputs =
    let
      ps = python3.pkgs;
    in
    [
      dbus
      gnupg
      ps.pytest
      ps.pytest-asyncio
      ps.pypass
    ];

  postInstall = ''
    mkdir -p "$out/share/dbus-1/services/" "$out/lib/systemd/user/"
    cp systemd/org.freedesktop.secrets.service "$out/share/dbus-1/services/"
    cp systemd/dbus-org.freedesktop.secrets.service "$out/lib/systemd/user/"
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  checkTarget = "test";

  dependencies = with python3.pkgs; [
    click
    cryptography
    dbus-next
    decorator
    pypass
    secretstorage
  ];

  pyproject = true;
  pythonImportsCheck = [ "pass_secret_service" ];

  passthru = {
    tests.pass-secret-service = nixosTests.pass-secret-service;

    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "Libsecret D-Bus API with pass as the backend";
    homepage = "https://github.com/mdellweg/pass_secret_service/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jluttine ];
    platforms = lib.platforms.all;
    mainProgram = "pass_secret_service";
  };
}
