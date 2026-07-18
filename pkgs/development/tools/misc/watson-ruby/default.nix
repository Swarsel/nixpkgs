{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:

stdenv.mkDerivation rec {
  pname = "watson-ruby";
  version = (import ./gemset.nix).watson-ruby.version;

  installPhase =
    let
      env = bundlerEnv {
        inherit ruby;
        # expects Gemfile, Gemfile.lock and gemset.nix in the same directory
        gemdir = ./.;
        name = "watson-ruby-gems-${version}";
      };
    in
    ''
      mkdir -p $out/bin
      ln -s ${env}/bin/watson $out/bin/watson
    '';

  dontUnpack = true;
  passthru.updateScript = bundlerUpdateScript "watson-ruby";

  meta = {
    description = "Inline issue manager";
    homepage = "https://goosecode.com/watson/";
    license = with lib.licenses; mit;

    maintainers = with lib.maintainers; [
      robertodr
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "watson";
  };
}
