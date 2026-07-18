{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sylkserver";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "sylkserver";
    tag = finalAttrs.version;
    hash = "sha256-FeoyQWM4dvO1FJ6q5uXczPCtX2Aocm+jIkAy88uvPFI=";
  };

  # no upstream tests exist
  nativeCheckInputs = [ versionCheckHook ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    autobahn
    cassandra-driver
    cement
    dnspython
    klein
    lxml
    lxml-html-clean
    msrplib
    python3-eventlib
    python3-gnutls
    python3-sipsimple
    systemd-python
    wokkel
    xcaplib
  ];

  pyproject = true;
  pythonImportsCheck = [ "sylk" ];
  versionCheckProgram = "${placeholder "out"}/bin/sylk-server";

  meta = {
    description = "SIP/XMPP/WebRTC Application Server";
    homepage = "https://sylkserver.com/";
    changelog = "https://github.com/AGProjects/sylkserver/blob/${finalAttrs.src.rev}/debian/changelog";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sylk-server";
    downloadPage = "https://github.com/AGProjects/sylkserver";
    teams = [ lib.teams.ngi ];
  };
})
