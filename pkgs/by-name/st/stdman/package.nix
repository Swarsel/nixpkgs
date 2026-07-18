{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stdman";
  version = "2024.07.05";

  src = fetchFromGitHub {
    owner = "jeaye";
    repo = "stdman";
    rev = finalAttrs.version;
    sha256 = "sha256-/yJqKwJHonnBkP6/yQQJT3yPyYO6/nFAf4XFrgl3L0A=";
  };

  buildInputs = [ curl ];

  preConfigure = "
    patchShebangs ./do_install
  ";

  outputDevdoc = "out";

  meta = {
    description = "Formatted C++17 stdlib man pages (cppreference)";

    longDescription = "stdman is a tool that parses archived HTML
      files from cppreference and generates groff-formatted manual
      pages for Unix-based systems. The goal is to provide excellent
      formatting for easy readability.";

    homepage = "https://github.com/jeaye/stdman";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.twey ];
    platforms = lib.platforms.unix;
  };
})
