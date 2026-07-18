{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "golds";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "go101";
    repo = "golds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jt0Q6Ie1HSqRs4+zlmNOXlSMXfWu0nSIOjglduq4FUE=";
  };

  # nixpkgs is not using the go distpack archive and missing a VERSION file in the source
  # but we can use go env to get the same information
  # https://github.com/NixOS/nixpkgs/pull/358316#discussion_r1855322027
  patches = [ ./info_module-gover.patch ];
  vendorHash = "sha256-qG6QeoIC6O+DzDTaKqtBIGaoG1jeyvNmcYFi/BVkPX0=";
  nativeCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  ldflags = [ "-s" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Experimental Go local docs server/generator and code reader implemented with some fresh ideas";
    homepage = "https://github.com/go101/golds";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.unix;
    mainProgram = "golds";
  };
})
