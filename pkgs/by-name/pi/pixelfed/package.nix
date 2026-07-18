{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  php,
  dataDir ? "/var/lib/pixelfed",
  runtimeDir ? "/run/pixelfed",
}:
let
  php' = php.withExtensions ({ all, enabled }: enabled ++ (with all; [ ffi ]));
in
php'.buildComposerProject2 (finalAttrs: {
  pname = "pixelfed";
  version = "0.12.7";

  src = fetchFromGitHub {
    owner = "pixelfed";
    repo = "pixelfed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ay1WJWEPwzeTtScaj+g72lsoWODeHWtjnQT5aa6epbU=";
  };

  vendorHash = "sha256-RNJzvWrKfxr2uBFtc05N1pUfBmvy01JiJHMWgtJ01pA=";

  postInstall = ''
    chmod -R u+w $out/share
    mv "$out/share/php/pixelfed"/* $out
    rm -R $out/bootstrap/cache
    # Move static contents for the NixOS module to pick it up, if needed.
    mv $out/bootstrap $out/bootstrap-static
    mv $out/storage $out/storage-static
    ln -s ${dataDir}/.env $out/.env
    ln -s ${dataDir}/storage $out/
    ln -s ${dataDir}/storage/app/public $out/public/storage
    ln -s ${runtimeDir} $out/bootstrap
    chmod +x $out/artisan
  '';

  passthru = {
    tests = { inherit (nixosTests.pixelfed) standard; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Federated image sharing platform";
    homepage = "https://pixelfed.org/";
    license = lib.licenses.agpl3Only;
    platforms = php.meta.platforms;
    teams = with lib.teams; [ ngi ];
  };
})
