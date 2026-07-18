{ lib, callPackage }:

let
  dockerGen =
    {
      # package dependencies
      stdenv,
      fetchFromGitHub,
      btrfs-progs,
      buildGoModule,
      cliHash,
      cliRev,
      containerd,
      containerdHash,
      containerdRev,
      docker-buildx,
      docker-compose,
      docker-init,
      docker-sbom,
      e2fsprogs,
      fuse-overlayfs,
      gitMinimal,
      glibc,
      go,
      go-md2man,
      installShellFiles,
      iproute2,
      iptables,
      libseccomp,
      libtool,
      lvm2,
      makeBinaryWrapper,
      mobyHash,
      mobyRev,
      nftables,
      nixosTests,
      pkg-config,
      procps,
      rootlesskit,
      runc,
      runcHash,
      runcRev,
      slirp4netns,
      sqlite,
      symlinkJoin,
      systemd,
      tini,
      tiniHash,
      tiniRev,
      util-linuxMinimal,
      version,
      versionCheckHook,
      xfsprogs,
      xz,
      buildxSupport ? true,
      clientOnly ? !stdenv.hostPlatform.isLinux,
      composeSupport ? true,
      initSupport ? false,
      knownVulnerabilities ? [ ],
      sbomSupport ? false,
      withBtrfs ? stdenv.hostPlatform.isLinux,
      withLvm ? stdenv.hostPlatform.isLinux,
      withSeccomp ? stdenv.hostPlatform.isLinux,
      withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
    }:
    let
      docker-meta = {
        identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "docker" version;
        license = lib.licenses.asl20;

        maintainers = with lib.maintainers; [
          vdemeester
          teutat3s
        ];
      };

      docker-runc = runc.overrideAttrs {
        inherit version;
        pname = "docker-runc";

        src = fetchFromGitHub {
          owner = "opencontainers";
          repo = "runc";
          tag = runcRev;
          hash = runcHash;
        };

        # docker/runc already include these patches / are not applicable
        patches = [ ];

        preBuild = ''
          substituteInPlace Makefile --replace-warn "/bin/bash" "${stdenv.shell}"
        '';
      };

      docker-containerd = containerd.overrideAttrs (oldAttrs: {
        inherit version;
        pname = "docker-containerd";

        src = fetchFromGitHub {
          owner = "containerd";
          repo = "containerd";
          tag = containerdRev;
          hash = containerdHash;
        };

        # We only need binaries
        outputs = [ "out" ];
        buildInputs = oldAttrs.buildInputs ++ lib.optionals withSeccomp [ libseccomp ];
        # See above
        installTargets = "install";
      });

      docker-tini = tini.overrideAttrs {
        inherit version;
        pname = "docker-tini";

        src = fetchFromGitHub {
          owner = "krallin";
          repo = "tini";
          rev = tiniRev;
          hash = tiniHash;
        };

        patches = [ ];
        # Do not remove static from make files as we want a static binary
        postPatch = "";

        buildInputs = [
          glibc
          glibc.static
        ];

        env.NIX_CFLAGS_COMPILE = "-DMINIMAL=ON";
      };

      moby-src = fetchFromGitHub {
        hash = mobyHash;
        owner = "moby";
        repo = "moby";
        tag = mobyRev;
      };

      moby = buildGoModule (
        lib.optionalAttrs stdenv.hostPlatform.isLinux {
          inherit version;
          pname = "moby";
          src = moby-src;

          postPatch = ''
            patchShebangs hack/make.sh hack/make/
          ''
          + lib.optionalString (lib.versionOlder version "29.0.0") ''
            patchShebangs hack/with-go-mod.sh
          '';

          nativeBuildInputs = [
            makeBinaryWrapper
            pkg-config
            go-md2man
            go
            libtool
            installShellFiles
          ];

          buildInputs = [
            sqlite
          ]
          ++ lib.optionals (lib.versionAtLeast version "29.0.0") [ nftables ]
          ++ lib.optionals withLvm [ lvm2 ]
          ++ lib.optionals withBtrfs [ btrfs-progs ]
          ++ lib.optionals withSystemd [ systemd ]
          ++ lib.optionals withSeccomp [ libseccomp ];

          vendorHash = null;

          env.DOCKER_BUILDTAGS = toString (
            lib.optionals withSystemd [ "journald" ]
            ++ lib.optionals (!withBtrfs) [ "exclude_graphdriver_btrfs" ]
            ++ lib.optionals (!withLvm) [ "exclude_graphdriver_devicemapper" ]
            ++ lib.optionals withSeccomp [ "seccomp" ]
          );

          buildPhase = ''
            runHook preBuild

            export GOCACHE="$TMPDIR/go-cache"
            # build engine
            export AUTO_GOPATH=1
            export DOCKER_GITCOMMIT="${cliRev}"
            export VERSION="${version}"
            ./hack/make.sh dynbinary

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            install -Dm755 ./bundles/dynbinary-daemon/dockerd $out/libexec/docker/dockerd
            install -Dm755 ./bundles/dynbinary-daemon/docker-proxy $out/libexec/docker/docker-proxy

            makeWrapper $out/libexec/docker/dockerd $out/bin/dockerd \
              --prefix PATH : "$out/libexec/docker:$extraPath"

            ln -s ${docker-containerd}/bin/containerd $out/libexec/docker/containerd
            ln -s ${docker-containerd}/bin/containerd-shim${lib.optionalString (lib.versionAtLeast version "29.0.0") "-runc-v2"} $out/libexec/docker/containerd-shim${lib.optionalString (lib.versionAtLeast version "29.0.0") "-runc-v2"}
            ln -s ${docker-runc}/bin/runc $out/libexec/docker/runc
            ln -s ${docker-tini}/bin/tini-static $out/libexec/docker/docker-init

            # systemd
            install -Dm644 ./contrib/init/systemd/docker.service $out/etc/systemd/system/docker.service
            substituteInPlace $out/etc/systemd/system/docker.service --replace-fail /usr/bin/dockerd $out/bin/dockerd
            install -Dm644 ./contrib/init/systemd/docker.socket $out/etc/systemd/system/docker.socket

            # rootless Docker
            install -Dm755 ./contrib/dockerd-rootless.sh $out/libexec/docker/dockerd-rootless.sh
            makeWrapper $out/libexec/docker/dockerd-rootless.sh $out/bin/dockerd-rootless \
              --prefix PATH : "$out/libexec/docker:$extraPath:$extraUserPath"

            runHook postInstall
          '';

          extraPath = lib.optionals stdenv.hostPlatform.isLinux (
            lib.makeBinPath [
              iproute2
              iptables
              e2fsprogs
              xz
              xfsprogs
              procps
              util-linuxMinimal
              gitMinimal
            ]
          );

          extraUserPath = lib.optionals (stdenv.hostPlatform.isLinux && !clientOnly) (
            lib.makeBinPath [
              rootlesskit
              slirp4netns
              fuse-overlayfs
            ]
          );

          meta = docker-meta // {
            description = "Collaborative project for the container ecosystem to assemble container-based systems";
            homepage = "https://mobyproject.org/";
            identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "mobyproject" version;
          };
        }
      );

      plugins =
        lib.optionals buildxSupport [ docker-buildx ]
        ++ lib.optionals composeSupport [ docker-compose ]
        ++ lib.optionals sbomSupport [ docker-sbom ]
        ++ lib.optionals initSupport [ docker-init ];

      dockerCliPluginsDirs = lib.strings.concatStringsSep ":" (
        map (p: "${p}/libexec/docker/cli-plugins") plugins
      );
    in
    buildGoModule (
      {
        inherit version;
        pname = "docker";

        src = fetchFromGitHub {
          owner = "docker";
          repo = "cli";
          # Cannot use `tag` since upstream forgot to tag release, see
          # https://github.com/docker/cli/issues/5789
          rev = cliRev;
          hash = cliHash;
        };

        outputs = [ "out" ];

        patches = [
          (
            if lib.versionOlder version "26.0.0" then
              ./cli-system-plugin-dir-from-env-25.patch
            else
              ./cli-system-plugin-dir-from-env.patch
          )
        ];

        postPatch = ''
          patchShebangs man scripts/build/
          substituteInPlace ./scripts/build/.variables --replace-fail "set -eu" ""
        '';

        nativeBuildInputs = [
          makeBinaryWrapper
          pkg-config
          go-md2man
          go
          libtool
          installShellFiles
        ];

        buildInputs =
          plugins
          ++ lib.optionals (stdenv.hostPlatform.isLinux) [
            glibc
            glibc.static
          ];

        vendorHash = null;

        # Keep eyes on BUILDTIME format - https://github.com/docker/cli/blob/${version}/scripts/build/.variables
        buildPhase = ''
          runHook preBuild

          export GOCACHE="$TMPDIR/go-cache"

          # Mimic AUTO_GOPATH
          mkdir -p .gopath/src/github.com/docker/
          ln -sf $PWD .gopath/src/github.com/docker/cli
          export GOPATH="$PWD/.gopath:$GOPATH"
          export GITCOMMIT="${cliRev}"
          export VERSION="${version}"
          export BUILDTIME="1970-01-01T00:00:00Z"
          make dynbinary

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          install -Dm755 ./build/docker $out/libexec/docker/docker

          makeWrapper $out/libexec/docker/docker $out/bin/docker \
            --prefix PATH : "$out/libexec/docker:$extraPath" \
            --prefix DOCKER_CLI_PLUGIN_DIRS : "${dockerCliPluginsDirs}"
        ''
        + lib.optionalString (!clientOnly) ''
          # symlink docker daemon to docker cli derivation
          ln -s ${moby}/bin/dockerd $out/bin/dockerd
          ln -s ${moby}/bin/dockerd-rootless $out/bin/dockerd-rootless

          # systemd
          mkdir -p $out/etc/systemd/system
          ln -s ${moby}/etc/systemd/system/docker.service $out/etc/systemd/system/docker.service
          ln -s ${moby}/etc/systemd/system/docker.socket $out/etc/systemd/system/docker.socket
        ''
        # Required to avoid breaking cross builds
        + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
          # completion (cli)
          installShellCompletion --cmd docker \
            --bash <($out/bin/docker completion bash) \
            --fish <($out/bin/docker completion fish) \
            --zsh <($out/bin/docker completion zsh)
        ''
        + ''
          runHook postInstall
        '';

        doInstallCheck = true;
        nativeInstallCheckInputs = [ versionCheckHook ];

        passthru = {
          # Exposed for tarsum build on non-linux systems (build-support/docker/default.nix)
          inherit moby-src;
          tests = lib.optionalAttrs (!clientOnly) { inherit (nixosTests) docker; };
          # run with: nix-shell ./maintainers/scripts/update.nix --argstr package docker
          updateScript = ./update.sh;
        };

        meta = docker-meta // {
          inherit knownVulnerabilities;
          description = "Open source project to pack, ship and run any application as a lightweight container";

          longDescription = ''
            Docker is a platform designed to help developers build, share, and run modern applications.

            To enable the docker daemon on NixOS, set the `virtualisation.docker.enable` option to `true`.
          '';

          homepage = "https://www.docker.com/";
          mainProgram = "docker";
        };
      }
      // lib.optionalAttrs (!clientOnly) {
        # allow overrides of docker components
        # TODO: move packages out of the let...in into top-level to allow proper overrides
        inherit
          docker-runc
          docker-containerd
          docker-tini
          moby
          ;
      }
    );
in
{
  # Get revisions from
  # https://github.com/moby/moby/tree/${mobyRev}/Dockerfile
  docker_25 =
    let
      version = "25.0.16";
    in
    callPackage dockerGen {
      inherit version;
      cliHash = "sha256-OwufdfuUPbPtgqfPeiKrQVkOOacU2g4ommHb770gV40=";
      # Upstream forgot to tag release
      # https://github.com/docker/cli/issues/5789
      cliRev = "43987fca488a535d810c429f75743d8c7b63bf4f";
      containerdHash = "sha256-H94EHnfW2Z59KcHcbfJn+BipyZiNUvHe50G5EXbrIps=";
      containerdRev = "v1.7.27";
      mobyHash = "sha256-St5yLoxo8QUTu7PjNcblS/EzZm98T189RPl1y+pAyHA=";
      mobyRev = "v${version}";
      runcHash = "sha256-J/QmOZxYnMPpzm87HhPTkYdt+fN+yeSUu2sv6aUeTY4=";
      runcRev = "v1.2.5";
      tiniHash = "sha256-jCBNfoJAjmcTJBx08kHs+FmbaU82CbQcf0IVjd56Nuw=";
      tiniRev = "369448a167e8b3da4ca5bca0b3307500c3371828";
    };

  docker_29 =
    let
      version = "29.6.1";
    in
    callPackage dockerGen {
      inherit version;
      cliHash = "sha256-cpK2UMRP/WXHsehG9Sq5UJAjhMesmXTrhe00y4RMRZc=";
      cliRev = "v${version}";
      containerdHash = "sha256-3ui+0AjEU6H4VHYwF3G85ggVMUdONCLJ5KfciFasmkk=";
      containerdRev = "v2.2.5";
      mobyHash = "sha256-gv+mea9X5TYDWN3IBRpmw0+R2waGxCiubdatNTeUQZI=";
      mobyRev = "docker-v${version}";
      runcHash = "sha256-cBMYZOElWHQ4OkF2NlYJSZrlW4833WD8CRJRkkXeKJc=";
      runcRev = "v1.3.6";
      tiniHash = "sha256-jCBNfoJAjmcTJBx08kHs+FmbaU82CbQcf0IVjd56Nuw=";
      tiniRev = "369448a167e8b3da4ca5bca0b3307500c3371828";
    };

}
