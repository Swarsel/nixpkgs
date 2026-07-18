{
  lib,
  cl-lib,
  flycheck,
  melpaBuild,
  urweb,
}:

melpaBuild {
  inherit (urweb) src version;
  pname = "urweb-mode";
  dontConfigure = true;
  files = ''("src/elisp/*.el")'';

  packageRequires = [
    cl-lib
    flycheck
  ];

  meta = {
    inherit (urweb.meta) license homepage;
    description = "Major mode for editing Ur/Web";
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
