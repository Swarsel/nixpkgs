{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule {
  pname = "imewlconverter";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "studyzy";
    repo = "imewlconverter";
    rev = "v3.3.0";
    hash = "sha256-4O25M91zOGK8nTxT0s7QlIcYYV0erWBErNlc2+BMpGk=";
  };

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  projectFile = "src/ImeWlConverterCmd/ImeWlConverterCmd.csproj";

  meta = {
    description = "FOSS program for converting IME dictionaries";
    homepage = "https://github.com/studyzy/imewlconverter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "ImeWlConverterCmd";
  };
}
