{
  lib,
  fetchFromGitHub,
  melpaBuild,
}:

let
  version = "1.4";
in
melpaBuild {
  inherit version;
  pname = "rect-mark";

  src = fetchFromGitHub {
    owner = "emacsmirror";
    repo = "rect-mark";
    tag = version;
    hash = "sha256-/8T1VTYkKUxlNWXuuS54S5jpl4UxJBbgSuWc17a/VyM=";
  };

  meta = {
    description = "Mark a rectangle of text with highlighting";
    homepage = "http://emacswiki.org/emacs/RectangleMark";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
