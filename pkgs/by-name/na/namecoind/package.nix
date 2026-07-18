{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  darwin,
  db4,
  hexdump,
  libevent,
  miniupnpc,
  pkg-config,
  python3,
  sqlite,
  util-linux,
  zeromq,
  zlib,
  withWallet ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "namecoind";
  version = "28.0";

  src = fetchFromGitHub {
    owner = "namecoin";
    repo = "namecoin-core";
    tag = "nc${finalAttrs.version}";
    hash = "sha256-r6rVgPrKz7nZ07oXw7KmVhGF4jVn6L+R9YHded+3E9k=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ util-linux ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ hexdump ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.autoSignDarwinBinariesHook
  ];

  buildInputs = [
    boost
    libevent
    db4
    miniupnpc
    zeromq
    zlib
  ]
  ++ lib.optionals withWallet [ sqlite ]
  # building with db48 (for legacy descriptor wallet support) is broken on Darwin
  ++ lib.optionals (withWallet && !stdenv.hostPlatform.isDarwin) [ db4 ];

  configureFlags = [
    "--with-boost-libdir=${boost.out}/lib"
    "--disable-bench"
    "--disable-gui-tests"
  ]
  ++ lib.optionals (!withWallet) [
    "--disable-wallet"
  ];

  doCheck = true;
  nativeCheckInputs = [ python3 ];
  checkFlags = [ "LC_ALL=en_US.UTF-8" ];
  enableParallelBuilding = true;

  meta = {
    description = "Decentralized open source information registration and transfer system based on the Bitcoin cryptocurrency";
    homepage = "https://namecoin.org";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
