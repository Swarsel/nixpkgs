{
  lib,
  stdenv,
  alsa-lib,
  dbus,
  fetchFromGitea,
  gitUpdater,
  libjack2,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "a2jmidid";
  version = "12";

  src = fetchFromGitea {
    owner = "LADI";
    repo = "a2jmidid";
    tag = finalAttrs.version;
    hash = "sha256-PZKGhHmPMf0AucPruOLB9DniM5A3BKdghFCrd5pTzeM=";
    fetchSubmodules = true;
    domain = "gitea.ladish.org";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    alsa-lib
    dbus
    libjack2
  ]
  ++ (with python3Packages; [
    python
    dbus-python
  ]);

  postInstall = ''
    wrapProgram $out/bin/a2j_control --set PYTHONPATH $PYTHONPATH
    substituteInPlace $out/bin/a2j --replace-fail "a2j_control" "$out/bin/a2j_control"
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Daemon for exposing legacy ALSA sequencer applications in JACK MIDI system";
    homepage = "https://a2jmidid.ladish.org/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
