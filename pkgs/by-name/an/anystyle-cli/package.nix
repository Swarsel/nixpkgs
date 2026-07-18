{
  lib,
  buildRubyGem,
  bundlerEnv,
  poppler-utils,
  ruby,
}:
let
  deps = bundlerEnv rec {
    inherit ruby;
    version = "1.5.0";
    gemdir = ./.;

    gemset = lib.recursiveUpdate (import ./gemset.nix) {
      anystyle.source = {
        remotes = [ "https://rubygems.org" ];
        sha256 = "C/OrU7guHzHdY80upEXRfhWmUYDxpI54NIvIjKv0znw=";
        type = "gem";
      };
    };

    name = "anystyle-cli-${version}";
    source.sha256 = lib.fakeSha256;
  };
in
buildRubyGem rec {
  inherit ruby;
  pname = gemName;
  version = "1.5.0";
  propagatedBuildInputs = [ deps ];

  preFixup = ''
    wrapProgram $out/bin/anystyle --prefix PATH : ${poppler-utils}/bin
  '';

  gemName = "anystyle-cli";
  source.sha256 = "Bkk00PBk/6noCXgAbr1XUcdBq5vpdeL0ES02eeNA594=";

  meta = {
    description = "Command line interface to the AnyStyle Parser and Finder";
    homepage = "https://anystyle.io/";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      aschleck
    ];

    platforms = lib.platforms.unix;
    mainProgram = "anystyle";
  };
}
