{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "arduino-ota";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduinoOTA";
    tag = finalAttrs.version;
    hash = "sha256-HaNMkeV/PDEotYp8+rUKFaBxGbZO8qA99Yp2sa6glz8=";
  };

  postPatch = ''
    substituteInPlace version/version.go \
      --replace-fail 'versionString        = ""' 'versionString        = "${finalAttrs.version}"'
  '';

  vendorHash = null;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for uploading programs to Arduino boards over a network";
    homepage = "https://github.com/arduino/arduinoOTA";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ poelzi ];
    platforms = lib.platforms.all;
    mainProgram = "arduinoOTA";
  };
})
