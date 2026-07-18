{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  haskellPackages,
  makeWrapper,
  # dependencies
  slither-analyzer,
}:

haskellPackages.mkDerivation rec {
  pname = "echidna";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "echidna";
    tag = "v${version}";
    sha256 = "sha256-Zopkqc01uUccJzdjP+qmHHZzB2iXK0U0fQi6EhgCRKg=";
  };

  # tests depend on a specific version of solc
  doCheck = false;

  postInstall =
    with haskellPackages;
    # https://github.com/NixOS/nixpkgs/pull/304352
    lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
      remove-references-to -t ${warp.out} "$out/bin/echidna"
      remove-references-to -t ${wreq.out} "$out/bin/echidna"
    ''
    # make slither-analyzer a runtime dependency
    + ''
      wrapProgram $out/bin/echidna \
        --prefix PATH : ${lib.makeBinPath [ slither-analyzer ]}
    '';

  buildTools = with haskellPackages; [
    hpack
    makeWrapper
  ];

  description = "Ethereum smart contract fuzzer";
  doHaddock = false;

  executableHaskellDepends = with haskellPackages; [
    # package.yml/dependencies
    aeson
    base
    containers
    directory
    hevm
    MonadRandom
    mtl
    text
    # package.yml/library.dependencies
    ansi-terminal
    array
    base16-bytestring
    binary
    brick
    bytestring
    data-bword
    data-dword
    deepseq
    exceptions
    extra
    filepath
    Glob
    hashable
    html-conduit
    html-entities
    http-conduit
    ListLike
    mcp-server
    mustache
    optics
    optics-core
    process
    random
    rosezipper
    semver
    signal
    split
    stm
    strip-ansi-escape
    time
    unliftio
    unliftio-core
    utf8-string
    vector
    vty
    vty-crossplatform
    wai-extra
    warp
    wreq
    word-wrap
    xml-conduit
    yaml
    # package.yml/ecutable.echidna.dependencies
    code-page
    filepath
    hashable
    optparse-applicative
    time
    with-utf8
  ];

  homepage = "https://github.com/crytic/echidna";
  isExecutable = true;
  license = lib.licenses.agpl3Plus;
  mainProgram = "echidna";

  maintainers = with lib.maintainers; [
    arturcygan
    hellwolf
  ];

  platforms = lib.platforms.unix;

  prePatch = ''
    hpack
  '';
}
