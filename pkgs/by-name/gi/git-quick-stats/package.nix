{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gawk,
  git,
  gnugrep,
  makeWrapper,
  ncurses,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-quick-stats";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "git-quick-stats";
    repo = "git-quick-stats";
    rev = finalAttrs.version;
    sha256 = "sha256-YVvlrlNRDDci7fH9LW4NxZcIkakVgvKe9FhJ2gCfoXg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall =
    let
      path = lib.makeBinPath [
        coreutils
        gawk
        git
        gnugrep
        ncurses
        util-linux
      ];
    in
    ''
      wrapProgram $out/bin/git-quick-stats --suffix PATH : ${path}
    '';

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Simple and efficient way to access various statistics in git repository";
    homepage = "https://github.com/git-quick-stats/git-quick-stats";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kmein ];
    platforms = lib.platforms.all;
    mainProgram = "git-quick-stats";
  };
})
