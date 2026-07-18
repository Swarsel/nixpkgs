{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "xandikos";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "jelmer";
    repo = "xandikos";
    tag = "v${version}";
    hash = "sha256-nK+od6mJRj6I6qFhQmwwf6x+0kfC07VRVNKY6fkbNjc=";
  };

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  postInstall = ''
    installManPage man/xandikos{,-milter}.8
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aiohttp
    aiohttp-openmetrics
    aiosmtpd
    dulwich
    defusedxml
    icalendar
    jinja2
    multidict
    vobject
  ];

  pyproject = true;
  passthru.tests.xandikos = nixosTests.xandikos;

  meta = {
    description = "Lightweight CalDAV/CardDAV server";
    homepage = "https://github.com/jelmer/xandikos";
    changelog = "https://github.com/jelmer/xandikos/blob/v${version}/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    mainProgram = "xandikos";
  };
}
