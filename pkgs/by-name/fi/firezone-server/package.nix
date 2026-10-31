{
  lib,
  nixosTests,
  fetchFromGitHub,
  beam29Packages,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs_22,
  tailwindcss_4,
  esbuild,
}:
let
  # Upstream builds the portal with Elixir 1.20 on OTP 29, see elixir/.tool-versions
  beamPackages = beam29Packages.overrideScope (_: prev: { elixir = prev.elixir_1_20; });
in
beamPackages.mixRelease (finalAttrs: {
  pname = "firezone-server";
  version = "0-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    rev = "6cc4aea7123220786c374354cb70fff0e505be4e";
    hash = "sha256-b+TSp//Y7AJOrGW/fIA0vMZLDXP20XW1/xTQkfoWCFM=";
  };
  sourceRoot = "${finalAttrs.src.name}/elixir";

  patches = [
    # This is necessary to allow sending mails via SMTP, as the default
    # SMTP adapter is current broken: https://github.com/swoosh/swoosh/issues/785
    ./0000-add-mua.patch
  ];

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${finalAttrs.pname}-${finalAttrs.version}";
    inherit (finalAttrs)
      src
      version
      patches
      sourceRoot
      ;
    hash = "sha256-kphCmgzQaYcctZHofIdMBc1Q3WlbHI8FcbIy8R442J4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    sourceRoot = "${finalAttrs.src.name}/elixir/assets";
    fetcherVersion = 5;
    hash = "sha256-aW0WuY4SzBUKUedgO+OIahSb7s7rpcHF9NdRBwVvX2I=";
  };
  pnpmRoot = "assets";

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    nodejs_22
  ];

  mixReleaseName = "portal";

  preBuild = ''
    cat >> config/config.exs <<EOF
    config :tailwind, path: "${lib.getExe tailwindcss_4}"
    config :esbuild, path: "${lib.getExe esbuild}"
    EOF
  '';

  postBuild = ''
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
  '';

  passthru.tests = {
    inherit (nixosTests) firezone;
  };

  meta = {
    description = "Backend server for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];
    mainProgram = "portal";
    platforms = lib.platforms.linux;
  };
})
