{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  fetchNpmDeps,
  nodejs-slim,
  npmHooks,
}:

buildDotnetModule (finalAttrs: {
  pname = "smtp4dev";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "rnwood";
    repo = "smtp4dev";
    tag = finalAttrs.version;
    hash = "sha256-1dzK0IHdjEppV62tE4Ywqs8WihLJUY4bhzJPQ1A/Eog=";
  };

  patches = [ ./smtp4dev-npm-packages.patch ];

  nativeBuildInputs = [
    nodejs-slim
    nodejs-slim.npm
    nodejs-slim.python
    npmHooks.npmConfigHook
    stdenv.cc # c compiler is needed for compiling npm-deps
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/smtp4dev --help > /dev/null

    runHook postInstallCheck
  '';

  postFixup = ''
    mv $out/bin/Rnwood.Smtp4dev $out/bin/smtp4dev
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "Rnwood.Smtp4dev" ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src patches;
    postPatch = "cd ${finalAttrs.npmRoot}";
    hash = "sha256-lJyjoTTgum67j1qPtkLFGYO2sTpvN7ug0Q1jJw/Se/c=";
  };

  npmRoot = "Rnwood.Smtp4dev/ClientApp";
  nugetDeps = ./deps.json;
  projectFile = "Rnwood.Smtp4dev/Rnwood.Smtp4dev.csproj";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Fake smtp email server for development and testing";
    homepage = "https://github.com/rnwood/smtp4dev";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      rucadi
      jchw
      defelo
    ];

    platforms = lib.platforms.unix;
    mainProgram = "smtp4dev";
  };
})
