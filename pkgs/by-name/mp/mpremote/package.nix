{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mpremote";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "micropython";
    repo = "micropython";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hk/DHMb9U/mLLVRKe+K3u5snxzW5BW3+bYRPFEAmUBQ=";
  };

  nativeBuildInputs = with python3Packages; [
    hatchling
    hatch-requirements-txt
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    pyserial
    importlib-metadata
  ];

  pyproject = true;
  pythonImportsCheck = [ "mpremote" ];
  sourceRoot = "${finalAttrs.src.name}/tools/mpremote";

  meta = {
    description = "Integrated set of utilities to remotely interact with and automate a MicroPython device over a serial connection";
    homepage = "https://github.com/micropython/micropython/blob/master/tools/mpremote/README.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _999eagle ];
    platforms = lib.platforms.unix;
    mainProgram = "mpremote";
  };
})
