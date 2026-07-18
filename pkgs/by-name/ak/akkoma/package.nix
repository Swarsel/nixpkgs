{
  lib,
  beam_minimal,
  cmake,
  fetchFromGitea,
  file,
  nix-update-script,
  nixosTests,
}:

let
  beamPackages = beam_minimal.packages.erlang_27.extend (
    self: super: {
      elixir = self.elixir_1_17;

      rebar3 = self.rebar3WithPlugins {
        plugins = with self; [ pc ];
      };
    }
  );
in
beamPackages.mixRelease rec {
  pname = "akkoma";
  version = "3.19.0";

  src = fetchFromGitea {
    owner = "AkkomaGang";
    repo = "akkoma";
    tag = "v${version}";
    hash = "sha256-ASLnsmuWpfQKwpNNLUgI32Gdn/j+jUW5IBLlT8RUmcE=";
    domain = "akkoma.dev";
    # upstream repository archive fetching is broken
    forceFetchGit = true;
  };

  postPatch = ''
    # Remove dependency on OS_Mon
    sed -E -i 's/(^|\s):os_mon,//' \
      mix.exs
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ file ];

  postBuild = ''
    # Digest and compress static files
    rm -f priv/static/READ_THIS_BEFORE_TOUCHING_FILES_HERE
    mix do deps.loadpaths --no-deps-check, phx.digest --no-compile
  '';

  dontUseCmakeConfigure = true;

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit src version;
    pname = "mix-deps-akkoma";

    postInstall = ''
      substituteInPlace "$out/http_signatures/mix.exs" \
        --replace-fail ":logger" ":logger, :public_key"

      # Akkoma adds some things to the `mime` package's configuration, which
      # requires it to be recompiled. However, we can't just recompile things
      # like we would on other systems. Therefore, we need to add it to mime's
      # compile-time config too, and also in every package that depends on
      # mime, directly or indirectly. We take the lazy way out and just add it
      # to every dependency – it won't make a difference in packages that don't
      # depend on `mime`.
      for dep in "$out/"*; do
        mkdir -p "$dep/config"
        cat ${./mime.exs} >>"$dep/config/config.exs"
      done
    '';

    hash = "sha256-O9A7XuQSSczGMcLMc6Fk0eh7PkjQ6sYJKSwdqoEPJJI=";
  };

  passthru = {
    inherit mixFodDeps;
    # Used to make sure the service uses the same version of elixir as
    # the package
    elixirPackage = beamPackages.elixir;

    tests = with nixosTests; {
      inherit akkoma akkoma-confined;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "ActivityPub microblogging server";
    homepage = "https://akkoma.social";
    changelog = "https://akkoma.dev/AkkomaGang/akkoma/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.unix;
  };
}
