{
  lib,
  fetchFromGitHub,
  python3Packages,
  stig,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "stig";
  # This project has a different concept for pre release / alpha,
  # Read the project's README for details: https://github.com/rndusr/stig#stig
  version = "0.14.2a0";

  src = fetchFromGitHub {
    owner = "rndusr";
    repo = "stig";
    rev = "v${finalAttrs.version}";
    hash = "sha256-g37be8EiuQGnGC6uKNadtG9Z78f+NutHHpAwzGcsmD8=";
  };

  # According to the upstream author,
  # stig no longer has working tests
  # since asynctest (former test dependency) got abandoned.
  # See https://github.com/rndusr/stig/issues/206#issuecomment-2669636320
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    urwid
    urwidtrees
    aiohttp
    async-timeout
    pyxdg
    blinker
    natsort
    setproctitle
  ];

  pyproject = true;

  pythonRelaxDeps = [
    # relax urwidtrees==1.0.3
    "urwidtrees"
  ];

  passthru.tests = testers.testVersion {
    version = "stig version ${finalAttrs.version}";
    command = "stig -v";
    package = stig;
  };

  meta = {
    description = "TUI and CLI for the BitTorrent client Transmission";
    homepage = "https://github.com/rndusr/stig";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
})
