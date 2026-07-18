{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:

bundlerEnv rec {
  inherit ruby;
  pname = "html-proofer";
  version = (import ./gemset.nix).html-proofer.version;
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript pname;

  meta = {
    description = "Tool to validate HTML files";
    homepage = "https://github.com/gjtorikian/html-proofer";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "htmlproofer";
  };
}
