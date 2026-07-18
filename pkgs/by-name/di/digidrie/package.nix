{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libjack2,
  libx11,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "digidrie";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "magnetophon";
    repo = "DigiDrie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bmytfZ6/V9eoEnj5xLq3Yzlhy0VGEK6utsfS9OCYWd0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs generate-ttl.sh patch/apply.sh
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libGL
    libx11
    libjack2
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  __structuredAttrs = true;
  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/plugin/dpf";

  meta = {
    description = "Monophonic Faust synth with vector synthesis, CZ-style oscillators and macro morphing (DPF: JACK/LV2/VST2/VST3/CLAP)";
    homepage = "https://github.com/magnetophon/DigiDrie";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.magnetophon ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "DigiDrie";
  };
})
