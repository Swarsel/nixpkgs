{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  makeWrapper,
  papertrail,
  ruby,
  testers,
}:
stdenv.mkDerivation rec {
  pname = "papertrail";
  version = (import ./gemset.nix).papertrail.version;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ gems ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${gems}/bin/papertrail $out/bin/papertrail
  '';

  dontUnpack = true;

  gems = bundlerEnv {
    gemfile = ./Gemfile;
    gemset = ./gemset.nix;
    lockfile = ./Gemfile.lock;
    name = "papertrail";
  };

  passthru.updateScript = bundlerUpdateScript "papertrail";

  meta = {
    description = "Command-line client for Papertrail log management service";
    homepage = "https://github.com/papertrail/papertrail-cli/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nicknovitski ];
    platforms = ruby.meta.platforms;
    mainProgram = "papertrail";
  };
}
