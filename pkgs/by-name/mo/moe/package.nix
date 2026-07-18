{
  lib,
  stdenv,
  fetchurl,
  lzip,
  ncurses,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "moe";
  version = "1.16";

  src = fetchurl {
    url = "mirror://gnu/moe/moe-${finalAttrs.version}.tar.lz";
    hash = "sha256-TCXNeJGScq6+wKf4wSYBG7Wktdh0IoB6NCMhbwoXqGg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    lzip
  ];

  buildInputs = [
    ncurses
  ];

  meta = {
    description = "Small, 8-bit clean editor";

    longDescription = ''
      GNU moe is a powerful, 8-bit clean, console text editor for ISO-8859 and
      ASCII character encodings. It has a modeless, user-friendly interface,
      online help, multiple windows, unlimited undo/redo capability, unlimited
      line length, unlimited buffers, global search/replace (on all buffers at
      once), block operations, automatic indentation, word wrapping, file name
      completion, directory browser, duplicate removal from prompt histories,
      delimiter matching, text conversion from/to UTF-8, romanization, etc.
    '';

    homepage = "https://www.gnu.org/software/moe/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ videl ];
    platforms = lib.platforms.unix;
    mainProgram = "moe";
  };
})
