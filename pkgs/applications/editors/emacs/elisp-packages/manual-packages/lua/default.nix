{
  lib,
  fetchFromGitHub,
  lua,
  melpaBuild,
  pkg-config,
  unstableGitUpdater,
}:

melpaBuild {
  pname = "lua";
  version = "0-unstable-2025-01-27";

  src = fetchFromGitHub {
    owner = "syohex";
    repo = "emacs-lua";
    rev = "501189b5fc069fcead8843b2b0ad510c08de1397";
    hash = "sha256-psCrto12p03R9XxPtDYTMB5vcRVWj+Blq7D30nLsSbU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ lua ];

  preBuild = ''
    make LUA_VERSION=${lua.luaversion} CC=$CC LD=$CC
  '';

  files = ''(:defaults "lua-core.so")'';
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Lua engine from Emacs Lisp";
    homepage = "https://github.com/syohex/emacs-lua";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
