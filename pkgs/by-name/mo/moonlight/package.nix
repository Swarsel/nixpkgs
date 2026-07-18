{
  lib,
  stdenv,
  fetchFromGitHub,
  discord,
  discord-canary,
  discord-development,
  discord-ptb,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "moonlight";
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "moonlight-mod";
    repo = "moonlight";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c6F/HGxdpNeKYFwaeyQsa4rtfXnd++Xa3hIdgN2oPwA=";
  };

  patches = [
    ./disable_updates.patch
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  env = {
    MOONLIGHT_BRANCH = "stable";
    MOONLIGHT_VERSION = "v${finalAttrs.version} (nixpkgs)";
    NODE_ENV = "production";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-+jxp3dD/SyGdskMyw0jhDzDRj7wXD4Egkx3ok3cMiyc=";
  };

  passthru = {
    tests = lib.genAttrs' [ discord discord-ptb discord-canary discord-development ] (
      p: lib.nameValuePair p.pname p.tests.withMoonlight
    );

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Discord client modification, focused on enhancing user and developer experience";

    longDescription = ''
      Moonlight is a ***passion project***—yet another Discord client mod—focused on providing a decent user
      and developer experience. Heavily inspired by hh3 (a private client mod) and the projects before it, namely EndPwn.
      All core code is original or used with permission from their respective authors where not copyleft.
    '';

    homepage = "https://moonlight-mod.github.io";
    changelog = "https://raw.githubusercontent.com/moonlight-mod/moonlight/refs/tags/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      ilys
      _4evy
      isabelroses
    ];

    downloadPage = "https://moonlight-mod.github.io/using/install/#nix";
  };
})
