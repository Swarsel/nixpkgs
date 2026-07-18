{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2,
  cmake,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cli11";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "CLIUtils";
    repo = "CLI11";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TcOmx/qUK/w3mO0bDHX+TRxxMwJpaDFQBcpkQj3hz8A=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2 ];
  doCheck = true;

  nativeCheckInputs = [
    boost
    python3
  ];

  meta = {
    description = "Command line parser for C++11";
    homepage = "https://github.com/CLIUtils/CLI11";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
