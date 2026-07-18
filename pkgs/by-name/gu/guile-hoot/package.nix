{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromCodeberg,
  guile,
  guile-fibers,
  guile-gnutls,
  guile-websocket,
  makeWrapper,
  nix-update-script,
  nodejs,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-hoot";
  version = "0.9.0";

  src = fetchFromCodeberg {
    owner = "spritely";
    repo = "hoot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZzWGdLKiJF9lBKrlX7jCKnPlmWRi1dDB4zrfkIOMpQU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    autoreconfHook
    guile
    pkg-config
    texinfo
    nodejs
  ];

  buildInputs = [
    guile
  ];

  propagatedBuildInputs = [
    guile-fibers
    guile-websocket
    guile-gnutls
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  postInstall =
    let
      libs = [ "$out" ] ++ finalAttrs.propagatedBuildInputs;
    in
    ''
      cp ./repl/repl.js $out/share/guile-hoot/${finalAttrs.version}/repl/repl.js
      wrapProgram $out/bin/hoot \
        --prefix GUILE_LOAD_PATH : ${lib.makeSearchPath guile.siteDir libs} \
        --prefix GUILE_LOAD_COMPILED_PATH : ${lib.makeSearchPath guile.siteCcacheDir libs}
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scheme to WebAssembly compiler backend for GNU Guile and a general purpose WASM toolchain";
    homepage = "https://codeberg.org/spritely/hoot";

    license = with lib.licenses; [
      asl20
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ jinser ];
    platforms = lib.platforms.unix;
    mainProgram = "hoot";
  };
})
