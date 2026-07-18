{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnet-sdk,
  fetchNpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  npmHooks,
}:

buildDotnetModule (finalAttrs: {
  pname = "immichframe";
  version = "1.0.35.0";

  src = fetchFromGitHub {
    owner = "immichFrame";
    repo = "immichFrame";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VET0em+CyJzXPlCXjozj6SDhjD26lH94AETFKGG895I=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
  ];

  preBuild = ''
    pushd ${finalAttrs.npmRoot}
    npm run build
    popd
  '';

  postInstall = ''
    cp -r ${finalAttrs.npmRoot}/build/* $out/lib/immichframe/wwwroot/
  '';

  dotnet-runtime = dotnet-sdk.aspnetcore;

  makeWrapperArgs = [
    "--chdir ${placeholder "out"}/lib/immichframe"
  ];

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/${finalAttrs.npmRoot}";
    hash = "sha256-RyMY5ooC6Q+W+Y24ILv+WCcWLMDToZ52yefFuoAYubY=";
  };

  npmRoot = "immichFrame.Web";
  nugetDeps = ./deps.json;
  projectFile = "ImmichFrame.WebApi/ImmichFrame.WebApi.csproj";

  passthru = {
    tests = { inherit (nixosTests) immichframe; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Display your photos from Immich as a digital photo frame";
    homepage = "https://immichframe.dev";
    changelog = "https://github.com/immichFrame/ImmichFrame/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jfly ];
    platforms = lib.platforms.all;
    mainProgram = "ImmichFrame.WebApi";
  };
})
