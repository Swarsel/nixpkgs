{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  ffmpeg,
  which,
}:

buildDotnetModule rec {
  pname = "ersatztv";
  version = "26.5.1";

  src = fetchFromGitHub {
    owner = "ErsatzTV";
    repo = "legacy";
    rev = "v${version}";
    sha256 = "sha256-2w+4xppj3E8H6WXea/iuNfloUmBsFQKDBpTnUn3RWvE=";
  };

  postPatch = ''
    # Remove config of development tools that don't end up in
    # nuget-deps.json but would be looked up at build time
    # leading to a missing package error.
    rm -r .config
  '';

  buildInputs = [ ffmpeg ];
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnetFlags = [ "-p:TreatWarningsAsErrors=false" ];

  executables = [
    "ErsatzTV"
    "ErsatzTV.Scanner"
  ];

  # ETV uses `which` to find `ffmpeg` and `ffprobe`
  makeWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      ffmpeg
      which
    ]}"
  ];

  nugetDeps = ./nuget-deps.json;
  projectFile = "ErsatzTV/ErsatzTV.csproj";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Stream custom live channels using your own media";
    homepage = "https://ersatztv.org/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ allout58 ];
    platforms = dotnet-runtime.meta.platforms;
    mainProgram = "ErsatzTV";
  };
}
