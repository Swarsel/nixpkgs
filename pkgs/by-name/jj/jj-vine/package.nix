{
  lib,
  cacert,
  fetchFromCodeberg,
  git,
  jujutsu,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jj-vine";
  version = "0.5.3";

  src = fetchFromCodeberg {
    owner = "abrenneke";
    repo = "jj-vine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dUamfoMtdDNz9xmXeg1O1j5UHW6uF/1WznHSsG+eVjs=";
  };

  cargoHash = "sha256-nuj0cugeK5oc+sZmm1f5dvGEjML0qkle5uO66e54VIY=";
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs = [
    jujutsu
    git
    writableTmpDirAsHomeHook
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  checkFeatures = [ "no-e2e-tests" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for submitting stacked Pull/Merge Requests from Jujutsu bookmarks";
    homepage = "https://codeberg.org/abrenneke/jj-vine";
    changelog = "https://codeberg.org/abrenneke/jj-vine/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ winter ];
    mainProgram = "jj-vine";
  };
})
