{
  lib,
  fetchFromGitHub,
  dbus,
  python3,
  scli,
  signal-cli,
  testers,
  xclip,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "scli";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "isamert";
    repo = "scli";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-pp3uVABsncXXL2PZvTymHPKGAFvB24tnX+3K+C0VW8g=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pyqrcode
    urwid
    urwid-readline
  ];

  installPhase = ''
    runHook preInstall

    patchShebangs scli
    install -Dm555 scli -t $out/bin
    echo "v$version" > $out/bin/VERSION

    runHook postInstall
  '';

  dontBuild = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      dbus
      signal-cli
      xclip
    ])
  ];

  pyproject = false;

  passthru.tests = {
    version = testers.testVersion {
      command = "HOME=$(mktemp -d) scli --version";
      package = scli;
    };
  };

  meta = {
    description = "Simple terminal user interface for Signal";
    homepage = "https://github.com/isamert/scli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "scli";
  };
})
