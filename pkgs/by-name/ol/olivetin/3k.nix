{
  lib,
  fetchFromGitHub,
  buf,
  buildGoModule,
  buildNpmPackage,
  grpc-gateway,
  installShellFiles,
  nixosTests,
  protoc-gen-go,
  protoc-gen-go-grpc,
  stdenvNoCC,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "olivetin";
  version = "3000.17.0";

  src = fetchFromGitHub {
    owner = "OliveTin";
    repo = "OliveTin";
    tag = finalAttrs.version;
    hash = "sha256-oLBXDd1grSFEbCvB4bK2XeVOZONSYro/6rvMJkG8eU0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-lZ3KBoM+cDyYPX16wuZT3UQvB/SrRD6W2ic+GznG7hU=";

  preBuild = ''
    ln -s ${finalAttrs.gen} gen
    substituteInPlace internal/config/config.go \
      --replace-fail 'config.WebUIDir = "./webui"' 'config.WebUIDir = "${finalAttrs.webui}"'
  '';

  postInstall = ''
    installManPage ../var/manpage/OliveTin.1.gz
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  gen = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "olivetin-gen";

    nativeBuildInputs = [
      writableTmpDirAsHomeHook
      buf
      protoc-gen-go
      protoc-gen-go-grpc
      grpc-gateway
    ];

    buildPhase = ''
      runHook preBuild

      pushd proto
      buf generate
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r service/gen $out

      runHook postInstall
    '';

    postFixup = ''
      find $out -type f -name '*.go' -exec \
        sed -i -E 's|//.*protoc-gen-go(-grpc)? +v.*$||' {} +
    '';

    outputHash = "sha256-X602MebKdmdxZ9OEtQ150u+/Z1O9FEvcxRtOhMorqyw=";
    outputHashMode = "recursive";
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  modRoot = "service";
  subPackages = [ "." ];
  versionCheckProgramArg = "-version";

  webui = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "olivetin-webui";
    npmDepsHash = "sha256-fr5RTPNXNd8sD/LphnDsekIbB333LgEHCb/NUEqSBIE=";

    buildPhase = ''
      runHook preBuild

      make build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out

      runHook postInstall
    '';

    sourceRoot = "${finalAttrs.src.name}/frontend";
  };

  passthru = {
    releaseSeries = "3k";

    tests.olivetin = nixosTests.olivetin.extendNixOS {
      module = {
        services.olivetin.package = finalAttrs.finalPackage;
      };
    };

    updateScript = ./update-3k.sh;
  };

  meta = {
    description = "Gives safe and simple access to predefined shell commands from a web interface";
    homepage = "https://www.olivetin.app/";
    changelog = "https://github.com/OliveTin/OliveTin/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "OliveTin";
    downloadPage = "https://github.com/OliveTin/OliveTin";
  };
})
