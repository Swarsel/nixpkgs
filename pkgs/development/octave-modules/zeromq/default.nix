{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  buildOctavePackage,
  nix-update-script,
  pkg-config,
  zeromq,
}:

buildOctavePackage rec {
  pname = "zeromq";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "octave-zeromq";
    tag = "release-${version}";
    sha256 = "sha256-2n/Cc4E/qYeN5Ku+Lmg/UCJhiYNbXkFIY8s4/SP2J+Y=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  propagatedBuildInputs = [
    zeromq
  ];

  postAutoreconf = ''
    cd ..
  '';

  preAutoreconf = ''
    cd src
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "release-(.*)"
    ];
  };

  meta = {
    description = "ZeroMQ bindings for GNU Octave";
    homepage = "https://gnu-octave.github.io/packages/zeromq/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
