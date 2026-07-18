{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  steampipe,
}:

buildGoModule rec {
  pname = "steampipe-plugin-aws";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "steampipe-plugin-aws";
    tag = "v${version}";
    hash = "sha256-Mt9KUyV9BrCdwDwF9NzOdOTF90W4vpT3N2n/QaVo6qo=";
  };

  vendorHash = "sha256-8ZVl70Lwz3j3PM3XljZGFaoGt+JP6TP+o5gOGoBlUY8=";
  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp $GOPATH/bin/steampipe-plugin-aws $out/steampipe-plugin-aws.plugin
    cp -R docs $out/.
    cp -R config $out/.

    runHook postInstall
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AWS Plugin for Steampipe";
    longDescription = "Use SQL to instantly query AWS resources across regions and accounts.";
    homepage = "https://github.com/turbot/steampipe-plugin-aws";
    changelog = "https://github.com/turbot/steampipe-plugin-aws/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    platforms = steampipe.meta.platforms;
  };
}
