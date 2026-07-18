{
  lib,
  fetchFromGitHub,
  libsodium,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustdesk-server,
  sqlite,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustdesk-server";
  version = "1.1.14";

  src = fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk-server";
    tag = finalAttrs.version;
    hash = "sha256-5LRMey1cxmjLg1s9RtVwgPjHjwYLSQHa6Tyv7r/XEQs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libsodium
    sqlite
  ];

  cargoHash = "sha256-U1LTnqi2iEsm2U7t0Fr4VJWLo1MdQmeTKrPsNqRWap0=";

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "hbbr --version";
      package = rustdesk-server;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "RustDesk Server Program";
    homepage = "https://github.com/rustdesk/rustdesk-server";
    changelog = "https://github.com/rustdesk/rustdesk-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
