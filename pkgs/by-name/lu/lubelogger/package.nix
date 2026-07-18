{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule rec {
  pname = "lubelogger";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "hargata";
    repo = "lubelog";
    rev = "v${version}";
    hash = "sha256-ePzR6TmByUBWGuOEg8WKMpvQT7qHGkZuBF8CkTwMtuY=";
  };

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  executables = [ "CarCareTracker" ]; # This wraps "$out/lib/$pname/foo" to `$out/bin/foo`.

  makeWrapperArgs = [
    "--set DOTNET_WEBROOT ${placeholder "out"}/lib/lubelogger/wwwroot"
  ];

  nugetDeps = ./deps.json; # File generated with `nix-build -A lubelogger.passthru.fetch-deps`.
  projectFile = "CarCareTracker.sln";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vehicle service records and maintainence tracker";

    longDescription = ''
      A self-hosted, open-source, unconventionally-named vehicle maintenance records and fuel mileage tracker.
    '';

    homepage = "https://lubelogger.com";
    changelog = "https://github.com/hargata/lubelog/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lyndeno ];
    platforms = lib.platforms.all;
    mainProgram = "CarCareTracker";
  };
}
