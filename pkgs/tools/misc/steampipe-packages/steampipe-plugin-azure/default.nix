{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  steampipe,
}:

buildGoModule rec {
  pname = "steampipe-plugin-azure";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "steampipe-plugin-azure";
    tag = "v${version}";
    hash = "sha256-QnVv9bHmgNex+4h/qyFgXd+CXoLrHjfxOReeYfrC/6Q=";
  };

  vendorHash = "sha256-VHLRKdzHCXybcqSTV1xjTk1Edt1EwEmqYvUFtDQNZFM=";
  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp $GOPATH/bin/steampipe-plugin-azure $out/steampipe-plugin-azure.plugin
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
    description = "Azure Plugin for Steampipe";
    longDescription = "Use SQL to instantly query Azure resources across regions and subscriptions.";
    homepage = "https://github.com/turbot/steampipe-plugin-azure";
    changelog = "https://github.com/turbot/steampipe-plugin-azure/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.apsl20;
    maintainers = [ ];
    platforms = steampipe.meta.platforms;
  };
}
