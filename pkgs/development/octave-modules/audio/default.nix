{
  lib,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  buildOctavePackage,
  jack2,
  nix-update-script,
  pkg-config,
  rtmidi,
}:

buildOctavePackage rec {
  pname = "audio";
  version = "2.0.12";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "octave-audio";
    tag = "release-${version}";
    sha256 = "sha256-DO7tNnYIJME08u8Kxbgkq8D4ZT0dvxiqK2deJEWmCyU=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  propagatedBuildInputs = [
    jack2
    alsa-lib
    rtmidi
  ];

  postAutoreconf = ''
    popd
  '';

  # autoreconfHook provides an autoreconfPhase that is run as a
  # preconfigurePhase, which means it runs AFTER the source is un-tarred, and
  # before buildOctavePackage's buildPhase re-tars it up into a format for later
  # consumption by Octave's "pkg build" command.
  preAutoreconf = ''
    pushd src
    # Upstream's bootstrap script uses wget to fetch config.guess & config.sub
    # and has them committed to the repository. We must remove them so autoreconf
    # actually fires for our environment.
    rm config.*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=release-(.*)" ]; };

  meta = {
    description = "Audio and MIDI Toolbox for GNU Octave";
    homepage = "https://gnu-octave.github.io/packages/audio/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
    platforms = lib.platforms.linux; # Because of run-time dependency on jack2 and alsa-lib
  };
}
