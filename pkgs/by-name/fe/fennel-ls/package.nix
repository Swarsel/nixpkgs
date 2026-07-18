{
  lib,
  stdenv,
  fetchFromSourcehut,
  lua,
  luaPackages,
  pandoc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fennel-ls";
  version = "0.2.3";

  src = fetchFromSourcehut {
    owner = "~xerool";
    repo = "fennel-ls";
    rev = finalAttrs.version;
    hash = "sha256-BU0SkdBjq8kicvACIo3N2gf1UvTmzA3FKSt39Lxp3rs=";
  };

  nativeBuildInputs = [ pandoc ];

  buildInputs = [
    lua
    luaPackages.fennel
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    inherit (lua.meta) platforms;
    description = "Language server for intelligent editing of the Fennel Programming Language";
    homepage = "https://git.sr.ht/~xerool/fennel-ls/";
    changelog = "https://git.sr.ht/~xerool/fennel-ls/refs/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      yisraeldov
    ];

    mainProgram = "fennel-ls";
  };
})
