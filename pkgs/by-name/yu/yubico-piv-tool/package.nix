{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  gengetopt,
  help2man,
  nix-update-script,
  openssl,
  pcsclite,
  pkg-config,
  testers,
  zlib,
  withApplePCSC ? stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yubico-piv-tool";
  version = "2.7.3";

  src = fetchFromGitHub {
    owner = "Yubico";
    repo = "yubico-piv-tool";
    tag = "yubico-piv-tool-${finalAttrs.version}";
    hash = "sha256-BXYsx9GtH3svHTnJuqCiWIJ+9kE09BjAPbAPKawNCDc=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "-Werror" ""
  '';

  nativeBuildInputs = [
    cmake
    gengetopt
    help2man
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
  ]
  ++ lib.optionals (!withApplePCSC) [ pcsclite ];

  cmakeFlags = [
    (lib.cmakeBool "GENERATE_MAN_PAGES" true)
    (lib.cmakeFeature "BACKEND" (if withApplePCSC then "macscard" else "pcsc"))
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_MANDIR" "share/man")
  ];

  doCheck = true;
  nativeCheckInputs = [ check ];

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "yubico-piv-tool --version";
        package = finalAttrs.finalPackage;
      };

      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "yubico-piv-tool-([0-9.]+)$"
      ];
    };
  };

  meta = {
    description = ''
      Used for interacting with the Privilege and Identification Card (PIV)
      application on a YubiKey
    '';

    longDescription = ''
      The Yubico PIV tool is used for interacting with the Privilege and
      Identification Card (PIV) application on a YubiKey.
      With it you may generate keys on the device, importing keys and
      certificates, and create certificate requests, and other operations.
      A shared library and a command-line tool is included.
    '';

    homepage = "https://developers.yubico.com/yubico-piv-tool/";
    changelog = "https://developers.yubico.com/yubico-piv-tool/Release_Notes.html";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      viraptor
      anthonyroussel
    ];

    platforms = lib.platforms.all;
    mainProgram = "yubico-piv-tool";

    pkgConfigModules = [
      "ykcs11"
      "ykpiv"
    ];
  };
})
