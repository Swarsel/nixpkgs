{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  makeWrapper,
  ncurses,
  rlwrap,
  unstableGitUpdater,
  xsel,
}:

stdenv.mkDerivation {
  pname = "cht.sh";
  version = "0-unstable-2025-12-23";

  src = fetchFromGitHub {
    owner = "chubin";
    repo = "cheat.sh";
    rev = "031a5d3887f035aaa3bf1a3f83dff4fde2aac53d";
    sha256 = "T6v58bmdA3EvC4QUgCR+FJLonN3QdHpkdvNGauq/i5Q=";
  };

  # Fix ".cht.sh-wrapped" in the help message
  postPatch = "substituteInPlace share/cht.sh.txt --replace '\${0##*/}' cht.sh";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -m755 -D share/cht.sh.txt "$out/bin/cht.sh"

    # install shell completion files
    mkdir -p $out/share/bash-completion/completions $out/share/zsh/site-functions
    mv share/bash_completion.txt $out/share/bash-completion/completions/cht.sh
    cp share/zsh.txt $out/share/zsh/site-functions/_cht

    wrapProgram "$out/bin/cht.sh" \
      --prefix PATH : "${
        lib.makeBinPath [
          curl
          rlwrap
          ncurses
          xsel
        ]
      }"
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/chubin/cheat.sh.git";
  };

  meta = {
    description = "CLI client for cheat.sh, a community driven cheat sheet";
    homepage = "https://github.com/chubin/cheat.sh";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fgaz
      evanjs
    ];

    mainProgram = "cht.sh";
  };
}
