{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildGoModule,
  clang,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:
let
  pnpm = pnpm_10;
in
buildGoModule (finalAttrs: {
  pname = "daed";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "daed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CvxCDdOLsdSlFfmoR+C1IUt9HvkAV5JsWGI94DLXB+U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ clang ];
  vendorHash = "sha256-l7jgMvrbpOY2+cvnc0e5cvSgKVm4GcWC+bPbff+PE80=";

  buildPhase = ''
    runHook preBuild

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
      NOSTRIP=y \
      WEB_DIST=dist \
      AppName=daed \
      VERSION=${finalAttrs.version} \
      OUTPUT=$out/bin/daed \
      bundle

    runHook postBuild
  '';

  postInstall = ''
    install -Dm444 $src/install/daed.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/daed.service \
      --replace-fail /usr/bin $out/bin
  '';

  hardeningDisable = [ "zerocallusedregs" ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace-fail /bin/bash /bin/sh

    # ${finalAttrs.web} does not have write permission
    mkdir dist
    cp -r ${finalAttrs.web}/* dist
    chmod -R 755 dist
  '';

  proxyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/wing";

  web = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) pname version src;
    strictDeps = true;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R apps/web/dist/* $out

      runHook postInstall
    '';

    __structuredAttrs = true;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        ;

      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-2g/M+4XI1EM+c7W82qyfH8C7sX+Y0QACiSpn65Vei4g=";
    };
  };

  passthru = {
    inherit (finalAttrs) web;

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        attrPath = "daed.web";
        extraArgs = [ "--use-github-releases" ];
      })
      (nix-update-script {
        extraArgs = [ "--version=skip" ];
      })
    ];
  };

  meta = {
    description = "Modern dashboard with dae";
    homepage = "https://github.com/daeuniverse/daed";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      oluceps
      ccicnce113424
    ];

    platforms = lib.platforms.linux;
    mainProgram = "daed";
  };
})
