{
  lib,
  lsp-bridge,
  melpaBuild,
  yasnippet,
}:

melpaBuild {
  pname = "acm";
  version = lsp-bridge.version;
  src = lsp-bridge.src;
  files = ''("acm/*.el" "acm/icons")'';
  packageRequires = [ yasnippet ];

  meta = {
    description = "Asynchronous Completion Menu";
    homepage = "https://github.com/manateelazycat/lsp-bridge";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fxttr
      kira-bruneau
    ];
  };
}
