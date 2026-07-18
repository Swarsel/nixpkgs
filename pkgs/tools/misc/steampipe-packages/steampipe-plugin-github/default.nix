{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  steampipe,
}:

buildGoModule rec {
  pname = "steampipe-plugin-github";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "steampipe-plugin-github";
    tag = "v${version}";
    hash = "sha256-S0MJONrJnsLj9MikwcO/GAL3m2xTwiEFSNPVJhhqzTI=";
  };

  vendorHash = "sha256-atrctIm5m0OzeiIjs7ypYKflSgO+t0iWclwOM+oZGzM=";
  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp $GOPATH/bin/steampipe-plugin-github $out/steampipe-plugin-github.plugin
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
    description = "GitHub Plugin for Steampipe";
    longDescription = "Use SQL to instantly query repositories, users, gists and more from GitHub.";
    homepage = "https://github.com/turbot/steampipe-plugin-github";
    changelog = "https://github.com/turbot/steampipe-plugin-github/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    platforms = steampipe.meta.platforms;
  };
}
