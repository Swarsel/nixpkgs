{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  ncurses,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "curses";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "mbacarella";
    repo = "curses";
    rev = finalAttrs.version;
    hash = "sha256-tjBOv7RARDzBShToNLL9LEaU/Syo95MfwZunFsyN4/Q=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ ncurses ];
  minimalOCamlVersion = "4.06";

  meta = {
    description = "OCaml Bindings to curses/ncurses";
    homepage = "https://github.com/mbacarella/curses";
    changelog = "https://github.com/mbacarella/curses/raw/${finalAttrs.version}/CHANGES";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
