{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bqn";
  version = "0-unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "BQN";
    rev = "df1d848328194249e68635f8b8c04641d9fa6bdc";
    hash = "sha256-2S675ru67bcSSXGLEWfPkyW+U+cHzKs/HbM8ZSWMcEs=";
  };

  patches = [
    # Creates a @libbqn@ substitution variable, to be filled in postFixup
    ./001-libbqn-path.patch
  ];

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/bqn
    cp bqn.js $out/share/bqn/bqn.js
    cp docs/bqn.js $out/share/bqn/libbqn.js

    makeWrapper "${lib.getBin nodejs}/bin/node" "$out/bin/mbqn" \
      --add-flags "$out/share/bqn/bqn.js"

    ln -s $out/bin/mbqn $out/bin/bqn

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/bqn/bqn.js \
      --subst-var-by "libbqn" "$out/share/bqn/libbqn.js"
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    inherit (nodejs.meta) platforms;
    description = "Original BQN implementation in Javascript";
    homepage = "https://github.com/mlochbaum/BQN/";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
})
# TODO: install docs and other stuff
