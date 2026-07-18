{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  replaceVars,
}:

buildGoModule (finalAttrs: {
  pname = "silverbullet";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "silverbulletmd";
    repo = "silverbullet";
    rev = finalAttrs.version;
    hash = "sha256-XQ0OKkiQrrmwmdGXk3dcim/2qosenF3EG2lkglQQ/iY=";
  };

  vendorHash = "sha256-8zZlhVptJq8y3k2DBghJ0lPNcIcaZYkrxN67b6dNBPs=";

  preBuild = ''
    cp -r ${finalAttrs.frontend}/client_bundle .
    cp ${finalAttrs.frontend}/public_version.ts .
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "$GOPATH/bin/silverbullet" $out/bin/silverbullet

    runHook postInstall
  '';

  frontend = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "silverbullet-frontend";

    patches = [
      (replaceVars ./override-public-version.patch { inherit (finalAttrs) version; })
    ];

    npmDepsHash = "sha256-Twcv3I3scF09onJQdYsc1zOFzMFPOEyPF7VPYa7LBko=";

    postBuild = ''
      npm run build:plug-compile
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r client_bundle public_version.ts $out/

      runHook postInstall
    '';
  };

  subPackages = [ "." ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open-source, self-hosted, offline-capable Personal Knowledge Management (PKM) web application";
    homepage = "https://silverbullet.md";
    changelog = "https://github.com/silverbulletmd/silverbullet/blob/${finalAttrs.version}/website/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aorith
      CnTeng
    ];

    mainProgram = "silverbullet";
  };
})
