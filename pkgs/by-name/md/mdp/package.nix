{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mdp";
  version = "1.0.18";

  src = fetchFromGitHub {
    owner = "visit1985";
    repo = "mdp";
    rev = finalAttrs.version;
    sha256 = "sha256-7ltqnvNzdr+sJiiiCQpp25dzhOrcUCOAgMTt1RIgVTw=";
  };

  buildInputs = [ ncurses ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Command-line based markdown presentation tool";
    homepage = "https://github.com/visit1985/mdp";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = with lib.platforms; unix;
    mainProgram = "mdp";
  };
})
