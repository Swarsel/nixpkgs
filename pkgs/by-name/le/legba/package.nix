{
  lib,
  fetchFromGitHub,
  cmake,
  openssl,
  pkg-config,
  rustPlatform,
  samba,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "legba";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "evilsocket";
    repo = "legba";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iynUReIWebfBkmWxbajsKbdfWSy+fzqF3NNssjtshYY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl.dev
    samba
  ];

  cargoHash = "sha256-clqOTFUOxZ1yt2YVgVDvsq2MhwMH7/s+jHSwt3buXgU=";
  # Paho C test fails due to permission issue
  doCheck = false;

  meta = {
    description = "Multiprotocol credentials bruteforcer / password sprayer and enumerator";
    homepage = "https://github.com/evilsocket/legba";
    changelog = "https://github.com/evilsocket/legba/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mikaelfangel ];
    mainProgram = "legba";
  };
})
