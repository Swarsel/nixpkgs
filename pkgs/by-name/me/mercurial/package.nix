{
  lib,
  stdenv,
  fetchurl,
  cacert,
  cargo,
  gettext,
  git,
  gnupg,
  installShellFiles,
  makeWrapper,
  python3Packages,
  # test dependencies
  runCommand,
  rustPlatform,
  rustc,
  sqlite,
  tk,
  unzip,
  which,
  fullBuild ? false,
  gitSupport ? fullBuild,
  guiSupport ? fullBuild,
  highlightSupport ? fullBuild,
  re2Support ? true,
  rustSupport ? stdenv.hostPlatform.isLinux,
}:

let
  inherit (python3Packages)
    docutils
    python
    google-re2
    pygit2
    pygments
    setuptools
    setuptools-scm
    pip
    ;

  self = python3Packages.buildPythonApplication rec {
    pname = "mercurial${lib.optionalString fullBuild "-full"}";
    version = "7.2.2";

    src = fetchurl {
      url = "https://mercurial-scm.org/release/mercurial-${version}.tar.gz";
      hash = "sha256-8uyOfu7wUAWRcG03RVXwzrEYgiBo51+jsyvgfdIYT2w=";
    };

    nativeBuildInputs = [
      makeWrapper
      gettext
      installShellFiles
      setuptools
      setuptools-scm
      pip
    ]
    ++ lib.optionals rustSupport [
      rustPlatform.cargoSetupHook
      cargo
      rustc
    ];

    buildInputs = [ docutils ];

    propagatedBuildInputs =
      lib.optional re2Support google-re2
      ++ lib.optional gitSupport pygit2
      ++ lib.optional highlightSupport pygments;

    makeFlags = [ "PREFIX=$(out)" ] ++ lib.optional rustSupport "PURE=--rust";
    # enable building with Python 3.14
    # FIXME remove once PyO3 is updated in Cargo.lock
    env.PYO3_USE_ABI3_FORWARD_COMPATIBILITY = 1;

    postInstall =
      (lib.optionalString guiSupport ''
        mkdir -p $out/etc/mercurial
        cp contrib/hgk $out/bin
        cat >> $out/etc/mercurial/hgrc << EOF
        [extensions]
        hgk=$out/${python.sitePackages}/hgext/hgk.py
        EOF
        # setting HG so that hgk can be run itself as well (not only hg view)
        WRAP_TK=" --set TK_LIBRARY ${tk}/lib/${tk.libPrefix}
                  --set HG $out/bin/hg
                  --prefix PATH : ${tk}/bin "
      '')
      + ''
        for i in $(cd $out/bin && ls); do
          wrapProgram $out/bin/$i \
            $WRAP_TK
        done

        # copy hgweb.cgi to allow use in apache
        mkdir -p $out/share/cgi-bin
        cp -v hgweb.cgi contrib/hgweb.wsgi $out/share/cgi-bin
        chmod u+x $out/share/cgi-bin/hgweb.cgi

        installShellCompletion --cmd hg \
          --bash contrib/bash_completion \
          --zsh contrib/zsh_completion
      '';

    cargoDeps =
      if rustSupport then
        rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-OGsHK3Bh47V4n+7HYpVp/jymCz1QY45rkWlAW0Hob7g=";
          name = "mercurial-${version}";
          sourceRoot = "mercurial-${version}/rust";
        }
      else
        null;

    cargoRoot = if rustSupport then "rust" else null;
    pyproject = false;
    passthru = { inherit python; }; # pass it so that the same version can be used in hg2git

    passthru.tests = {
      mercurial-tests = makeTests { flags = "--with-hg=$MERCURIAL_BASE/bin/hg"; };
    };

    meta = {
      description = "Fast, lightweight SCM system for very large distributed projects";
      homepage = "https://www.mercurial-scm.org";
      changelog = "https://wiki.mercurial-scm.org/Release${lib.versions.majorMinor version}";
      license = lib.licenses.gpl2Plus;

      maintainers = with lib.maintainers; [
        lukegb
        euxane
        techknowlogick
      ];

      platforms = lib.platforms.unix;
      mainProgram = "hg";
      downloadPage = "https://www.mercurial-scm.org/release/";
    };
  };

  makeTests =
    {
      flags ? "",
      mercurial ? self,
      nameSuffix ? "",
    }:
    runCommand "${mercurial.pname}${nameSuffix}-tests"
      {
        inherit (mercurial) src;

        postPatch = ''
          patchShebangs .

          for f in **/*.{py,c,t}; do
            # not only used in shebangs
            substituteAllInPlace "$f" '/bin/sh' '${stdenv.shell}'
          done

          for f in **/*.t; do
            substituteInPlace 2>/dev/null "$f" \
              --replace '*/hg:' '*/*hg*:' \${
                # paths emitted by our wrapped hg look like ..hg-wrapped-wrapped
                ""
              }
              --replace '"$PYTHON" "$BINDIR"/hg' '"$BINDIR"/hg' ${
                # 'hg' is a wrapper; don't run using python directly
                ""
              }
          done
        '';

        nativeBuildInputs = [
          python
          unzip
          which
          sqlite
          git
          gnupg
        ];

        # https://bz.mercurial-scm.org/show_bug.cgi?id=6887
        propagatedBuildInputs = [ setuptools ];
        MERCURIAL_BASE = mercurial;
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt"; # needed for git
        # This runs Mercurial _a lot_ of times.
        requiredSystemFeatures = [ "big-parallel" ];
        # Don't run tests if not-Linux or if cross-compiling.
        meta.broken = !stdenv.hostPlatform.isLinux || stdenv.buildPlatform != stdenv.hostPlatform;
      }
      ''
        addToSearchPathWithCustomDelimiter : PYTHONPATH "${mercurial}/${python.sitePackages}"

        unpackPhase
        cd "$sourceRoot"
        patchPhase

        cat << EOF > tests/blacklists/nix
        # tests enforcing "/usr/bin/env" shebangs, which are patched for nix
        test-run-tests.t
        test-check-shbang.t

        # unstable experimental/unsupported features
        # https://bz.mercurial-scm.org/show_bug.cgi?id=6633#c1
        test-git-interop.t

        # doesn't like the extra setlocale warnings emitted by our bash wrappers
        test-locale.t

        # Python 3.10-3.12 deprecation warning: asyncore
        # https://bz.mercurial-scm.org/show_bug.cgi?id=6727
        test-patchbomb-tls.t

        # Python 3.12 _lsprof module change, breaking profile test
        # https://bz.mercurial-scm.org/show_bug.cgi?id=6846
        test-profile.t

        # Python 3.12 deprecation warning: multi-threaded fork in worker.py
        # https://bz.mercurial-scm.org/show_bug.cgi?id=6892
        test-clone-stream.t
        test-clonebundles.t
        test-fix-topology.t
        test-fix.t
        test-persistent-nodemap.t
        test-profile.t
        test-simple-update.t

        EOF

        export HGTEST_REAL_HG="${mercurial}/bin/hg"
        # include tests for native components
        export HGMODULEPOLICY="rust+c"
        # extended timeout necessary for tests to pass on the busy CI workers
        export HGTESTFLAGS="--blacklist blacklists/nix --timeout 1800 -j$NIX_BUILD_CORES ${flags}"
        make check
        touch $out
      '';
in
self.overridePythonAttrs (origAttrs: {
  passthru = origAttrs.passthru // rec {
    tests = origAttrs.passthru.tests // {
      withExtensions = withExtensions (pm: [ pm.hg-evolve ]);
    };

    # withExtensions takes a function which takes the python packages set and
    # returns a list of extensions to install.
    #
    # for instance: mercurial.withExtension (pm: [ pm.hg-evolve ])
    withExtensions =
      f:
      let
        python = self.python;
        mercurialHighPrio =
          ps:
          (ps.toPythonModule self).overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 50;
            };
          });
        plugins = (f python.pkgs) ++ [ (mercurialHighPrio python.pkgs) ];
        env = python.withPackages (ps: plugins);
      in
      stdenv.mkDerivation {
        inherit (self) src version meta;
        pname = "${self.pname}-with-extensions";
        nativeBuildInputs = self.nativeBuildInputs;
        buildInputs = self.buildInputs ++ self.propagatedBuildInputs;
        doCheck = false;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin

          for bindir in ${lib.concatStringsSep " " (map (d: "${lib.getBin d}/bin") plugins)}; do
            for bin in $bindir/*; do
              ln -s ${env}/bin/$(basename $bin) $out/bin/
            done
          done

          ln -s ${self}/share $out/share

          runHook postInstall
        '';

        installCheckPhase = ''
          runHook preInstallCheck

          $out/bin/hg help >/dev/null || exit 1

          runHook postInstallCheck
        '';

        dontBuild = true;
        dontConfigure = true;
        dontPatch = true;
        dontUnpack = true;
      };
  };
})
