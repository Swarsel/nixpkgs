{
  lib,
  fetchFromGitHub,
  nixosTests,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "davis";
  version = "5.4.3";

  src = fetchFromGitHub {
    owner = "tchapi";
    repo = "davis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QCXjw01uJAt22/Vybm/bgE7GeGj4utwdTbXJ2oIVWRo=";
  };

  vendorHash = "sha256-YSpDBkg/Xlq4cPeil5CaSVXgfKcrUFFRdR4kvFtwzhU=";

  postInstall = ''
    chmod -R u+w $out/share
    # Only include the files needed for runtime in the derivation
    mv $out/share/php/davis/{migrations,public,src,config,bin,templates,tests,translations,vendor,symfony.lock,composer.json,composer.lock} $out
    # Save the upstream .env file for reference, but rename it so it is not loaded
    mv $out/share/php/davis/.env $out/env-upstream
    rm -rf "$out/share"
  '';

  composerNoPlugins = false;

  passthru = {
    php = php;

    tests = {
      inherit (nixosTests) davis;
    };
  };

  meta = {
    description = "Simple CardDav and CalDav server inspired by Baïkal";
    homepage = "https://github.com/tchapi/davis";
    changelog = "https://github.com/tchapi/davis/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ramblurr ];
  };
})
