{
  lib,
  fetchurl,
  callPackage,
  nugetPackageHook,
  patchNupkgs,
  stdenvNoCC,
  symlinkJoin,
  unzip,
  overrides ? callPackage ./overrides.nix { },
}:
lib.makeOverridable (
  {
    pname,
    version,
    hash ? "",
    installable ? false,
    sha256 ? "",
    url ? "https://www.nuget.org/api/v2/package/${pname}/${version}",
  }:
  let
    package = stdenvNoCC.mkDerivation rec {
      inherit pname version;

      src = fetchurl {
        # There is no need to verify whether both sha256 and hash are
        # valid here, because nuget-to-json does not generate a deps.nix
        # containing both.
        inherit
          url
          sha256
          hash
          version
          ;

        name = "${pname}.${version}.nupkg";
      };

      nativeBuildInputs = [
        unzip
        patchNupkgs
        nugetPackageHook
      ];

      installPhase = ''
        runHook preInstall

        dir=$out/share/nuget/packages/${lib.toLower pname}/${lib.toLower version}
        mkdir -p $dir
        cp -r . $dir
        createNupkgMetadata "$dir"

        runHook postInstall
      '';

      preFixup = ''
        patch-nupkgs $out/share/nuget/packages
      '';

      createInstallableNugetSource = installable;

      prePatch = ''
        shopt -s nullglob
        local dir
        for dir in tools runtimes/*/native; do
          [[ ! -d "$dir" ]] || chmod -R +x "$dir"
        done
        rm -rf .signature.p7s
      '';

      unpackPhase = ''
        runHook preUnpack

        unpackNupkg "$src" source
        cd source

        runHook postUnpack
      '';

      meta = {
        sourceProvenance = with lib.sourceTypes; [
          binaryBytecode
          binaryNativeCode
        ];
      };
    };
  in
  overrides.${pname} or lib.id package
)
