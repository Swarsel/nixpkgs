{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cctools,
  python3,
  unbound,
}:

buildNpmPackage rec {
  pname = "hsd";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "handshake-org";
    repo = "hsd";
    rev = "v${version}";
    hash = "sha256-7hF8cJf9Oewfg5WvNpqQSrBZjpnERcdDAaxixOdArpo=";
  };

  nativeBuildInputs = [
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
  ];

  buildInputs = [
    unbound
  ];

  npmDepsHash = "sha256-fO8ia0FwNvMMVBUO22gUNImkXY3kjdUjQIP7s5MOJDs=";
  dontNpmBuild = true;

  meta = {
    description = "Implementation of the Handshake protocol";
    homepage = "https://github.com/handshake-org/hsd";
    changelog = "https://github.com/handshake-org/hsd/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
  };
}
