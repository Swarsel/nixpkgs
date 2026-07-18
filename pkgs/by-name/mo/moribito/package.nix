{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libx11,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "moribito";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "ericschmar";
    repo = "moribito";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/p7RVsz9jjPTVkEjhDsSHQmYVOsvpbb1APLGQYVjgiU=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];
  vendorHash = "sha256-O5OmVP5aGlc8Bz2nVAAkhCdTuonB9yXGSz5FO3FxJ1I=";
  # Clipboard support
  env.CGO_ENABLED = 1;
  subPackages = [ "cmd/moribito" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal LDAP explorer";
    homepage = "https://github.com/ericschmar/moribito";
    changelog = "https://github.com/ericschmar/moribito/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kumpelinus ];
    mainProgram = "moribito";
  };
})
