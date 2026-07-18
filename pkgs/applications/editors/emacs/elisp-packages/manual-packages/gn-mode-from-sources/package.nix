{
  lib,
  gn,
  melpaBuild,
}:

melpaBuild {
  inherit (gn) src;
  pname = "gn-mode-from-sources";
  version = "0-unstable-${gn.version}";

  # Fixes the malformed header error
  postPatch = ''
    substituteInPlace misc/emacs/gn-mode.el \
      --replace-fail ";;; gn-mode.el - " ";;; gn-mode.el --- "
  '';

  ename = "gn-mode";
  files = ''("misc/emacs/gn-mode.el")'';

  meta = {
    inherit (gn.meta) homepage license;
    description = "Major mode for editing GN files; taken from GN sources";
    maintainers = with lib.maintainers; [ rennsax ];
  };
}
