{
  lib,
  stdenv,
  fetchFromGitHub,
  imagemagick,
  makeWrapper,
  xwd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ttygif";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "icholy";
    repo = "ttygif";
    rev = finalAttrs.version;
    sha256 = "sha256-GsMeVR2wNivQguZ6B/0v39Td9VGHg+m3RtAG9DYkNmU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=${placeholder "out"}"
  ];

  postInstall = ''
    wrapProgram $out/bin/ttygif \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          xwd
        ]
      }
  '';

  meta = {
    description = "Convert terminal recordings to animated gifs";
    homepage = "https://github.com/icholy/ttygif";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moaxcp ];
    platforms = lib.platforms.unix;
    mainProgram = "ttygif";
  };
})
