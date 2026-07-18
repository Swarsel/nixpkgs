{
  lib,
  fetchFromGitHub,
  SDL2,
  buildDotnetModule,
  clangStdenv,
  dotnetCorePackages,
  gtk3,
  libx11,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "mesen";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "nesdev-org";
    repo = "MesenCE";
    tag = version;
    hash = "sha256-IH8Or+UVapQW0PXPanMVaOIQVT85TEYU2utKBbvuW6c=";
  };

  patches = [
    # patch out the usage of nightly avalonia builds, since we can't use alternative restore sources
    ./dont-use-nightly-avalonia.patch
    # upstream has a weird library loading mechanism, which we override with a more sane alternative
    ./dont-zip-libraries.patch
    # without this the generated .desktop file uses an absolute (and incorrect) path for the binary
    ./desktop-make-non-absolute-exec.patch
  ];

  nativeBuildInputs = [ wrapGAppsHook3 ];

  postInstall = ''
    ln -s ${passthru.core}/lib/MesenCore.* $out/lib/mesen
  '';

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    "-p:RuntimeIdentifier=${dotnetCorePackages.systemToDotnetRid clangStdenv.hostPlatform.system}"
  ];

  executables = [ "Mesen" ];
  nugetDeps = ./deps.json;
  projectFile = [ "UI/UI.csproj" ];
  runtimeDeps = [ gtk3 ];

  # according to upstream, compiling with clang creates a faster binary
  passthru.core = clangStdenv.mkDerivation {
    inherit version src;
    pname = "mesen-core";
    strictDeps = true;
    nativeBuildInputs = [ SDL2 ];
    buildInputs = [ SDL2 ] ++ lib.optionals clangStdenv.hostPlatform.isLinux [ libx11 ];
    makeFlags = [ "core" ];

    installPhase = ''
      runHook preInstall
      install -Dm755 InteropDLL/obj.*/MesenCore.* -t $out/lib
      runHook postInstall
    '';

    enableParallelBuilding = true;
  };

  meta = {
    description = "Multi-system emulator that supports NES, SNES, Game Boy, Game Boy Advance, PC Engine, SMS/Game Gear and WonderSwan games";
    homepage = "https://www.mesen.ca";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "Mesen";
  };
}
