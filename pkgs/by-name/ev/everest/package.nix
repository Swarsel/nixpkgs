{
  lib,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  dotnetCorePackages,
  icu,
  mono,
}:

let
  pname = "everest";
  version = "6314";
  rev = "a3112074ae83766af9f8cf48295689bbd8166730";
  phome = "$out/lib/Celeste";
in
buildDotnetModule {
  inherit pname version;

  src = fetchFromGitHub {
    inherit rev;
    owner = "EverestAPI";
    repo = "Everest";
    # TODO: use leaveDotGit = true and modify external/MonoMod in postFetch to please SourceLink
    # Microsoft.SourceLink.Common.targets(53,5): warning : Source control information is not available - the generated source link is empty.
    hash = "sha256-yZLhjP09ocn8lbb6SuklcEHvqz/GV2/wlxpjYm/gr08=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # MonoMod.ILHelpers.Patcher complains at build phase: You must install .NET to run this application.
    sed -i 's|<Exec Command="&quot;|<Exec Command="DOTNET_ROOT=${dotnetCorePackages.runtime_9_0}/share/dotnet \&quot;|' external/MonoMod/tools/Common.IL.targets

    # Moving files after publishing somehow doesn't work. Will do this manually in postInstall.
    sed -i 's|<Move.*/>||' Celeste.Mod.mm/Celeste.Mod.mm.csproj

    autoPatchelf lib-ext/piton/piton-linux_x64
  '';

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    icu # For autoPatchelf
    mono # See upstream README
  ];

  preBuild = ''
    # See .azure-pipelines/prebuild.ps1
    sed -i 's|0\.0\.0-dev|1.${version}.0-nixos-${lib.substring 0 5 rev}|' Celeste.Mod.mm/Mod/Everest/Everest.cs
    cat <<-EOF > Celeste.Mod.mm/Mod/Helpers/EverestVersion.cs
      namespace Celeste.Mod.Helpers {
        internal static class EverestBuild${version} {
          public static string EverestBuild = "EverestBuild${version}";
        }
      }
    EOF
  '';

  postInstall = ''
    mkdir tmp-EverestSplash
    mv ${phome}/EverestSplash* tmp-EverestSplash
    mv tmp-EverestSplash ${phome}/EverestSplash
    cp ${phome}/piton-runtime.yaml ${phome}/EverestSplash
  '';

  dontAutoPatchelf = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  dontStrip = true;

  dotnet-sdk =
    with dotnetCorePackages;
    sdk_9_0
    // {
      inherit
        (combinePackages [
          sdk_9_0
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };

  # Workaround from https://github.com/NixOS/nixpkgs/issues/454432
  # Necessitated by https://github.com/MonoMod/MonoMod/pull/246
  dotnetRestoreFlags = [ "--force-evaluate" ];
  # Microsoft.NET.Sdk complains: The process cannot access the file xxx because it is being used by another process.
  enableParallelBuilding = false;
  executables = [ ];
  installPath = builtins.replaceStrings [ "$out" ] [ (placeholder "out") ] phome;
  # Needed for ILAsm projects: https://github.com/NixOS/nixpkgs/issues/370754#issuecomment-2571475814
  linkNugetPackages = true;
  nugetDeps = ./deps.json;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Celeste mod loader (don't install; use celestegame instead)";
    homepage = "https://everestapi.github.io";
    license = with lib.licenses; [ mit ];

    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      fromSource
    ];

    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = [ "x86_64-linux" ];
  };
}
