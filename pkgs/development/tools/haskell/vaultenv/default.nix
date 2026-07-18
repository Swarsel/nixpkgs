{
  lib,
  fetchFromGitHub,
  HsOpenSSL,
  QuickCheck,
  aeson,
  async,
  base,
  bytestring,
  containers,
  crypton-connection,
  directory,
  dotenv,
  hpack,
  hspec,
  hspec-discover,
  hspec-expectations,
  http-client,
  http-client-openssl,
  http-conduit,
  megaparsec,
  mkDerivation,
  network-uri,
  optparse-applicative,
  parser-combinators,
  quickcheck-instances,
  retry,
  text,
  unix,
  unordered-containers,
  utf8-string,
}:
mkDerivation rec {
  pname = "vaultenv";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "channable";
    repo = "vaultenv";
    rev = "v${version}";
    hash = "sha256-x3c9TKrCF3tsEFofYAXfK6DWdirEUxWWTttNqU/sJSc=";
  };

  buildTools = [ hpack ];
  description = "Runs processes with secrets from HashiCorp Vault";

  executableHaskellDepends = [
    HsOpenSSL
    aeson
    async
    base
    bytestring
    containers
    crypton-connection
    directory
    dotenv
    http-client
    http-client-openssl
    http-conduit
    megaparsec
    network-uri
    optparse-applicative
    optparse-applicative
    parser-combinators
    retry
    text
    unix
    unordered-containers
    utf8-string
  ];

  homepage = "https://github.com/channable/vaultenv#readme";
  isExecutable = true;
  isLibrary = false;
  license = lib.licenses.bsd3;

  maintainers = [
  ];

  prePatch = ''
    substituteInPlace package.yaml \
        --replace -Werror ""
    hpack
  '';

  testHaskellDepends = executableHaskellDepends ++ [
    QuickCheck
    directory
    hspec
    hspec-discover
    hspec-expectations
    quickcheck-instances
  ];
}
