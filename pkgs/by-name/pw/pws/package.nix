{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  makeWrapper,
  ruby,
  xsel,
}:

stdenv.mkDerivation rec {
  pname = "pws";
  version = (import ./gemset.nix).pws.version;
  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      env = bundlerEnv {
        inherit ruby;
        gemdir = ./.;
        name = "${pname}-gems";
      };
    in
    ''
      mkdir -p $out/bin
      makeWrapper ${env}/bin/pws $out/bin/pws \
        --set PATH '"${xsel}/bin/:$PATH"'
    '';

  dontUnpack = true;
  passthru.updateScript = bundlerUpdateScript "pws";

  meta = {
    description = "Command-line password safe";
    homepage = "https://github.com/janlelis/pws";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      swistak35
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pws";
  };
}
