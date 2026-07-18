{
  lib,
  fetchurl,
  melpaBuild,
}:

melpaBuild {
  pname = "prolog-mode";
  version = "1.28";

  src = fetchurl {
    url = "https://bruda.ca/_media/emacs/prolog.el";
    hash = "sha256-ZzIDFQWPq1vI9z3btgsHgn0axN6uRQn9Tt8TnqGybOk=";
  };

  postPatch = ''
    substituteInPlace prolog.el \
      --replace-fail ";; prolog.el ---" ";;; prolog.el ---"
  '';

  ename = "prolog";

  meta = {
    description = "Prolog mode for Emacs";
    homepage = "https://bruda.ca/emacs/prolog_mode_for_emacs/";
    license = lib.licenses.gpl2Plus;
  };
}
