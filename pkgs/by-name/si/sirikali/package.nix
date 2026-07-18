{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fscrypt-experimental,
  gocryptfs,
  hicolor-icon-theme,
  kdePackages,
  libgcrypt,
  libpwquality,
  libsecret,
  pkg-config,
  qt6,
  sshfs,
  withKWallet ? true,
  withLibsecret ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sirikali";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "mhogomchungu";
    repo = "sirikali";
    rev = finalAttrs.version;
    hash = "sha256-x3YCnIAPAJ5mOUboo+8Wg8ePyPYKoO++aSh3nSOj00I=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    cmake
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    libpwquality
    hicolor-icon-theme
    libgcrypt
  ]
  ++ lib.optionals withKWallet [ kdePackages.kwallet ]
  ++ lib.optionals withLibsecret [ libsecret ];

  cmakeFlags = [
    "-DINTERNAL_LXQT_WALLET=false"
    "-DNOKDESUPPORT=${if withKWallet then "false" else "true"}"
    "-DNOSECRETSUPPORT=${if withLibsecret then "false" else "true"}"
    "-DBUILD_WITH_QT6=true"
  ];

  doCheck = true;

  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        fscrypt-experimental
        gocryptfs
        sshfs
      ]
    }"
  ];

  meta = {
    description = "Qt/C++ GUI front end to sshfs, ecryptfs-simple, gocryptfs and fscrypt";
    longDescription = "Sirikali also supports `cryfs`, but `cryfs` is no longer available in Nixpkgs.";
    homepage = "https://github.com/mhogomchungu/sirikali";
    changelog = "https://github.com/mhogomchungu/sirikali/blob/${finalAttrs.src.rev}/changelog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ linuxissuper ];
    platforms = lib.platforms.all;
    mainProgram = "sirikali";
  };
})
