{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  fontconfig,
  freetype,
  jellyfin-ffmpeg,
  jellyfin-web,
  jq,
  nixosTests,
  sqlite,
  versionCheckHook,
}:

buildDotnetModule (finalAttrs: {
  pname = "jellyfin";
  version = "10.11.11"; # ensure that jellyfin-web has matching version

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HCs4ZsutVoVH+bBZANjpPeMyV8e63Yemjg9DSr0R9zg=";
  };

  nativeBuildInputs = [
    jq
  ];

  propagatedBuildInputs = [ sqlite ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Impurity with time. Injects the build date into this file
  postFixup = ''
    timestamp="$(TZ=GMT date -d "@$SOURCE_DATE_EPOCH" '+%a, %d %b %Y %X GMT')"

    cat "$out/lib/jellyfin/jellyfin.staticwebassets.endpoints.json" \
      | jq --arg timestamp "$timestamp" '.Endpoints[].ResponseHeaders[] |= if (.Name == "Last-Modified") then .Value = $timestamp else . end' \
      > jellyfin.staticwebassets.endpoints.json.new

    mv "jellyfin.staticwebassets.endpoints.json.new" "$out/lib/jellyfin/jellyfin.staticwebassets.endpoints.json"
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnetBuildFlags = [ "--no-self-contained" ];
  executables = [ "jellyfin" ];

  makeWrapperArgs = [
    "--add-flags"
    "--ffmpeg=${jellyfin-ffmpeg}/bin/ffmpeg"
    "--add-flags"
    "--webdir=${jellyfin-web}/share/jellyfin-web"
  ];

  nugetDeps = ./nuget-deps.json;
  projectFile = "Jellyfin.Server/Jellyfin.Server.csproj";

  runtimeDeps = [
    jellyfin-ffmpeg
    fontconfig
    freetype
  ];

  passthru.tests = {
    smoke-test = nixosTests.jellyfin;
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Free Software Media System";
    homepage = "https://jellyfin.org/";
    # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      nyanloutre
      minijackson
      purcell
      jojosch
    ];

    platforms = finalAttrs.dotnet-runtime.meta.platforms;
    mainProgram = "jellyfin";
  };
})
