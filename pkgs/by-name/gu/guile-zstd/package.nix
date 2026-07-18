{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitea,
  guile,
  pkg-config,
  texinfo,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-zstd";
  version = "0.1.1";

  src = fetchFromGitea {
    owner = "guile-zstd";
    repo = "guile-zstd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IAyDoqb7qHAy666hxs6CCZrFnfwwV8AaR92XlQQ6FLE=";
    domain = "notabug.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
  ];

  buildInputs = [ guile ];
  propagatedBuildInputs = [ zstd ];
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  doCheck = !stdenv.hostPlatform.isDarwin;

  meta = {
    description = "GNU Guile library providing bindings to zstd";
    homepage = "https://notabug.org/guile-zstd/guile-zstd";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = guile.meta.platforms;
  };
})
