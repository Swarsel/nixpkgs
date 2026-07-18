{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "WiseUnpacker";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "mnadareski";
    repo = "WiseUnpacker";
    rev = finalAttrs.version;
    hash = "sha256-APbfo2D/p733AwNNByu5MvC9LA8WW4mAzq6t2w/YNrs=";
  };

  # Rename to something sensible
  postFixup = ''
    mv "$out/bin/Test" "$out/bin/WiseUnpacker"
  '';

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnetFlags = [ "-p:TargetFramework=net8.0" ];
  nugetDeps = ./deps.json;
  projectFile = "Test/Test.csproj";

  meta = {
    description = "C# Wise installer unpacker based on HWUN and E_WISE ";
    homepage = "https://github.com/mnadareski/WiseUnpacker/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.gigahawk ];
  };
})
