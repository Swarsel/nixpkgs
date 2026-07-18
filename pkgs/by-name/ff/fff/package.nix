{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  coreutils,
  file,
  makeWrapper,
  w3m,
  xdg-utils,
  xdotool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fff";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "fff";
    rev = finalAttrs.version;
    sha256 = "14ymdw6l6phnil0xf1frd5kgznaiwppcic0v4hb61s1zpf4wrshg";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bashInteractive ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram "$out/bin/fff" --prefix PATH : $pathAdd
  '';

  dontBuild = true;

  pathAdd = lib.makeSearchPath "bin" [
    xdg-utils
    file
    coreutils
    w3m
    xdotool
  ];

  meta = {
    description = "Fucking Fast File-Manager";
    homepage = "https://github.com/dylanaraps/fff";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "fff";
  };
})
