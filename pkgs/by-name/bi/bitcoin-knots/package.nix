{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  boost,
  cmake,
  darwin,
  db48,
  gnupg,
  imagemagick,
  installShellFiles,
  libevent,
  libicns,
  librsvg,
  libsodium,
  libsystemtap,
  pkg-config,
  python3,
  qrencode,
  qt5,
  sqlite,
  versionCheckHook,
  zeromq,
  zlib,
  # Signatures from the following GPG public keys checked during verification of the source code.
  # The list can be found at https://github.com/bitcoinknots/guix.sigs/tree/knots/builder-keys
  builderKeys ? [
    "1A3E761F19D2CC7785C5502EA291A2C45D0C504A" # luke-jr.gpg
    "DAED928C727D3E613EC46635F5073C4F4882FFFC" # leo-haf.gpg
  ],
  enableTracing ? stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isStatic,
  withGui ? true,
  withWallet ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = if withGui then "bitcoin-knots" else "bitcoind-knots";
  version = "29.3.knots20260508";

  src = fetchurl {
    url = "https://bitcoinknots.org/files/29.x/${finalAttrs.version}/bitcoin-${finalAttrs.version}.tar.gz";
    # hash retrieved from signed SHA256SUMS
    hash = "sha256-jjrr2sqzL29rZdkMmKGIlSVToSpXfgtY0TUlv9Wd1jA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
    gnupg
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.autoSignDarwinBinariesHook
  ]
  ++ lib.optionals withGui [
    imagemagick # for convert
    librsvg # for rsvg-convert
    qt5.wrapQtAppsHook
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && withGui) [
    libicns # for png2icns
  ];

  buildInputs = [
    boost
    libevent
    libsodium
    zeromq
    zlib
  ]
  ++ lib.optionals enableTracing [ libsystemtap ]
  ++ lib.optionals withWallet [ sqlite ]
  # building with db48 (for legacy descriptor wallet support) is broken on Darwin
  ++ lib.optionals (withWallet && !stdenv.hostPlatform.isDarwin) [ db48 ]
  ++ lib.optionals withGui [
    qrencode
    qt5.qtbase
    qt5.qttools
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_BENCH" false)
    (lib.cmakeBool "WITH_ZMQ" true)
    # building with db48 (for legacy wallet support) is broken on Darwin
    (lib.cmakeBool "WITH_BDB" (withWallet && !stdenv.hostPlatform.isDarwin))
    (lib.cmakeBool "WITH_USDT" enableTracing)
    (lib.cmakeFeature "RDTS_CONSENT" "RUNTIME_WARN")
  ]
  ++ lib.optionals (!finalAttrs.doCheck) [
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "BUILD_FUZZ_BINARY" false)
    (lib.cmakeBool "BUILD_GUI_TESTS" false)
  ]
  ++ lib.optionals (!withWallet) [
    (lib.cmakeBool "ENABLE_WALLET" false)
  ]
  ++ lib.optionals withGui [
    (lib.cmakeBool "BUILD_GUI" true)
  ];

  env = lib.optionalAttrs (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isStatic) {
    NIX_LDFLAGS = "-levent_core";
  };

  doCheck = true;
  nativeCheckInputs = [ python3 ];

  checkFlags = [
    "LC_ALL=en_US.UTF-8"
  ]
  # QT_PLUGIN_PATH needs to be set when executing QT, which is needed when testing Bitcoin's GUI.
  # See also https://github.com/NixOS/nixpkgs/issues/24256
  ++ lib.optional withGui "QT_PLUGIN_PATH=${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}";

  postInstall = ''
    cd ..
    installShellCompletion --bash contrib/completions/bash/bitcoin-cli.bash
    installShellCompletion --bash contrib/completions/bash/bitcoind.bash
    installShellCompletion --bash contrib/completions/bash/bitcoin-tx.bash

    installShellCompletion --fish contrib/completions/fish/bitcoin-cli.fish
    installShellCompletion --fish contrib/completions/fish/bitcoind.fish
    installShellCompletion --fish contrib/completions/fish/bitcoin-tx.fish
    installShellCompletion --fish contrib/completions/fish/bitcoin-util.fish
    installShellCompletion --fish contrib/completions/fish/bitcoin-wallet.fish
  ''
  + lib.optionalString withGui ''
    installShellCompletion --fish contrib/completions/fish/bitcoin-qt.fish
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;

  preUnpack =
    let
      majorVersion = lib.versions.major finalAttrs.version;

      publicKeys = fetchFromGitHub {
        owner = "bitcoinknots";
        repo = "guix.sigs";
        rev = "15113e2fe61b31354a6bcc3fddd17f759ce20c4a";
        sha256 = "sha256-snbs2j88k9CBdv8+s3GaFoIXyJRVWlKoxiKA8R6ek9Y=";
      };

      checksums = fetchurl {
        hash = "sha256-vFfeObwXowk143DSv9WZ++u+KA0fuHexFU1NizrCiV4=";
        url = "https://bitcoinknots.org/files/${majorVersion}.x/${finalAttrs.version}/SHA256SUMS";
      };

      signatures = fetchurl {
        hash = "sha256-8pVhrITphjs7rnJZrmxAU92GVgkjVPlkA54ne9iwiIs=";
        url = "https://bitcoinknots.org/files/${majorVersion}.x/${finalAttrs.version}/SHA256SUMS.asc";
      };

      verifyBuilderKeys =
        let
          script = publicKey: ''
            echo "Checking if public key ${publicKey} signed the checksum file..."
            grep "^\[GNUPG:\] VALIDSIG .* ${publicKey}$" verify.log > /dev/null
            echo "OK"
          '';
        in
        builtins.concatStringsSep "\n" (map script builderKeys);
    in
    ''
      pushd $(mktemp -d)
      export GNUPGHOME=$PWD/gnupg
      mkdir -m 700 -p $GNUPGHOME
      gpg --no-autostart --batch --import ${publicKeys}/builder-keys/*
      ln -s ${checksums} ./SHA256SUMS
      ln -s ${signatures} ./SHA256SUMS.asc
      ln -s $src ./bitcoin-${finalAttrs.version}.tar.gz
      gpg --no-autostart --batch --verify --status-fd 1 SHA256SUMS.asc SHA256SUMS > verify.log
      ${verifyBuilderKeys}
      echo "Checking ${checksums} for bitcoin-${finalAttrs.version}.tar.gz..."
      grep bitcoin-${finalAttrs.version}.tar.gz SHA256SUMS > SHA256SUMS.filtered
      echo "Verifying the checksum of bitcoin-${finalAttrs.version}.tar.gz..."
      sha256sum -c SHA256SUMS.filtered
      popd
    '';

  versionCheckProgram = "${placeholder "out"}/bin/bitcoin-cli";

  meta = {
    description = "Derivative of Bitcoin Core";
    homepage = "https://bitcoinknots.org/";
    changelog = "https://github.com/bitcoinknots/bitcoin/blob/v${finalAttrs.version}/doc/release-notes.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      prusnak
      mmahut
    ];

    platforms = lib.platforms.unix;
  };
})
