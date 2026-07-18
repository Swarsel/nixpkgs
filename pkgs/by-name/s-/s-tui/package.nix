{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  s-tui,
  stress,
  testers,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "s-tui";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "amanusk";
    repo = "s-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PDDT37W0x7VJ6OnkbwvPXttphD+vHDul0zmA3VY/Sao=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = [
    python3Packages.urwid
    python3Packages.psutil
    stress
  ];

  pyproject = true;

  passthru = {
    tests = testers.testVersion { package = s-tui; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Stress-Terminal UI monitoring tool";
    homepage = "https://amanusk.github.io/s-tui/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ lilacious ];
    mainProgram = "s-tui";
    broken = stdenv.hostPlatform.isDarwin; # https://github.com/amanusk/s-tui/issues/49
  };
})
