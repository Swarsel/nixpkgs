{
  lib,
  fetchFromGitHub,
  ffmpeg-full,
  libnotify,
  makeWrapper,
  procps,
  slop,
  stdenvNoCC,
  xdotool,
}:

stdenvNoCC.mkDerivation rec {
  pname = "giph";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "phisch";
    repo = "giph";
    rev = version;
    sha256 = "19l46m1f32b3bagzrhaqsfnl5n3wbrmg3sdy6fdss4y1yf6nqayk";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/giph \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg-full
          xdotool
          libnotify
          slop
          procps
        ]
      }
  '';

  dontBuild = true;
  dontConfigure = true;
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Simple gif recorder";
    homepage = "https://github.com/phisch/giph";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "giph";
  };
}
