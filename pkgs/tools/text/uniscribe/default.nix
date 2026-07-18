{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  makeWrapper,
}:

let
  rubyEnv = bundlerEnv {
    gemdir = ./.;
    name = "uniscribe";
  };
in
stdenv.mkDerivation {
  pname = "uniscribe";
  version = (import ./gemset.nix).uniscribe.version;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${rubyEnv}/bin/uniscribe $out/bin/uniscribe
  '';

  dontUnpack = true;
  passthru.updateScript = bundlerUpdateScript "uniscribe";

  meta = {
    description = "Explains Unicode characters/code points: Displays their name, category, and shows compositions";
    homepage = "https://github.com/janlelis/uniscribe";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kjeremy ];
    mainProgram = "uniscribe";
  };
}
