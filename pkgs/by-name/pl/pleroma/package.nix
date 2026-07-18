{
  lib,
  fetchFromGitHub,
  beam,
  cmake,
  fetchFromForgejo,
  fetchHex,
  fetchpatch,
  file,
  glib,
  nixosTests,
  pkg-config,
  vips,
  writeText,
}:

let
  beamPackages = beam.packages.erlang_27.extend (self: super: { elixir = self.elixir_1_18; });
in
beamPackages.mixRelease rec {
  pname = "pleroma";
  version = "2.10.2";

  src = fetchFromForgejo {
    owner = "pleroma";
    repo = "pleroma";
    rev = "v${version}";
    sha256 = "sha256-5BFzV2alNDjO/bS08+V4idzFaXQLr+4pNlLLXayBqIE=";
    domain = "git.pleroma.social";
  };

  patches = [ ./Revert-Config-Restrict-permissions-of-OTP-config.patch ];

  mixNixDeps = import ./mix.nix {
    inherit beamPackages lib;

    overrides = final: prev: {
      # mix2nix does not support git dependencies yet,
      # so we need to add them manually
      captcha = beamPackages.buildMix {
        version = "0.1.0";

        src = fetchFromForgejo {
          owner = "pleroma/elixir-libraries";
          repo = "elixir-captcha";
          rev = "e7b7cc34cc16b383461b966484c297e4ec9aeef6";
          sha256 = "sha256-gcsZ8BzmKfSeX2QsWDxQd34nKxIM0eJKBAaxxYyFSlg=";
          domain = "git.pleroma.social";
        };

        beamDeps = [ ];
        name = "captcha";
      };

      # This needs a different version (1.0.14 -> 1.0.18) to build properly with
      # our Erlang/OTP version.
      eimp = beamPackages.buildRebar3 rec {
        version = "1.0.18";

        src = beamPackages.fetchHex {
          inherit version;
          sha256 = "0fnx2pm1n2m0zs2skivv43s42hrgpq9i143p9mngw9f3swjqpxvx";
          pkg = name;
        };

        beamDeps = with final; [ p1_utils ];
        buildPlugins = with beamPackages; [ pc ];
        name = "eimp";

        patchPhase = ''
          echo '{plugins, [pc]}.' >> rebar.config
        '';
      };

      fast_html = prev.fast_html.override {
        nativeBuildInputs = [ cmake ];
        dontUseCmakeConfigure = true;
      };

      # Some additional build inputs and build fixes
      http_signatures = prev.http_signatures.override {
        patchPhase = ''
          substituteInPlace mix.exs --replace ":logger" ":logger, :public_key"
        '';
      };

      majic = prev.majic.override { buildInputs = [ file ]; };

      mime = prev.mime.override {
        patchPhase =
          let
            cfgFile = writeText "config.exs" ''
              use Mix.Config
              config :mime, :types, %{
                "application/activity+json" => ["activity+json"],
                "application/jrd+json" => ["jrd+json"],
                "application/ld+json" => ["activity+json"],
                "application/xml" => ["xml"],
                "application/xrd+xml" => ["xrd+xml"]
              }
            '';
          in
          ''
            mkdir config
            cp ${cfgFile} config/config.exs
          '';
      };

      # mochiweb is unused by still in mix.lock
      # work around OTP 27+ incompat by forcing our build to use a newer version
      mochiweb = prev.mochiweb.override rec {
        version = "3.3.0";

        src = fetchHex {
          sha256 = "sha256-qoW3d/sj6ZcuvEJOQLXTUQbxm8mYhz4Cbe3Ydt+O5Qw=";
          pkg = "mochiweb";
          version = "${version}";
        };
      };

      oban_plugins_lazarus = beamPackages.buildMix {
        version = "0.1.0";

        src = fetchFromForgejo {
          owner = "pleroma/elixir-libraries";
          repo = "oban_plugins_lazarus";
          rev = "e49fc355baaf0e435208bf5f534d31e26e897711";
          hash = "sha256-zSzPniRN7jQLAEGGOuwserDSLy2lSZ74NFMD/IOBsC8=";
          domain = "git.pleroma.social";
        };

        beamDeps = with final; [ oban ];
        name = "oban_plugins_lazarus";
      };

      oban_web = prev.oban_web.override {
        # This listener breaks with elixir 1.18.
        # It's only using for dev, let's remove it.
        postPatch = ''
          sed -i '/listeners: \[Phoenix.CodeReloader\]/d' mix.exs
        '';
      };

      # Required by eimp
      p1_utils = beamPackages.buildRebar3 rec {
        version = "1.0.18";

        src = fetchHex {
          inherit version;
          sha256 = "120znzz0yw1994nk6v28zql9plgapqpv51n9g6qm6md1f4x7gj0z";
          pkg = "${name}";
        };

        beamDeps = [ ];
        name = "p1_utils";
      };

      # Upstream is pointing to
      # https://github.com/feld/phoenix/commits/v1.7.14-websocket-headers/
      # which is v1.7.14 with an extra patch applied on top.
      phoenix = beamPackages.buildMix {
        version = "1.7.14-websocket-headers";

        src = fetchFromGitHub {
          owner = "phoenixframework";
          repo = "phoenix";
          tag = "v1.7.14";
          hash = "sha256-hb8k0bUl28re1Bv2AIs17VHOP8zIyCfbpaVydu1Dh24=";
        };

        patches = [
          (fetchpatch {
            hash = "sha256-eMla+D3EcVTc1WwlRaKvLPV5eXwGfAgZOxiYlGSkBIQ=";
            name = "0001-Support-passing-through-the-value-of-the-sec-websocket-protocol-header.patch";
            url = "https://github.com/feld/phoenix/commit/fb6dc76c657422e49600896c64aab4253fceaef6.patch";
          })
        ];

        beamDeps = with final; [
          phoenix_pubsub
          plug
          plug_crypto
          telemetry
          phoenix_template
          websock_adapter
          phoenix_view
          castore
          plug_cowboy
          jason
        ];

        name = "phoenix";
      };

      phoenix_live_view = prev.phoenix_live_view.override {
        # This listener breaks with elixir 1.18.
        # It's only using for dev, let's remove it.
        postPatch = ''
          sed -i '/listeners: \[Phoenix.CodeReloader\]/d' mix.exs
        '';
      };

      prometheus_ex = beamPackages.buildMix {
        version = "3.0.5";

        src = fetchFromGitHub {
          owner = "lanodan";
          repo = "prometheus.ex";
          rev = "31f7fbe4b71b79ba27efc2a5085746c4011ceb8f";
          hash = "sha256-2PZP+YnwnHt69HtIAQvjMBqBbfdbkRSoMzb1AL2Zsyc=";
        };

        beamDeps = with final; [ prometheus ];
        name = "prometheus_ex";
      };

      remote_ip = beamPackages.buildMix {
        version = "0.1.5";

        src = fetchFromForgejo {
          owner = "pleroma/elixir-libraries";
          repo = "remote_ip";
          rev = "b647d0deecaa3acb140854fe4bda5b7e1dc6d1c8";
          hash = "sha256-pgON0uhTPVeeAC866Qz24Jvm1okoAECAHJrRzqaq+zA=";
          domain = "git.pleroma.social";
        };

        beamDeps = with final; [
          combine
          plug
          inet_cidr
        ];

        name = "remote_ip";
      };

      syslog = prev.syslog.override { buildPlugins = with beamPackages; [ pc ]; };

      vix = prev.vix.override {
        nativeBuildInputs = [ pkg-config ];

        buildInputs = [
          vips
          glib.dev
        ];

        VIX_COMPILATION_MODE = "PLATFORM_PROVIDED_LIBVIPS";
      };
    };
  };

  passthru = {
    inherit mixNixDeps;
    tests.pleroma = nixosTests.pleroma;
  };

  meta = {
    description = "ActivityPub microblogging server";
    homepage = "https://git.pleroma.social/pleroma/pleroma";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      picnoir
      kloenk
    ];

    platforms = lib.platforms.unix;
  };
}
