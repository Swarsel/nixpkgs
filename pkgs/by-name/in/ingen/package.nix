{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  ganv,
  gtkmm2,
  libjack2,
  lilv,
  meson,
  ninja,
  pkg-config,
  portaudio,
  python3,
  raul,
  sord,
  sratom,
  suil,
}:

stdenv.mkDerivation {
  pname = "ingen";
  version = "0-unstable-2024-07-13";

  src = fetchFromGitLab {
    owner = "drobilla";
    repo = "ingen";
    rev = "bbdab98ed282291b6e29a944359c360c9cca127e";
    hash = "sha256-BllWeVmEkHQaZD9Ba7H0JMRlxVROJ8pkIiC2VXYiweA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    boost
    ganv
    gtkmm2
    libjack2
    lilv
    portaudio
    raul
    sord
    sratom
    suil
  ];

  # lv2specgen.py is not packaged in lv2 but required to build docs
  mesonFlags = [ "-Ddocs=disabled" ];

  postInstall = ''
    wrapPythonProgramsIn "$out/bin" "$out ''${pythonPath[*]}"
    wrapProgram "$out/bin/ingen" --set INGEN_UI_PATH "$out/share/ingen/ingen_gui.ui"
  '';

  pythonPath = [
    python3
    python3.pkgs.rdflib
  ];

  meta = {
    description = "Modular audio processing system using JACK and LV2 or LADSPA plugins";
    homepage = "http://drobilla.net/software/ingen";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ t4ccer ];
    platforms = lib.platforms.linux;
  };
}
