{
  lib,
  stdenv,
  fetchFromGitHub,
  xsel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yank";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "mptre";
    repo = "yank";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-sZiZki2Zl0Tfmls5KrLGxT94Bdf9TA9EwoaLoFOX9B4=";
  };

  makeFlags = [ "YANKCMD=${xsel}/bin/xsel" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Yank terminal output to clipboard";

    longDescription = ''
      Read input from stdin and display a selection interface that allows a
      field to be selected and copied to the clipboard. Fields are determined
      by splitting the input on a delimiter sequence, optionally specified
      using the -d option. New line, carriage return and tab characters are
      always treated as delimiters.
    '';

    homepage = "https://github.com/mptre/yank";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dochang ];
    platforms = lib.platforms.unix;
    mainProgram = "yank";
    downloadPage = "https://github.com/mptre/yank/releases";
  };

})
