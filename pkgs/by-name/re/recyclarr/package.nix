{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  git,
  openssl,
  testers,
}:
buildDotnetModule (finalAttrs: {
  pname = "recyclarr";
  version = "8.6.0";

  src = fetchFromGitHub {
    owner = "recyclarr";
    repo = "recyclarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uu6fBKODzKGYA6vSJPw0OV/+bi3y2F/SHfrdd5pdyzs=";
  };

  postPatch = ''
    cat > src/Recyclarr.Core/GitVersionInformation.g.cs <<'EOF'
    public static class GitVersionInformation
    {
        public static string SemVer => "${finalAttrs.version}";
        public static string FullBuildMetaData => "nixpkgs";
        public static string InformationalVersion => "${finalAttrs.version}+nixpkgs";
        public static int Major => ${lib.versions.major finalAttrs.version};
    }
    EOF

    rm .config/dotnet-tools.json
  '';

  doCheck = false;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetBuildFlags = [
    "-p:DisableGitVersionTask=true"
    "/m:1"
  ];

  executables = [ "recyclarr" ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        git
        openssl
      ]
    }"
  ];

  nugetDeps = ./deps.json;
  projectFile = "Recyclarr.slnx";

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Automatically sync TRaSH guides to your Sonarr and Radarr instances";
    homepage = "https://recyclarr.dev/";
    changelog = "https://github.com/recyclarr/recyclarr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      josephst
      aldoborrero
    ];

    mainProgram = "recyclarr";
  };
})
