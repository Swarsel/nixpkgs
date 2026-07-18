{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  debianutils,
  mkdocs,
  nixosTests,
  python3,
  python3Packages,
  runtimeShell,
}:

buildGoModule (
  finalAttrs:

  let
    ui = buildNpmPackage {
      inherit (finalAttrs) src version;
      pname = "ntfy-sh-ui";
      npmDepsHash = "sha256-ENwqAS3HDzezlwiNG7e0dCN16c6RreBirua+Yv6GTS4=";

      installPhase = ''
        runHook preInstall

        mv build/index.html build/app.html
        rm build/config.js
        mkdir -p $out
        mv build/ $out/site

        runHook postInstall
      '';

      prePatch = ''
        cd web/
      '';
    };
  in
  {
    pname = "ntfy-sh";
    version = "2.26.0";

    src = fetchFromGitHub {
      owner = "binwiederhier";
      repo = "ntfy";
      tag = "v${finalAttrs.version}";
      hash = "sha256-/VOCztlfi8n12PrUmv17jNpV2/aVh+G0Qq0/leuHnzw=";
    };

    postPatch = ''
      sed -i 's# /bin/echo# echo#' Makefile
      substituteInPlace \
          cmd/subscribe_unix.go \
          cmd/subscribe_darwin.go \
        --replace \
          'scriptLauncher = []string{"sh", "-c"}' \
          'scriptLauncher = []string{"${runtimeShell}", "-c"}'
    '';

    nativeBuildInputs = [
      debianutils
      mkdocs
      python3
      python3Packages.mkdocs-material
      python3Packages.mkdocs-minify-plugin
    ];

    vendorHash = "sha256-t/NTLIL+eVFBFuTy6T1st8cdRliJZCYHojyDx76IW7o=";

    preBuild = ''
      cp -r ${ui}/site/ server/
      make docs-build
    '';

    doCheck = false;

    excludedPackages = [
      # main module (heckel.io/ntfy/v2) does not contain package heckel.io/ntfy/v2/tools/loadtest
      "tools/loadtest"
    ];

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${finalAttrs.version}"
    ];

    passthru = {
      tests.ntfy-sh = nixosTests.ntfy-sh;
      updateScript = ./update.sh;
    };

    meta = {
      description = "Send push notifications to your phone or desktop via PUT/POST";
      homepage = "https://ntfy.sh";
      changelog = "https://github.com/binwiederhier/ntfy/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.asl20;

      maintainers = with lib.maintainers; [
        arjan-s
        fpletz
        matthiasbeyer
      ];

      mainProgram = "ntfy";
    };
  }
)
