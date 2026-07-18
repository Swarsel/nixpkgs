{
  lib,
  fetchFromGitHub,
  audioop-lts,
  buildPythonPackage,
  libpulseaudio,
  lxmf,
  numpy,
  pycodec2,
  rns,
  setuptools,
  soundcard,
}:

buildPythonPackage (finalAttrs: {
  pname = "lxst";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "lxst";
    tag = finalAttrs.version;
    hash = "sha256-MAJ1n6EUZ6FmIfKKuM2ppbTVrWkxpjC5KIICo5stc+k=";
  };

  postPatch = ''
    substituteInPlace LXST/Platforms/linux/soundcard.py \
      --replace-fail "libpulse.so" "${lib.getLib libpulseaudio}/lib/libpulse.so"
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    audioop-lts
    pycodec2
    numpy
    rns
    lxmf
    soundcard
  ];

  pyproject = true;

  meta = {
    description = "Simple and flexible real-time streaming format and delivery protocol for Reticulum";
    homepage = "https://github.com/markqvist/LXST";
    changelog = "https://github.com/markqvist/LXST/releases/tag/${finalAttrs.version}";
    license = lib.licenses.cc-by-nc-nd-40;

    maintainers = with lib.maintainers; [
      drupol
    ];

    mainProgram = "rnphone";
  };
})
