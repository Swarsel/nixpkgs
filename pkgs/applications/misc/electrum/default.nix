{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  python3,
  qtwayland,
  wrapQtAppsHook,
  zbar,
  enablePythonEcdsa ? false,
  enableQt ? true,
}:

let
  libzbar_name =
    if stdenv.hostPlatform.isLinux then
      "libzbar.so.0"
    else if stdenv.hostPlatform.isDarwin then
      "libzbar.0.dylib"
    else
      "libzbar${stdenv.hostPlatform.extensions.sharedLibrary}";
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "electrum";
  version = "4.8.0";

  src = fetchurl {
    url = "https://download.electrum.org/${finalAttrs.version}/Electrum-${finalAttrs.version}.tar.gz";
    hash = "sha256-z14bzs81eJNTMSWSBLTyCmsljDNztG54SVkoTcSqvsM=";
  };

  postPatch =
    if enableQt then
      ''
        substituteInPlace ./electrum/qrscanner.py \
          --replace-fail ${libzbar_name} ${zbar.lib}/lib/libzbar${stdenv.hostPlatform.extensions.sharedLibrary}
      ''
    else
      ''
        sed -i '/qdarkstyle/d' contrib/requirements/requirements.txt
      '';

  nativeBuildInputs = [
    python3.pkgs.pythonRelaxDepsHook
  ]
  ++ lib.optionals enableQt [
    wrapQtAppsHook
  ];

  buildInputs = lib.optional (stdenv.hostPlatform.isLinux && enableQt) qtwayland;

  nativeCheckInputs = with python3.pkgs; [
    protobuf
    pytestCheckHook
    pyaes
    pycryptodomex
  ];

  checkInputs =
    with python3.pkgs;
    lib.optionals enableQt [
      pyqt6
    ];

  # avoid homeless-shelter error in tests
  preCheck = ''
    export PYTHONPATH=${python3.pkgs.protobuf}/${python3.sitePackages}:$PYTHONPATH
    export HOME="$(mktemp -d)"
  '';

  postCheck = ''
    $out/bin/electrum help >/dev/null
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $out/share/applications/electrum.desktop \
      --replace-fail "Exec=electrum %u" "Exec=$out/bin/electrum %u" \
      --replace-fail "Exec=electrum --testnet %u" "Exec=$out/bin/electrum --testnet %u"
  '';

  preFixup = ''
    makeWrapperArgs+=(--prefix PYTHONPATH : ${python3.pkgs.protobuf}/${python3.sitePackages})
  ''
  + lib.optionalString enableQt ''
    qtWrapperArgs+=(--prefix PYTHONPATH : ${python3.pkgs.protobuf}/${python3.sitePackages})
  '';

  postFixup = lib.optionalString enableQt ''
    wrapQtApp $out/bin/electrum
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies =
    with python3.pkgs;
    [
      aiohttp
      aiohttp-socks
      aiorpcx
      attrs
      bitstring
      cryptography
      dnspython
      jsonrpclib-pelix
      matplotlib
      pbkdf2
      protobuf
      pysocks
      qrcode
      requests
      certifi
      jsonpatch
      electrum-aionostr
      electrum-ecc
      # plugins
      ledger-bitcoin
      cbor2
      pyserial
    ]
    ++ lib.optionals enablePythonEcdsa [
      # enablePythonEcdsa gates plugins known to pull in python-ecdsa, which we
      # avoid by default due to CVE-2024-23342.
      ckcc-protocol
      keepkey
      trezor
      bitbox02
    ]
    ++ lib.optionals enableQt [
      pyqt6
      qdarkstyle
    ];

  disabledTestPaths = lib.optionals (!enableQt) [
    "tests/test_qml_types.py"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;

  pythonRelaxDeps = [
    "attrs"
    "dnspython"
  ];

  pythonRemoveDeps = [
    "protobuf"
  ];

  passthru.updateScript = callPackage ./update.nix { };

  meta = {
    description = "Lightweight Bitcoin wallet";

    longDescription = ''
      An easy-to-use Bitcoin client featuring wallets generated from
      mnemonic seeds (in addition to other, more advanced, wallet options)
      and the ability to perform transactions without downloading a copy
      of the blockchain.
    '';

    homepage = "https://electrum.org/";
    changelog = "https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      np
      prusnak
      ryand56
    ];

    platforms = lib.platforms.all;
    mainProgram = "electrum";
    downloadPage = "https://electrum.org/#download";
  };
})
