{
  lib,
  fetchFromGitea,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "syndicate-server";
  version = "0.50.1";

  src = fetchFromGitea {
    owner = "syndicate-lang";
    repo = "syndicate-rs";
    rev = "syndicate-server-v${finalAttrs.version}";
    hash = "sha256-orQN83DE+ZNgdx2PVcYrte/rVDFFtuQuRDKzeumpsLo=";
    domain = "git.syndicate-lang.org";
  };

  nativeBuildInputs = [
    pkg-config
    versionCheckHook
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-lR36UAMedPdfvX613adxxRzJe+Ri09hiZYanyu7xbLU=";
  env.RUSTC_BOOTSTRAP = 1;
  doCheck = false;
  doInstallCheck = true;

  meta = {
    description = "Syndicate broker server";
    homepage = "https://synit.org/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "syndicate-server";
  };
})
