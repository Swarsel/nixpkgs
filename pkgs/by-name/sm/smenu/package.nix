{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smenu";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "p-gen";
    repo = "smenu";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-nTQe6sCMHGRW7Djpv33xY8nL4a7ZyC9YM7PGOvmpuSM=";
  };

  buildInputs = [ ncurses ];

  meta = {
    description = "Terminal selection utility";

    longDescription = ''
      Terminal utility that allows you to use words coming from the standard
      input to create a nice selection window just below the cursor. Once done,
      your selection will be sent to standard output.
    '';

    homepage = "https://github.com/p-gen/smenu";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "smenu";
  };
})
