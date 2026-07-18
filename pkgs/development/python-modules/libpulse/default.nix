{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  flit-core,
  glibcLocales,
  libpulseaudio,
  pulseaudio,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "libpulse";
  version = "0.7";

  src = fetchFromGitLab {
    owner = "xdegaye";
    repo = "libpulse";
    tag = finalAttrs.version;
    hash = "sha256-JxWJaD/9WxvF/lajWWot10/urqGktr4JGGOJRNhbPjk=";
  };

  postPatch = ''
    substituteInPlace libpulse/libpulse_ctypes.py \
      --replace-fail "find_library('pulse')" "'${lib.getLib libpulseaudio}/lib/libpulse${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  nativeCheckInputs = [
    glibcLocales
    pulseaudio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  # using pulseaudio as it is easier to setup than pipewire
  preCheck = ''
    mkdir -p $HOME/.config/pulse/
    cp ${pulseaudio}/etc/pulse/* $HOME/.config/pulse/
    pulseaudio --verbose --daemonize=yes
  '';

  build-system = [ flit-core ];

  disabledTests = [
    # path to lib is patched and which breaks the mocking
    "test_missing_lib"
  ];

  pyproject = true;
  pythonImportsCheck = [ "libpulse" ];

  meta = {
    description = "Asyncio interface to the Pulseaudio and Pipewire pulse library";
    homepage = "https://gitlab.com/xdegaye/libpulse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.linux;
    mainProgram = "pactl-py";
  };
})
