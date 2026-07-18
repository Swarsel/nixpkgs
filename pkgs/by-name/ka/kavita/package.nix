{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  buildNpmPackage,
  dotnetCorePackages,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kavita";
  version = "0.9.0.2";

  src = fetchFromGitHub {
    owner = "kareadita";
    repo = "kavita";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Wfb/Lc+BvkiJLopH1NQx1YQWzm2Sdmvg1Xmn+8YwWus=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/kavita
    ln -s $backend/lib/kavita-backend $out/lib/kavita/backend
    ln -s $frontend/lib/node_modules/kavita-webui/dist $out/lib/kavita/frontend
    ln -s $backend/bin/Kavita.Server $out/bin/kavita

    runHook postInstall
  '';

  backend = buildDotnetModule {
    inherit (finalAttrs) version src;
    pname = "kavita-backend";

    patches = [
      # The webroot is hardcoded as ./wwwroot
      ./change-webroot.diff
      # NOTE: Upstream frequently removes old database migrations between versions.
      # Currently no migration patches are needed for upgrades from NixOS 24.11 (v0.8.3.2).
      # Future updates should check if migration restoration is needed for supported upgrade paths.
    ];

    postPatch = ''
      substituteInPlace Kavita.Services/DirectoryService.cs --subst-var out

      substituteInPlace Kavita.Server/Startup.cs Kavita.Services/LocalizationService.cs Kavita.Server/Controllers/FallbackController.cs \
        --subst-var-by webroot "${finalAttrs.frontend}/lib/node_modules/kavita-webui/dist/browser"
    '';

    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    nugetDeps = ./nuget-deps.json;
    projectFile = "Kavita.Server/Kavita.Server.csproj";
  };

  dontBuild = true;

  frontend = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "kavita-frontend";
    npmDepsHash = "sha256-Qa/lf0hH2KMDdRcBj8GW9cJGE3YZsP32z2kfTk6YNYc=";
    npmBuildScript = "prod";
    npmFlags = [ "--legacy-peer-deps" ];
    npmRebuildFlags = [ "--ignore-scripts" ]; # Prevent playwright from trying to install browsers
    sourceRoot = "${finalAttrs.src.name}/UI/Web";
  };

  passthru = {
    tests = {
      inherit (nixosTests) kavita;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Fast, feature rich, cross platform reading server";
    homepage = "https://kavitareader.com";
    changelog = "https://github.com/kareadita/kavita/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      misterio77
      nevivurn
    ];

    platforms = lib.platforms.linux;
    mainProgram = "kavita";
  };
})
