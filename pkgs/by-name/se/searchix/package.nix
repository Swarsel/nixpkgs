{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchFromCodeberg,
  nix-update-script,
  versionCheckHook,
}:

let
  simpleCss = fetchFromGitHub {
    hash = "sha256-rihjNW1gf0k7DI8x+vaFUR4ehI3gXDV9zWV3DGSg4y8=";
    owner = "kevquirk";
    repo = "simple.css";
    rev = "ba4af949057d489331759e0118de596222e0f5b7";
  };
in

buildGoModule (finalAttrs: {
  pname = "searchix";
  version = "0.4.9";

  src = fetchFromCodeberg {
    owner = "alinnow";
    repo = "searchix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pyBl6y53Efa+4qQ92elA4r+zO7rPxha+4hnmmFTsoaE=";
  };

  vendorHash = "sha256-BG6v4HsXtSCmEmzdawH1YfEfDMbXNH8XGMF+jJgy+3w=";

  preBuild = ''
    rm -f frontend/static/base.css
    cp ${simpleCss}/simple.css frontend/static/base.css
  '';

  postInstall = ''
    $out/bin/searchix-web generate-error-page --outdir $out/share/searchix/
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X=alin.ovh/searchix/internal/config.Version=${finalAttrs.version}"
  ];

  overrideModAttrs = old: {
    # netdb.go allows /etc/protocols and /etc/services to not exist and happily proceeds, but it panic()s if they exist but return permission denied.
    postBuild = ''
      patch -p0 < ${./darwin-sandbox-fix.patch}
    '';
  };

  subPackages = [ "cmd/searchix-web" ];
  tags = [ "embed" ];
  versionCheckProgramArg = "version";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Search tool for options and packages in the NixOS ecosystem";
    homepage = "https://searchix.ovh/";
    changelog = "https://codeberg.org/alinnow/searchix/src/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      airone01
      BatteredBunny
    ];

    mainProgram = "searchix-web";
    downloadPage = "https://codeberg.org/alinnow/searchix";
  };
})
