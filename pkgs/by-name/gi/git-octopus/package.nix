{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  makeWrapper,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-octopus";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "lesfurets";
    repo = "git-octopus";
    rev = "v${finalAttrs.version}";
    sha256 = "14p61xk7jankp6gc26xciag9fnvm7r9vcbhclcy23f4ghf4q4sj1";
  };

  nativeBuildInputs = [ makeWrapper ];

  # perl provides shasum
  postInstall = ''
    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${
        lib.makeBinPath [
          git
          perl
        ]
      }
    done
  '';

  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Continuous merge workflow";
    homepage = "https://github.com/lesfurets/git-octopus";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.mic92 ];
    platforms = lib.platforms.unix;
  };
})
