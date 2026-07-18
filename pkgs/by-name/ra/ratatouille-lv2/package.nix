{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libjack2,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ratatouille-lv2";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "Ratatouille.lv2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mig3yUGSNz1xuyz6ljKqJUjNqmEcsbXSH1vTxTGdOFk=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace Ratatouille/makefile \
      --replace-fail "-flto=auto" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    xorgproto
    cairo
    lv2
    libsndfile
    libjack2
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "INSTALL_DIR=$(out)/lib/lv2"
    "EXE_INSTALL_DIR=$(out)/bin"
    "CLAP_INSTAL_DIR=$(out)/lib/clap"
    "VST2_INSTAL_DIR=$(out)/lib/vst"
    "user=root"
    "STRIP=:"
  ];

  __structuredAttrs = true;

  meta = {
    description = "Neural Amp Modeler LV2 plugin";
    homepage = "https://github.com/brummer10/Ratatouille.lv2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eymeric ];
    platforms = lib.platforms.linux;
    mainProgram = "Ratatouille";
  };
})
