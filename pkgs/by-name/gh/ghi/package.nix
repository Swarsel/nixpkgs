{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  makeWrapper,
}:
let
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "drazisil";
    repo = "ghi";
    tag = version;
    hash = "sha256-3V1lxI4VhP0jC3VSWyNS327gOCKowbbLB6ae1idpFFI=";
  };

  rubyEnv = bundlerEnv {
    gemfile = "${src}/Gemfile";
    gemset = ./gemset.nix;
    lockfile = "${src}/Gemfile.lock";
    name = "ghi";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "ghi";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ rubyEnv.wrappedRuby ];

  installPhase = ''
    mkdir -p $out/bin

    cp ghi $out/bin
  '';

  meta = {
    description = "GitHub Issues on the command line";
    homepage = "https://github.com/drazisil/ghi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "ghi";
  };
})
