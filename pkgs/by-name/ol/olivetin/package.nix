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
  version = "2025.11.25";

  src = fetchFromGitHub {
    owner = "OliveTin";
    repo = "OliveTin";
    tag = finalAttrs.version;
    hash = "sha256-HQLInEVXowWpDaSW/4bduUMdYsvQ0Rju1Rl2l9jupYA=";
  };

  patches = [ ./update-go-sum.patch ];
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-xSroaS6fwHrQ0s09uD3bkBZWWxbIndiOGL2JPvKzC6E=";

  preBuild = ''
    ln -s ${finalAttrs.gen} gen
    substituteInPlace internal/config/config.go \
      --replace-fail 'config.WebUIDir = "./webui"' 'config.WebUIDir = "${finalAttrs.webui}"'
    substituteInPlace internal/httpservers/webuiServer_test.go \
      --replace-fail '"../webui/"' '"${finalAttrs.webui}"'
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

    outputHash = "sha256-fTsJE9ymtJ0TU2OhXLE+XfEOckFMG7IPi0IHHAmN84s=";
    outputHashMode = "recursive";
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  modRoot = "service";
  versionCheckProgramArg = "-version";

  webui = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "olivetin-webui";
    npmDepsHash = "sha256-a1BBNlGusdMlmDXgclGqkO8AywSd4DTQKkuBVzuzAfE=";

    buildPhase = ''
      runHook preBuild

      npx parcel build --public-url "."

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out
      cp -r *.png $out

      runHook postInstall
    '';

    sourceRoot = "${finalAttrs.src.name}/webui.dev";
  };

  passthru = {
    releaseSeries = "2k";

    tests.olivetin = nixosTests.olivetin.extendNixOS {
      module = {
        services.olivetin.package = finalAttrs.finalPackage;
      };
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Gives safe and simple access to predefined shell commands from a web interface";
    homepage = "https://www.olivetin.app/";
    changelog = "https://github.com/OliveTin/OliveTin/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "OliveTin";
    downloadPage = "https://github.com/OliveTin/OliveTin";

    knownVulnerabilities = [
      "CVE-2026-27626: OS Command Injection via password argument type and webhook JSON extraction bypasses shell safety checks"
      "CVE-2026-28342: Unauthenticated Denial of Service via Memory Exhaustion in PasswordHash API Endpoint"
      "CVE-2026-28789: Unauthenticated DoS via concurrent map writes in OAuth2 state handling"
      "CVE-2026-28790: Unauthenticated Action Termination via KillAction When Guests Must Login"
      "CVE-2026-30223: JWT Audience Validation Bypass in Local Key and HMAC Modes"
      "CVE-2026-30224: Session Fixation - Logout Fails to Invalidate Server-Side Session"
      "CVE-2026-30225: RestartAction always runs actions as guest"
      "CVE-2026-30233: View permission not being checked when returning dashboards"
      "CVE-2026-31817: Unsafe parsing of UniqueTrackingId can be used to write files"
    ];
  };
})
