{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "evdevremapkeys";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "philipl";
    repo = "evdevremapkeys";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gtml52tHNtg/3Fy+QO9eIh90nim0p0Fs+oEyqJvsZKs=";
  };

  env.SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    pyyaml
    pyxdg
    evdev
    pyudev
  ];

  pyproject = true;
  pythonImportsCheck = [ "evdevremapkeys" ];

  meta = {
    description = "Daemon to remap events on linux input devices";
    homepage = "https://github.com/philipl/evdevremapkeys";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.q3k ];
    platforms = lib.platforms.linux;
    mainProgram = "evdevremapkeys";
  };
})
