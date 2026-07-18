/*
  ** To customize the enabled beets plugins, use the pluginOverrides input to the
  ** derivation.
  ** Examples:
  **
  ** Disabling a builtin plugin:
  ** python3.pkgs.beets.override {
  **   pluginOverrides = {
  **     beatport.enable = false;
  **   };
  ** }
  **
  ** Enabling an external plugin:
  ** python3.pkgs.beets.override {
  **   pluginOverrides = {
  **     alternatives = {
  **       enable = true;
  **       propagatedBuildInputs = [ beets-alternatives ];
  **     };
  **   };
  ** }
  **
  ** For an example adding a builtin plugin, see
  ** passthru.tests.with-new-builtin-plugin below
*/
{
  lib,
  stdenv,
  fetchFromGitHub,
  # plugin deps
  aacgain,
  # preCheck
  bashInteractive,
  beautifulsoup4,
  beets,
  buildPythonPackage,
  chromaprint,
  # dependencies
  confuse,
  diffPlugins,
  discogs-client,
  ffmpeg,
  flac,
  flask,
  flask-cors,
  # native
  gobject-introspection,
  gst-python,
  # buildInputs
  gst_all_1,
  imagemagick,
  jellyfish,
  keyfinder-cli,
  langdetect,
  lap,
  librosa,
  mediafile,
  mock,
  mp3gain,
  mp3val,
  munkres,
  musicbrainzngs,
  packaging,
  pillow,
  platformdirs,
  # build-system
  poetry-core,
  poetry-dynamic-versioning,
  pyacoustid,
  pylast,
  pytest-cov-stub,
  pytest-factoryboy,
  pytest-flask,
  # tests
  pytestCheckHook,
  python-mpd2,
  pyxdg,
  pyyaml,
  rarfile,
  reflink,
  requests,
  requests-mock,
  requests-oauthlib,
  requests-ratelimiter,
  resampy,
  responses,
  # passthru.tests
  runCommand,
  runtimeShell,
  soco,
  titlecase,
  tomli,
  typing-extensions,
  unidecode,
  writableTmpDirAsHomeHook,
  writeScript,
  disableAllPlugins ? false,
  extraDisabledTests ? [ ],
  extraNativeBuildInputs ? [ ],
  # configurations
  extraPatches ? [ ],
  pluginOverrides ? { },
}:

buildPythonPackage (finalAttrs: {
  pname = "beets";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "beetbox";
    repo = "beets";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u2qoZ0/qWq9YUcwbOpsqtIjX5BZ2z2wj00X59Pf+/fk=";
  };

  outputs = [
    "out"
  ];

  patches = extraPatches;

  nativeBuildInputs = [
    gobject-introspection
  ]
  ++ extraNativeBuildInputs;

  buildInputs = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
  ];

  nativeCheckInputs = [
    ffmpeg
    pytestCheckHook
    pytest-cov-stub
    pytest-factoryboy
    pytest-flask
    mock
    rarfile
    responses
    requests-mock
    pillow
    tomli
    writableTmpDirAsHomeHook
  ]
  ++ finalAttrs.finalPackage.passthru.plugins.wrapperBins;

  # Perform extra "sanity checks", before running pytest tests.
  preCheck = ''
    # Check for undefined plugins
    find beetsplug -mindepth 1 \
      \! -path 'beetsplug/__init__.py' -a \
      \( -name '*.py' -o -path 'beetsplug/*/__init__.py' \) -print \
      | sed -n -re 's|^beetsplug/([^/.]+).*|\1|p' \
      | sort -u > plugins_available
    ${diffPlugins (lib.attrNames finalAttrs.finalPackage.passthru.plugins.builtins) "plugins_available"}

    export BEETS_TEST_SHELL="${lib.getExe bashInteractive} --norc"

    env EDITOR="${writeScript "beetconfig.sh" ''
      #!${runtimeShell}
      cat > "$1" <<CFG
      plugins: ${lib.concatStringsSep " " (lib.attrNames finalAttrs.finalPackage.passthru.plugins.enabled)}
      CFG
    ''}" "$out/bin/beet" config -e
    env EDITOR=true "$out/bin/beet" config -e
  '';

  postInstall = ''
    mkdir -p $out/share/zsh/site-functions
    cp extra/_beet $out/share/zsh/site-functions/
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    confuse
    gst-python
    jellyfish
    mediafile
    munkres
    musicbrainzngs
    packaging
    platformdirs
    pyyaml
    unidecode
    # Can be built without it, but is useful on btrfs systems, and doesn't
    # add too much to the closure. See:
    # https://github.com/NixOS/nixpkgs/issues/437308
    reflink
    requests-ratelimiter
    typing-extensions
    lap
  ]
  ++ (lib.concatMap (p: p.propagatedBuildInputs) (
    lib.attrValues finalAttrs.finalPackage.passthru.plugins.enabled
  ));

  disabledTestPaths =
    finalAttrs.finalPackage.passthru.plugins.disabledTestPaths
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # Flaky: several tests fail randomly with:
      # if not self._poll(timeout):
      #   raise Empty
      #   _queue.Empty
      "test/plugins/test_bpd.py"
    ];

  disabledTests = extraDisabledTests ++ [
    # touches network
    "test_merge_duplicate_album"
    # The existence of the dependency reflink (see comment above), causes this
    # test to be run, and it fails in the sandbox.
    "test_successful_reflink"
  ];

  makeWrapperArgs = [
    "--set GI_TYPELIB_PATH \"$GI_TYPELIB_PATH\""
    "--set GST_PLUGIN_SYSTEM_PATH_1_0 \"$GST_PLUGIN_SYSTEM_PATH_1_0\""
    "--prefix PATH : ${lib.makeBinPath finalAttrs.finalPackage.passthru.plugins.wrapperBins}"
  ];

  pyproject = true;

  passthru = {
    plugins = {
      all =
        lib.mapAttrs
          (
            n: a:
            {
              propagatedBuildInputs = [ ];
              builtin = false;
              enable = !disableAllPlugins;
              name = n;
              testPaths = [ "test/plugins/test_${n}.py" ];
              wrapperBins = [ ];
            }
            // a
          )
          (
            lib.recursiveUpdate finalAttrs.finalPackage.passthru.plugins.base finalAttrs.finalPackage.passthru.plugins.overrides
          );

      base = lib.mapAttrs (
        _: a: { builtin = true; } // a
      ) finalAttrs.finalPackage.passthru.plugins.builtins;

      builtins = {
        _typing = {
          testPaths = [ ];
        };

        _utils = {
          testPaths = [ ];
        };

        absubmit = {
          deprecated = true;
          testPaths = [ ];
        };

        acousticbrainz = {
          propagatedBuildInputs = [ requests ];
          deprecated = true;
        };

        advancedrewrite = {
          testPaths = [ ];
        };

        albumtypes = { };

        aura = {
          propagatedBuildInputs = [
            flask
            flask-cors
            pillow
          ];
        };

        autobpm = {
          propagatedBuildInputs = [
            librosa
            # An optional dependency of librosa, needed for beets' autobpm
            resampy
          ];
        };

        badfiles = {
          testPaths = [ ];

          wrapperBins = [
            mp3val
            flac
          ];
        };

        bareasc = { };
        beatport.propagatedBuildInputs = [ requests-oauthlib ];
        bench.testPaths = [ ];
        bpd = { };
        bpm.testPaths = [ ];
        bpsync.testPaths = [ ];
        bucket = { };

        chroma = {
          propagatedBuildInputs = [ pyacoustid ];

          wrapperBins = [
            chromaprint
          ];
        };

        convert.wrapperBins = [ ffmpeg ];

        deezer = {
          propagatedBuildInputs = [ requests ];
          testPaths = [ ];
        };

        discogs.propagatedBuildInputs = [
          discogs-client
          requests
        ];

        duplicates.testPaths = [ ];
        edit = { };

        embedart = {
          propagatedBuildInputs = [ pillow ];
          wrapperBins = [ imagemagick ];
        };

        embyupdate.propagatedBuildInputs = [ requests ];
        export = { };

        fetchart = {
          propagatedBuildInputs = [
            beautifulsoup4
            langdetect
            pillow
            requests
          ];

          wrapperBins = [ imagemagick ];
        };

        filefilter = { };
        fish.testPaths = [ ];
        freedesktop.testPaths = [ ];
        fromfilename.testPaths = [ ];
        ftintitle = { };
        fuzzy.testPaths = [ ];
        hook = { };
        ihate = { };
        importadded = { };
        importfeeds = { };
        importsource = { };
        info = { };
        inline.testPaths = [ ];
        ipfs = { };
        keyfinder.wrapperBins = [ keyfinder-cli ];

        kodiupdate = {
          propagatedBuildInputs = [ requests ];
          testPaths = [ ];
        };

        lastgenre.propagatedBuildInputs = [ pylast ];

        lastimport = {
          propagatedBuildInputs = [ pylast ];
          testPaths = [ ];
        };

        limit = { };
        listenbrainz = { };

        loadext = {
          propagatedBuildInputs = [ requests ];
          testPaths = [ ];
        };

        lyrics.propagatedBuildInputs = [
          beautifulsoup4
          langdetect
          requests
        ];

        mbcollection.testPaths = [ ];
        mbpseudo = { };
        mbsubmit = { };
        mbsync = { };
        metasync.testPaths = [ ];
        missing.testPaths = [ ];
        mpdstats.propagatedBuildInputs = [ python-mpd2 ];

        mpdupdate = {
          propagatedBuildInputs = [ python-mpd2 ];
          testPaths = [ ];
        };

        musicbrainz = { };
        parentwork = { };
        permissions = { };
        play = { };
        playlist.propagatedBuildInputs = [ requests ];
        plexupdate = { };
        random = { };
        replace = { };

        replaygain.wrapperBins = [
          aacgain
          ffmpeg
          mp3gain
        ];

        rewrite.testPaths = [ ];
        scrub.testPaths = [ ];
        smartplaylist = { };

        sonosupdate = {
          propagatedBuildInputs = [ soco ];
          testPaths = [ ];
        };

        spotify = { };

        subsonicplaylist = {
          propagatedBuildInputs = [ requests ];
          testPaths = [ ];
        };

        subsonicupdate.propagatedBuildInputs = [ requests ];

        substitute = {
          testPaths = [ ];
        };

        the = { };

        thumbnails = {
          propagatedBuildInputs = [
            pillow
            pyxdg
          ];

          wrapperBins = [ imagemagick ];
        };

        tidal = { };
        titlecase.propagatedBuildInputs = [ titlecase ];
        types.testPaths = [ "test/plugins/test_types_plugin.py" ];
        unimported.testPaths = [ ];

        web.propagatedBuildInputs = [
          flask
          flask-cors
        ];

        zero = { };
      };

      disabled = lib.filterAttrs (_: p: !p.enable) finalAttrs.finalPackage.passthru.plugins.all;

      disabledTestPaths = lib.flatten (
        lib.attrValues (lib.mapAttrs (_: v: v.testPaths) finalAttrs.finalPackage.passthru.plugins.disabled)
      );

      enabled = lib.filterAttrs (_: p: p.enable) finalAttrs.finalPackage.passthru.plugins.all;

      overrides = lib.mapAttrs (
        plugName:
        lib.throwIf (finalAttrs.finalPackage.passthru.plugins.builtins.${plugName}.deprecated or false)
          "beets evaluation error: Plugin ${plugName} was enabled in pluginOverrides, but it has been removed. Remove the override to fix evaluation."
      ) pluginOverrides;

      wrapperBins = lib.concatMap (p: p.wrapperBins) (
        lib.attrValues finalAttrs.finalPackage.passthru.plugins.enabled
      );
    };

    tests = {
      gstreamer =
        runCommand "beets-gstreamer-test"
          {
            meta.timeout = 60;
          }
          ''
            set -euo pipefail
            export HOME=$(mktemp -d)
            mkdir $out

            cat << EOF > $out/config.yaml
            replaygain:
              backend: gstreamer
            EOF

            ${finalAttrs.finalPackage}/bin/beet -c $out/config.yaml > /dev/null
          '';

      mpd-plugins-really-disabled = runCommand "beets-mpd-plugins-disabled-test" { } ''
        set -euo pipefail
        export HOME=$(mktemp -d)
        mkdir $out

        cat << EOF > $out/config.yaml
        plugins:
          - mpdstats
        EOF
        ${finalAttrs.finalPackage.passthru.tests.with-mpd-plugins-disabled}/bin/beet \
          -c $out/config.yaml \
          --help 2> $out/help-stderr || true
        ${finalAttrs.finalPackage.passthru.tests.with-mpd-plugins-disabled}/bin/beet \
          -c $out/config.yaml \
          mpdstats --help 2> $out/mpdstats-help-stderr || true
      '';

      # Test that disabling
      with-mpd-plugins-disabled = beets.override {
        pluginOverrides = {
          # These two plugins require mpd2 Python dependency. If they are
          # disabled, this dependency shouldn't be pulled, and the `runCommand`
          # test below should fail with a `ModuleNotFoundError`
          mpdstats.enable = false;
          mpdupdate.enable = false;
        };
      };

      with-new-builtin-plugin = finalAttrs.finalPackage.overrideAttrs (
        newAttrs: oldAttrs: {
          postPatch = (oldAttrs.postPatch or "") + ''
            mkdir -p beetsplug/my_special_plugin
            touch beetsplug/my_special_plugin/__init__.py
          '';

          passthru = lib.recursiveUpdate oldAttrs.passthru {
            plugins.builtins.my_special_plugin = { };
          };
        }
      );
    };
  };

  meta = {
    description = "Music tagger and library organizer";
    homepage = "https://beets.io";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      astratagem
      doronbehar
      lovesegfault
      pjones
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "beet";
  };
})
