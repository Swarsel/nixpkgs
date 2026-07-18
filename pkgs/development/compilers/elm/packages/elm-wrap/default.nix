{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  hostname,
  python3,
  rsync,
  zip,
}:
stdenv.mkDerivation rec {
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "dsimunic";
    repo = "elm-wrap";
    tag = "v${version}";
    hash = "sha256-n7wX2jP4sX2LYiiFKOIyrEw5B4eJB9Bp2JD4qpp9Kmw=";
  };

  nativeBuildInputs = [
    hostname
    rsync
    zip
  ];

  buildInputs = [
    curl
  ];

  buildFlags = [ "RELEASE_VERSION=1" ];
  doCheck = true;

  nativeCheckInputs = [
    python3
  ];

  checkPhase = "make test";
  installFlags = [ "PREFIX=$(out)" ];
  name = "elm-wrap";

  meta = {
    description = "This utility is a comprehensive package management solution for Elm programming language packages and code. It wraps Elm compiler and intercepts its package management commands like install to augment them with support for custom package registries and policies.";
    homepage = "https://elm-wrap.dev/";
    changelog = "https://github.com/dsimunic/elm-wrap/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ turbomack ];
    mainProgram = "wrap";
  };
}
