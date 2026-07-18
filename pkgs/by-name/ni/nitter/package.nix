{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  nixosTests,
  replaceVars,
  unstableGitUpdater,
}:

buildNimPackage (
  finalAttrs: prevAttrs: {
    pname = "nitter";
    version = "0-unstable-2026-06-16";

    src = fetchFromGitHub {
      owner = "zedeus";
      repo = "nitter";
      rev = "35882ed88d422b1355b66a1ff8c1144bffdc7bdf";
      hash = "sha256-U3FDhTZIcTDNKbSjrb0F9+Y5Q6GHLmGnmwXoZ5XfATc=";
    };

    patches = [
      (replaceVars ./nitter-version.patch {
        inherit (finalAttrs) version;
        inherit (finalAttrs.src) rev;
        url = builtins.replaceStrings [ "archive" ".tar.gz" ] [ "commit" "" ] finalAttrs.src.url;
      })
    ];

    postBuild = ''
      nim compile ${toString finalAttrs.nimFlags} -r tools/gencss
      nim compile ${toString finalAttrs.nimFlags} -r tools/rendermd
    '';

    postInstall = ''
      mkdir -p $out/share/nitter
      cp -r public $out/share/nitter/public
    '';

    lockFile = ./lock.json;

    passthru = {
      tests = { inherit (nixosTests) nitter; };
      updateScript = unstableGitUpdater { };
    };

    meta = {
      description = "Alternative Twitter front-end";
      homepage = "https://github.com/zedeus/nitter";
      license = lib.licenses.agpl3Only;

      maintainers = with lib.maintainers; [
        erdnaxe
        infinidoge
      ];

      mainProgram = "nitter";
    };
  }
)
