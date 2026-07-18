{
  lib,
  fetchFromGitHub,
  beam27Packages,
  esbuild,
  fetchPnpmDeps,
  gitMinimal,
  nixosTests,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
  tailwindcss_3,
  mixReleaseName ? "domain", # "domain" "web" or "api"
}:
beam27Packages.mixRelease rec {
  inherit mixReleaseName;
  pname = "firezone-server-${mixReleaseName}";
  version = "0-unstable-2025-08-31";

  src = "${
    fetchFromGitHub {
      owner = "firezone";
      repo = "firezone";
      rev = "f86719db19b848ab757995361032c1f2b7927d13";
      hash = "sha256-MrW+mnVMi3mOwkcWDsY84rVBaX1qJPmqkecdH8I2ng0=";

      # This is necessary to allow sending mails via SMTP, as the default
      # SMTP adapter is current broken: https://github.com/swoosh/swoosh/issues/785
      postFetch = ''
        ${lib.getExe gitMinimal} -C $out apply ${./0000-add-mua.patch}
      '';
    }
  }/elixir";

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_9
    nodejs
  ];

  preBuild = ''
    cat >> config/config.exs <<EOF
    config :tailwind, path: "${lib.getExe tailwindcss_3}"
    config :esbuild, path: "${lib.getExe esbuild}"
    EOF

    cat >> config/runtime.exs <<EOF
    config :tzdata, :data_dir, System.fetch_env!("TZDATA_DIR")
    EOF
  '';

  postBuild = ''
    pushd apps/web
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
    mix do deps.loadpaths --no-deps-check, phx.digest priv/static
    popd
  '';

  mixFodDeps = beam27Packages.fetchMixDeps {
    inherit src version;
    pname = "mix-deps-${pname}-${version}";
    hash = "sha256-h3l7HK9dxNmkHWfJyCOCXmCvFOK+mZtmszhRv0zxqoo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version;
    src = "${src}/apps/web/assets";
    fetcherVersion = 3;
    hash = "sha256-tB0y3T/dZBe8BHz7AV913zQ4oQu7VLyqHCnzBycNg18=";
    pnpm = pnpm_9;
  };

  pnpmRoot = "apps/web/assets";

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

    platforms = lib.platforms.linux;
    mainProgram = mixReleaseName;
  };
}
