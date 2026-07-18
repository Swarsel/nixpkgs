{
  lib,
  stdenv,
  fetchFromSourcehut,
  unstableGitUpdater,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "river-bnf";
  version = "0-unstable-2023-10-10";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = "river-bnf";
    rev = "bb8ded380ed5d539777533065b4fd33646ad5603";
    hash = "sha256-rm9Nt3WLgq9QOXzrkYBGp45EALNYFTQGInxfYIN0XcU=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace '/usr/local' $out
  '';

  nativeBuildInputs = [
    wayland-scanner
  ];

  buildInputs = [
    wayland.dev
  ];

  # Fix build with gcc 15
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Switch back'n'forth between river tags";
    homepage = "https://git.sr.ht/~leon_plickat/river-bnf";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ adamcstephens ];
    platforms = lib.platforms.linux;
    mainProgram = "river-bnf";
  };
}
