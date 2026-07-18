{
  lib,
  stdenv,
  fetchFromGitHub,
  expect,
  gnutls,
  kryoptic,
  meson,
  ninja,
  nix-update-script,
  nss,
  opensc,
  openssl,
  p11-kit,
  pkg-config,
  python3,
  softhsm,
  valgrind,
  which,
}:

let
  pkcs11ProviderPython3 = python3.withPackages (pythonPkgs: with pythonPkgs; [ six ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pkcs11-provider";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "openssl-projects";
    repo = "pkcs11-provider";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rymH/0otZ553lKqfdTRR5ttNsom9A3ObNNxptqB/eno=";
    fetchSubmodules = true;
  };

  # Need to search $KRYOPTIC for the path to the actual Kryoptic library.
  postPatch = ''
    patchShebangs --build .
    substituteInPlace tests/kryoptic-init.sh \
      --replace-fail /usr/local/lib/kryoptic "\\''${KRYOPTIC}"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    which
  ];

  buildInputs = [
    openssl
    nss
    p11-kit
  ];

  env = {
    KRYOPTIC = "${lib.getLib kryoptic}/lib";
  };

  doCheck = true;

  nativeCheckInputs = [
    p11-kit.bin
    opensc
    kryoptic
    nss.tools
    gnutls
    openssl.bin
    expect
    pkcs11ProviderPython3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    valgrind
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    # softokn and kryoptic are OK; softhsm is pretty flaky.
    # This fails with a `pkcs11-provider:softhsm / tls - FAIL - exit status 1`.
    # Considering that kryoptic is the Rust replacement, we can rely on it instead:
    # https://github.com/softhsm/SoftHSMv2/issues/803
    softhsm
  ];

  preInstall = ''
    # Meson tries to install to `$out/$out` and `$out/''${openssl.out}`; so join them.
    mkdir -p "$out"
    for dir in "$out" "${openssl.out}"; do
      mkdir -p .install/"$(dirname -- "$dir")"
      ln -s "$out" ".install/$dir"
    done
    export DESTDIR="$(realpath .install)"
  '';

  # Tests bind to localhost.
  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;
  # Frequently fails due to a race condition.
  enableParallelInstalling = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(\\d+\\.\\d+\\.\\d+)"
    ];
  };

  meta = {
    description = "OpenSSL 3.x provider to access hardware or software tokens using the PKCS#11 Cryptographic Token Interface";
    homepage = "https://github.com/latchset/pkcs11-provider";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ numinit ];
    platforms = lib.platforms.unix;
  };
})
