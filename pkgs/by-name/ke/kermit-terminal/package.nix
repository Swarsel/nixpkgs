{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtk3,
  nixosTests,
  pcre,
  pkg-config,
  vte,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kermit";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "kermit";
    rev = finalAttrs.version;
    hash = "sha256-rhlUnRfyd7PmtMSyP+tiu+TxZNb/YyS0Yc5IkWft7/4=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gtk3
    pcre
    vte
  ];

  passthru.tests.test = nixosTests.terminal-emulators.kermit;

  meta = {
    description = "VTE-based, simple and froggy terminal emulator";
    homepage = "https://github.com/orhun/kermit";
    changelog = "https://github.com/orhun/kermit/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "kermit";
  };
})
