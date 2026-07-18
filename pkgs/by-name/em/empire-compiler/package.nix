{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  testers,
}:

buildDotnetModule (finalAttrs: {
  pname = "empire-compiler";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "bc-security";
    repo = "empire-compiler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HNT1sELoyibXDoRcKkBZiJHIsNY7Hz2fZfHEM93UCBE=";
  };

  postPatch = ''
    substituteInPlace EmpireCompiler/EmpireCompiler.csproj \
      --replace-fail 'net6.0' 'net9.0'
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  nugetDeps = ./deps.json;
  projectFile = "EmpireCompiler/EmpireCompiler.csproj";

  passthru = {
    tests.version = testers.testVersion {
      version = "${finalAttrs.version}";
      command = "EmpireCompiler --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "C# Compiler for Empire";
    homepage = "https://github.com/BC-SECURITY/Empire-Compiler";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fzakaria
      vrose
    ];

    platforms = lib.platforms.linux;
  };
})
