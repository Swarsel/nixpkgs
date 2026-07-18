{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  gettext,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yash";
  version = "2.61";

  src = fetchFromGitHub {
    owner = "magicant";
    repo = "yash";
    rev = finalAttrs.version;
    hash = "sha256-ih5BXzhG/DNeWghptXXTXVbZLT63AE8blWTzzfssqXU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    gettext
  ];

  buildInputs = [ ncurses ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ gettext ];
  passthru.shellPath = "/bin/yash";

  meta = {
    description = "Yet another POSIX-compliant shell";
    homepage = "https://yash.osdn.jp/index.html.en";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ qbit ];
    platforms = lib.platforms.all;
    mainProgram = "yash";
  };
})
