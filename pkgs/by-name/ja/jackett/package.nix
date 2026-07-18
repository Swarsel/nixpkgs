{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  mono,
  nix-update-script,
  nixosTests,
  openssl,
}:

buildDotnetModule (finalAttrs: {
  pname = "jackett";
  version = "0.24.2200";

  src = fetchFromGitHub {
    owner = "jackett";
    repo = "jackett";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hmgv17zju1BnT6eapTUhY+3Do/lr2+Cu/ejlU0/vF/I=";
  };

  postPatch = ''
    substituteInPlace ${finalAttrs.projectFile} ${finalAttrs.testProjectFile} \
      --replace-fail '<TargetFrameworks>net9.0;net471</' '<TargetFrameworks>net9.0</'
  '';

  # mono is not available on aarch64-darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ mono ];

  postFixup = ''
    # For compatibility
    ln -s $out/bin/jackett $out/bin/Jackett || :
    ln -s $out/bin/Jackett $out/bin/jackett || :
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetInstallFlags = [
    "--framework"
    "net9.0"
  ];

  nugetDeps = ./deps.json;
  projectFile = "src/Jackett.Server/Jackett.Server.csproj";
  runtimeDeps = [ openssl ];
  testProjectFile = "src/Jackett.Test/Jackett.Test.csproj";

  passthru = {
    tests = { inherit (nixosTests) jackett; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "API Support for your favorite torrent trackers";
    homepage = "https://github.com/Jackett/Jackett/";
    changelog = "https://github.com/Jackett/Jackett/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      nyanloutre
      purcell
    ];

    mainProgram = "jackett";
  };
})
