# Examples of using the docker tools to build packages.
#
# This file defines several docker images. In order to use an image,
# build its derivation with `nix-build`, and then load the result with
# `docker load`. For example:
#
#  $ nix-build '<nixpkgs>' -A dockerTools.examples.redis
#  $ docker load < result

{
  buildImage,
  buildImageWithNixDb,
  buildLayeredImage,
  pkgs,
  pkgsCross,
  pullImage,
  shadowSetup,
  streamNixShellImage,
}:

let
  nixosLib = import ../../../nixos/lib {
    # Experimental features need testing too, but there's no point in warning
    # about it, so we enable the feature flag.
    featureFlags.minimalModules = { };
  };
  evalMinimalConfig = module: nixosLib.evalModules { modules = [ module ]; };

  nonRootShadowSetup =
    {
      uid,
      user,
      gid ? uid,
    }:
    with pkgs;
    [
      (writeTextDir "etc/shadow" ''
        root:!x:::::::
        ${user}:!:::::::
      '')
      (writeTextDir "etc/passwd" ''
        root:x:0:0::/root:${runtimeShell}
        ${user}:x:${toString uid}:${toString gid}::/home/${user}:
      '')
      (writeTextDir "etc/group" ''
        root:x:0:
        ${user}:x:${toString gid}:
      '')
      (writeTextDir "etc/gshadow" ''
        root:x::
        ${user}:x::
      '')
    ];

  nginxArguments =
    let
      nginxPort = "80";
      nginxConf = pkgs.writeText "nginx.conf" ''
        user nginx nginx;
        daemon off;
        error_log /dev/stdout info;
        pid /dev/null;
        events {}
        http {
          access_log /dev/stdout;
          server {
            listen ${nginxPort};
            index index.html;
            location / {
              root ${nginxWebRoot};
            }
          }
        }
      '';
      nginxWebRoot = pkgs.writeTextDir "index.html" ''
        <html><body><h1>Hello from NGINX</h1></body></html>
      '';
    in
    {
      config = {
        Cmd = [
          "nginx"
          "-c"
          nginxConf
        ];

        ExposedPorts = {
          "${nginxPort}/tcp" = { };
        };
      };

      contents = [
        pkgs.nginx
      ]
      ++ nonRootShadowSetup {
        uid = 999;
        user = "nginx";
      };

      extraCommands = ''
        mkdir -p tmp/nginx_client_body

        # nginx still tries to read this directory even if error_log
        # directive is specifying another file :/
        mkdir -p var/log/nginx
      '';

      name = "nginx-container";
      tag = "latest";
      meta.description = "Basic nginx docker image example";
    };

in

rec {
  # 16. Create another layered image, for comparing layers with image 10.
  another-layered-image = pkgs.dockerTools.buildLayeredImage {
    config.Cmd = [ "${pkgs.hello}/bin/hello" ];
    name = "another-layered-image";
    tag = "latest";
  };

  # 1. basic example
  bash = buildImage {
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.bash ];
      pathsToLink = [ "/bin" ];
    };

    name = "bash";
    tag = "latest";
    meta.description = "Basic example image";
  };

  # buildLayeredImage without compression
  bashLayeredUncompressed = pkgs.dockerTools.buildLayeredImage {
    compressor = "none";
    contents = pkgs.bash;
    name = "bash-layered-uncompressed";
    tag = "latest";
  };

  # buildLayeredImage with non-root user
  bashLayeredWithUser = pkgs.dockerTools.buildLayeredImage {
    contents = [
      pkgs.bash
      pkgs.coreutils
    ]
    ++ nonRootShadowSetup {
      uid = 999;
      user = "somebody";
    };

    name = "bash-layered-with-user";
    tag = "latest";
  };

  # buildLayeredImage with zstd compression
  bashLayeredZstdCompressed = pkgs.dockerTools.buildLayeredImage {
    compressor = "zstd";
    contents = pkgs.bash;
    name = "bash-layered-zstd";
    tag = "latest";
  };

  # buildImage without explicit tag
  bashNoTag = pkgs.dockerTools.buildImage {
    # Not recommended. Use `buildEnv` between copy and packages to avoid file duplication.
    copyToRoot = pkgs.bash;
    name = "bash-no-tag";
  };

  # buildLayeredImage without explicit tag
  bashNoTagLayered = pkgs.dockerTools.buildLayeredImage {
    contents = pkgs.bash;
    name = "bash-no-tag-layered";
  };

  # streamLayeredImage without explicit tag
  bashNoTagStreamLayered = pkgs.dockerTools.streamLayeredImage {
    contents = pkgs.bash;
    name = "bash-no-tag-stream-layered";
  };

  bashUncompressed = pkgs.dockerTools.buildImage {
    compressor = "none";
    # Not recommended. Use `buildEnv` between copy and packages to avoid file duplication.
    copyToRoot = pkgs.bash;
    name = "bash-uncompressed";
    tag = "latest";
  };

  bashZstdCompressed = pkgs.dockerTools.buildImage {
    compressor = "zstd";
    # Not recommended. Use `buildEnv` between copy and packages to avoid file duplication.
    copyToRoot = pkgs.bash;
    name = "bash-zstd";
    tag = "latest";
  };

  build-image-with-architecture = buildImage {
    architecture = "arm64";

    # Not recommended. Use `buildEnv` between copy and packages to avoid file duplication.
    copyToRoot = [
      pkgs.bash
      ./test-dummy
    ];

    name = "build-image-with-architecture";
    tag = "latest";
  };

  build-image-with-path = buildImage {
    # Not recommended. Use `buildEnv` between copy and packages to avoid file duplication.
    copyToRoot = [
      pkgs.bash
      ./test-dummy
    ];

    name = "build-image-with-path";
    tag = "latest";
  };

  # 18. Create a layered image with more packages than max layers.
  # coreutils and hello are part of the same layer
  bulk-layer = pkgs.dockerTools.buildLayeredImage {
    contents = with pkgs; [
      coreutils
      hello
    ];

    maxLayers = 2;
    name = "bulk-layer";
    tag = "latest";
  };

  # basic example, with cross compilation
  cross =
    let
      # Cross compile for x86_64 if on aarch64
      crossPkgs =
        if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then
          pkgsCross.gnu64
        else
          pkgsCross.aarch64-multiplatform;
    in
    crossPkgs.dockerTools.buildImage {
      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = [ crossPkgs.hello ];
        pathsToLink = [ "/bin" ];
      };

      name = "hello-cross";
      tag = "latest";
    };

  # 5. example of multiple contents, emacs and vi happily coexisting
  editors = buildImage {
    copyToRoot = pkgs.buildEnv {
      name = "image-root";

      paths = [
        pkgs.coreutils
        pkgs.bash
        pkgs.emacs
        pkgs.vim
        pkgs.nano
      ];

      pathsToLink = [ "/bin" ];
    };

    name = "editors";
  };

  environmentVariables = pkgs.dockerTools.buildImage {
    config = {
      Env = [
        "FROM_CHILD=true"
        "LAST_LAYER=child"
      ];
    };

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.coreutils ];
      pathsToLink = [ "/bin" ];
    };

    fromImage = environmentVariablesParent;
    name = "child";
    tag = "latest";
  };

  environmentVariablesLayered = pkgs.dockerTools.buildLayeredImage {
    config = {
      Env = [
        "FROM_CHILD=true"
        "LAST_LAYER=child"
      ];
    };

    contents = [ pkgs.coreutils ];
    fromImage = environmentVariablesParent;
    name = "child";
    tag = "latest";
  };

  # 15. Environment variable inheritance.
  # Child image should inherit parents environment variables,
  # optionally overriding them.
  environmentVariablesParent = pkgs.dockerTools.buildImage {
    config = {
      Env = [
        "FROM_PARENT=true"
        "LAST_LAYER=parent"
      ];
    };

    name = "parent";
    tag = "latest";
  };

  etc =
    let
      inherit (pkgs) lib;
      nixosCore = (
        evalMinimalConfig (
          { config, ... }:
          {
            environment.etc."some-config-file" = {
              text = ''
                127.0.0.1 localhost
                ::1 localhost
              '';
              # For executables:
              # mode = "0755";
            };

            imports = [
              pkgs.pkgsModule
              ../../../nixos/modules/system/etc/etc.nix
            ];
          }
        )
      );
      etcCmd = pkgs.writeScript "etc-cmd" ''
        #!${pkgs.busybox}/bin/sh
        ${pkgs.busybox}/bin/cat /etc/some-config-file
      '';
    in
    pkgs.dockerTools.streamLayeredImage {
      config.Cmd = [ etcCmd ];
      enableFakechroot = true;

      fakeRootCommands = ''
        mkdir -p /etc
        ${nixosCore.config.system.build.etcActivationCommands}
      '';

      name = "etc";
      tag = "latest";
    };

  # Example export of the bash image
  exportBash = pkgs.dockerTools.exportImage { fromImage = bash; };

  # 21. Support files in the store on buildLayeredImage
  # See: https://github.com/NixOS/nixpkgs/pull/91084#issuecomment-653496223
  filesInStore = pkgs.dockerTools.buildLayeredImageWithNixDb {
    config = {
      Cmd = [ "myscript" ];
      # For some reason 'nix-store --verify' requires this environment variable
      Env = [ "USER=root" ];
    };

    contents = [
      pkgs.coreutils
      pkgs.nix
      (pkgs.writeScriptBin "myscript" ''
        #!${pkgs.runtimeShell}
        cat ${pkgs.writeText "somefile" "some data"}
      '')
    ];

    name = "file-in-store";
    tag = "latest";
  };

  helloOnRoot = pkgs.dockerTools.streamLayeredImage {
    config.Cmd = [ "hello" ];

    contents = [
      (pkgs.buildEnv {
        name = "hello-root";
        paths = [ pkgs.hello ];
      })
    ];

    name = "hello";
    tag = "latest";
  };

  helloOnRootNoStore = pkgs.dockerTools.streamLayeredImage {
    config.Cmd = [ "hello" ];

    contents = [
      (pkgs.buildEnv {
        name = "hello-root";
        paths = [ pkgs.hello ];
      })
    ];

    includeStorePaths = false;
    name = "hello";
    tag = "latest";
  };

  helloOnRootNoStoreFakechroot = pkgs.dockerTools.streamLayeredImage {
    config.Cmd = [ "hello" ];

    contents = [
      (pkgs.buildEnv {
        name = "hello-root";
        paths = [ pkgs.hello ];
      })
    ];

    enableFakechroot = true;
    includeStorePaths = false;
    name = "hello";
    tag = "latest";
  };

  # ensure that caCertificates builds
  image-with-certs = buildImage {
    config = {
    };

    copyToRoot = pkgs.buildEnv {
      name = "image-with-certs-root";

      paths = [
        pkgs.coreutils
        pkgs.dockerTools.caCertificates
      ];
    };

    name = "image-with-certs";
    tag = "latest";
  };

  imageViaFakeChroot = pkgs.dockerTools.streamLayeredImage {
    config.Cmd = [ "hello" ];
    enableFakechroot = true;

    # Crucially, instead of a relative path, this creates /bin, which is
    # intercepted by fakechroot.
    # This functionality is not available on darwin as of 2021.
    fakeRootCommands = ''
      mkdir /bin
      ln -s ${pkgs.hello}/bin/hello /bin/hello
    '';

    name = "image-via-fake-chroot";
    tag = "latest";
  };

  # 19. Create a layered image with a base image and more packages than max
  # layers. coreutils and hello are part of the same layer
  layered-bulk-layer = pkgs.dockerTools.buildLayeredImage {
    contents = with pkgs; [
      coreutils
      hello
    ];

    fromImage = two-layered-image;
    maxLayers = 4;
    name = "layered-bulk-layer";
    tag = "latest";
  };

  # 10. Create a layered image
  layered-image = pkgs.dockerTools.buildLayeredImage {
    config.Cmd = [ "${pkgs.hello}/bin/hello" ];

    contents = [
      pkgs.hello
      pkgs.bash
      pkgs.coreutils
    ];

    extraCommands = ''echo "(extraCommand)" > extraCommands'';
    name = "layered-image";
    tag = "latest";
  };

  layered-image-with-architecture = pkgs.dockerTools.streamLayeredImage {
    architecture = "arm64";

    contents = [
      pkgs.bash
      ./test-dummy
    ];

    name = "layered-image-with-architecture";
    tag = "latest";
  };

  layered-image-with-path = pkgs.dockerTools.streamLayeredImage {
    contents = [
      pkgs.bash
      ./test-dummy
    ];

    name = "layered-image-with-path";
    tag = "latest";
  };

  # 11. Create an image on top of a layered image
  layered-on-top = pkgs.dockerTools.buildImage {
    config = {
      Cmd = [
        "${pkgs.bash}/bin/bash"
        "-c"
        "echo hello > foo; cat foo"
      ];

      Env = [ "PATH=${pkgs.coreutils}/bin/" ];
      WorkingDir = "/example-output";
    };

    extraCommands = ''
      mkdir ./example-output
      chmod 777 ./example-output
    '';

    fromImage = layered-image;
    name = "layered-on-top";
    tag = "latest";
  };

  # 12 Create a layered image on top of a layered image
  layered-on-top-layered = pkgs.dockerTools.buildLayeredImage {
    config = {
      Cmd = [
        "${pkgs.bash}/bin/bash"
        "-c"
        "echo hello > foo; cat foo"
      ];

      Env = [ "PATH=${pkgs.coreutils}/bin/" ];
      WorkingDir = "/example-output";
    };

    extraCommands = ''
      mkdir ./example-output
      chmod 777 ./example-output
    '';

    fromImage = layered-image;
    name = "layered-on-top-layered";
    tag = "latest";
  };

  # layered image with files owned by a user other than root
  layeredImageWithFakeRootCommands = pkgs.dockerTools.buildLayeredImage {
    contents = [
      pkgs.pkgsStatic.busybox
    ];

    fakeRootCommands = ''
      mkdir -p ./home/alice
      chown 1000 ./home/alice
      ln -s ${
        pkgs.hello.overrideAttrs (
          finalAttrs: prevAttrs: {
            # A unique `hello` to make sure that it isn't included via another mechanism by accident.
            configureFlags = prevAttrs.configureFlags or [ ] ++ [
              "--program-prefix=layeredImageWithFakeRootCommands-"
            ];

            doCheck = false;
            versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

            meta = prevAttrs.meta // {
              mainProgram = "layeredImageWithFakeRootCommands-hello";
            };
          }
        )
      } ./hello
    '';

    name = "layered-image-with-fake-root-commands";
    tag = "latest";
  };

  # layered image where a store path is itself a symlink
  layeredStoreSymlink =
    let
      target = pkgs.writeTextDir "dir/target" "Content doesn't matter.";
      symlink = pkgs.runCommand "symlink" { } "ln -s ${target} $out";
    in
    pkgs.dockerTools.buildLayeredImage {
      contents = [
        pkgs.bash
        symlink
      ];

      name = "layeredstoresymlink";
      tag = "latest";
    }
    // {
      passthru = { inherit symlink; };
    };

  # 14. example of 3 layers images This image is used to verify the
  # order of layers is correct.
  # It allows to validate
  # - the layer of parent are below
  # - the order of parent layer is preserved at image build time
  #   (this is why there are 3 images)
  layersOrder =
    let
      l1 = pkgs.dockerTools.buildImage {
        extraCommands = ''
          mkdir -p tmp
          echo layer1 > tmp/layer1
          echo layer1 > tmp/layer2
          echo layer1 > tmp/layer3
        '';

        name = "l1";
        tag = "latest";
      };
      l2 = pkgs.dockerTools.buildImage {
        extraCommands = ''
          mkdir -p tmp
          echo layer2 > tmp/layer2
          echo layer2 > tmp/layer3
        '';

        fromImage = l1;
        name = "l2";
        tag = "latest";
      };
    in
    pkgs.dockerTools.buildImage {
      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = [ pkgs.coreutils ];
        pathsToLink = [ "/bin" ];
      };

      extraCommands = ''
        mkdir -p tmp
        echo layer3 > tmp/layer3
      '';

      fromImage = l2;
      name = "l3";
      tag = "latest";
    };

  # 23. Ensure that layers are unpacked in the correct order before the
  # runAsRoot script is executed.
  layersUnpackOrder =
    let
      layerOnTopOf =
        parent: layerName:
        pkgs.dockerTools.buildImage {
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ pkgs.coreutils ];
            pathsToLink = [ "/bin" ];
          };

          fromImage = parent;
          name = "layers-unpack-order-${layerName}";

          runAsRoot = ''
            #!${pkgs.runtimeShell}
            echo -n "${layerName}" >> /layer-order
          '';

          tag = "latest";
        };
      # When executing the runAsRoot script when building layer C, if layer B is
      # not unpacked on top of layer A, the contents of /layer-order will not be
      # "ABC".
      layerA = layerOnTopOf null "a";
      layerB = layerOnTopOf layerA "b";
      layerC = layerOnTopOf layerB "c";
    in
    layerC;

  mergeVaryingCompressor = pkgs.dockerTools.mergeImages [
    redis
    bashUncompressed
    bashZstdCompressed
  ];

  # tarball consisting of both bash and redis images
  mergedBashAndRedis = pkgs.dockerTools.mergeImages [
    bash
    redis
  ];

  # tarball consisting of bash and layered image with different owner of the
  # /home/alice directory
  mergedBashFakeRoot = pkgs.dockerTools.mergeImages [
    bash
    layeredImageWithFakeRootCommands
  ];

  # tarball consisting of bash (without tag) and redis images
  mergedBashNoTagAndRedis = pkgs.dockerTools.mergeImages [
    bashNoTag
    redis
  ];

  # 3. another service example
  nginx = buildLayeredImage nginxArguments;
  # Used to demonstrate how virtualisation.oci-containers.imageStream works
  nginxStream = pkgs.dockerTools.streamLayeredImage nginxArguments;

  # 6. nix example to play with the container nix store
  # docker run -it --rm nix nix-store -qR $(nix-build '<nixpkgs>' -A nix)
  nix = buildImageWithNixDb {
    config = {
      Env = [
        "NIX_PAGER=cat"
        # A user is required by nix
        # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
        "USER=nobody"
      ];
    };

    copyToRoot = pkgs.buildEnv {
      name = "image-root";

      paths = [
        # nix-store uses cat program to display results as specified by
        # the image env variable NIX_PAGER.
        pkgs.coreutils
        pkgs.nix
        pkgs.bash
      ];

      pathsToLink = [ "/bin" ];
    };

    name = "nix";
    tag = "latest";
    meta.description = "nix example to play with the container nix store";
  };

  nix-layered = pkgs.dockerTools.streamLayeredImage {
    config = {
      Env = [
        "NIX_PAGER=cat"
      ];
    };

    contents = [
      pkgs.nix
      pkgs.bash
    ];

    includeNixDB = true;
    name = "nix-layered";
    tag = "latest";
  };

  nix-shell-basic = streamNixShellImage {
    drv = pkgs.hello;
    name = "nix-shell-basic";
    tag = "latest";
  };

  nix-shell-build-derivation = streamNixShellImage {
    drv = pkgs.hello;
    name = "nix-shell-build-derivation";

    run = ''
      buildDerivation
      $out/bin/hello
    '';

    tag = "latest";
  };

  nix-shell-command = streamNixShellImage {
    command = ''
      case "$-" in
      *i*) echo This shell is interactive ;;
      *) echo This shell is not interactive ;;
      esac
    '';

    drv = pkgs.mkShell { };
    name = "nix-shell-command";
    tag = "latest";
  };

  nix-shell-hook = streamNixShellImage {
    drv = pkgs.mkShell {
      shellHook = ''
        echo "This is the shell hook!"
        exit
      '';
    };

    name = "nix-shell-hook";
    tag = "latest";
  };

  nix-shell-inputs = streamNixShellImage {
    command = ''
      hello
    '';

    drv = pkgs.mkShell {
      nativeBuildInputs = [
        pkgs.hello
      ];
    };

    name = "nix-shell-inputs";
    tag = "latest";
  };

  nix-shell-nonexistent-home = streamNixShellImage {
    drv = pkgs.mkShell { };
    homeDirectory = "/homeless-shelter";
    name = "nix-shell-nonexistent-home";

    run = ''
      if [[ "$HOME" != "$(eval "echo ~$(whoami)")" ]]; then
        echo "\$HOME ($HOME) is not the same as ~\$(whoami) ($(eval "echo ~$(whoami)"))"
        exit 1
      fi

      if -e $HOME; then
        echo "home directory exists"
        exit 1
      fi
      echo "home directory doesn't exist"
    '';

    tag = "latest";
  };

  nix-shell-pass-as-file = streamNixShellImage {
    command = ''
      cat "$strPath"
    '';

    drv = pkgs.mkShell {
      passAsFile = [ "str" ];
      str = "this is a string";
    };

    name = "nix-shell-pass-as-file";
    tag = "latest";
  };

  nix-shell-run = streamNixShellImage {
    drv = pkgs.mkShell { };
    name = "nix-shell-run";

    run = ''
      case "$-" in
      *i*) echo This shell is interactive ;;
      *) echo This shell is not interactive ;;
      esac
    '';

    tag = "latest";
  };

  nix-shell-writable-home = streamNixShellImage {
    drv = pkgs.mkShell { };
    name = "nix-shell-writable-home";

    run = ''
      if [[ "$HOME" != "$(eval "echo ~$(whoami)")" ]]; then
        echo "\$HOME ($HOME) is not the same as ~\$(whoami) ($(eval "echo ~$(whoami)"))"
        exit 1
      fi

      if ! touch $HOME/test-file; then
        echo "home directory is not writable"
        exit 1
      fi
      echo "home directory is writable"
    '';

    tag = "latest";
  };

  # 4. example of pulling an image. could be used as a base for other images
  nixFromDockerHub = pullImage {
    finalImageName = "nix";
    finalImageTag = "2.2.1";
    hash = "sha256-xxZ4UW6jRIVAzlVYA62awcopzcYNViDyh6q1yocF3KU=";
    imageDigest = "sha256:85299d86263a3059cf19f419f9d286cc9f06d3c13146a8ebbb21b3437f598357";
    imageName = "nixos/nix";
  };

  nixLayered = pkgs.dockerTools.buildLayeredImageWithNixDb {
    config = {
      Env = [
        "NIX_PAGER=cat"
        # A user is required by nix
        # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
        "USER=nobody"
      ];
    };

    contents = [
      # nix-store uses cat program to display results as specified by
      # the image env variable NIX_PAGER.
      pkgs.coreutils
      pkgs.nix
      pkgs.bash
    ];

    name = "nix-layered";
    tag = "latest";
  };

  # 20. Create a "layered" image without nix store layers. This is not
  # recommended, but can be useful for base images in rare cases.
  no-store-paths = pkgs.dockerTools.buildLayeredImage {
    extraCommands = ''
      # This removes sharing of busybox and is not recommended. We do this
      # to make the example suitable as a test case with working binaries.
      cp -r ${pkgs.pkgsStatic.busybox}/* .

      # This is a "build" dependency that will not appear in the image
      ${pkgs.hello}/bin/hello
    '';

    name = "no-store-paths";
    tag = "latest";
  };

  # 7. example of adding something on top of an image pull by our
  # dockerTools chain.
  onTopOfPulledImage = buildImage {
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.hello ];
      pathsToLink = [ "/bin" ];
    };

    fromImage = nixFromDockerHub;
    name = "onTopOfPulledImage";
    tag = "latest";
  };

  # image with registry/ prefix
  prefixedImage = pkgs.dockerTools.buildImage {
    config.Cmd = [ "${pkgs.hello}/bin/hello" ];
    name = "registry-1.docker.io/image";
    tag = "latest";
  };

  # layered image with registry/ prefix
  prefixedLayeredImage = pkgs.dockerTools.buildLayeredImage {
    config.Cmd = [ "${pkgs.hello}/bin/hello" ];
    name = "registry-1.docker.io/layered-image";
    tag = "latest";
  };

  # 2. service example, layered on another image
  redis = buildImage {
    config = {
      Cmd = [ "/bin/redis-server" ];

      Healthcheck = {
        Interval = 30000000000;
        Retries = 3;

        Test = [
          "CMD-SHELL"
          "/bin/healthcheck"
        ];

        Timeout = 10000000000;
      };

      Volumes = {
        "/data" = { };
      };

      WorkingDir = "/data";
    };

    # fromImage = debian;
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.redis ];
      pathsToLink = [ "/bin" ];
    };

    # for example's sake, we can layer redis on top of bash or debian
    fromImage = bash;
    name = "redis";

    runAsRoot = ''
      mkdir -p /data
      cat >/bin/healthcheck <<-'EOF'
      set -x
      probe="$(/bin/redis-cli ping)"
      echo "$probe"
      if [ "$probe" = 'PONG' ]; then
        exit 0
      fi
      exit 1
      EOF
      chmod +x /bin/healthcheck
    '';

    tag = "latest";
    meta.description = "Service example, layered on another image";
  };

  # 8. regression test for erroneous use of eval and string expansion.
  # See issue #34779 and PR #40947 for details.
  runAsRootExtraCommands = pkgs.dockerTools.buildImage {
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.coreutils ];
      pathsToLink = [ "/bin" ];
    };

    extraCommands = ''echo "(extraCommand)" > extraCommands'';
    name = "runAsRootExtraCommands";
    # The parens here are to create problematic bash to embed and eval. In case
    # this is *embedded* into the script (with nix expansion) the initial quotes
    # will close the string and the following parens are unexpected
    runAsRoot = ''echo "(runAsRoot)" > runAsRoot'';
    tag = "latest";
  };

  # 13. example of running something as root on top of a parent image
  # Regression test related to PR #52109
  runAsRootParentImage = buildImage {
    fromImage = bash;
    name = "runAsRootParentImage";
    runAsRoot = "touch /example-file";
    tag = "latest";
  };

  # Same example, but re-fetches every time the fetcher implementation changes.
  # NOTE: Only use this for testing, or you'd be wasting a lot of time, network and space.
  testNixFromDockerHub = pkgs.testers.invalidateFetcherByDrvHash pullImage {
    finalImageName = "nix";
    finalImageTag = "2.2.1";
    hash = "sha256-xxZ4UW6jRIVAzlVYA62awcopzcYNViDyh6q1yocF3KU=";
    imageDigest = "sha256:85299d86263a3059cf19f419f9d286cc9f06d3c13146a8ebbb21b3437f598357";
    imageName = "nixos/nix";
  };

  # 17. Create a layered image with only 2 layers
  two-layered-image = pkgs.dockerTools.buildLayeredImage {
    config.Cmd = [ "${pkgs.hello}/bin/hello" ];

    contents = [
      pkgs.bash
      pkgs.hello
    ];

    maxLayers = 2;
    name = "two-layered-image";
    tag = "latest";
  };

  # 9. Ensure that setting created to now results in a date which
  # isn't the epoch + 1
  unstableDate = pkgs.dockerTools.buildImage {
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.coreutils ];
      pathsToLink = [ "/bin" ];
    };

    created = "now";
    name = "unstable-date";
    tag = "latest";
  };

  # 22. Ensure that setting created to now results in a date which
  # isn't the epoch + 1 for layered images.
  unstableDateLayered = pkgs.dockerTools.buildLayeredImage {
    contents = [ pkgs.coreutils ];
    created = "now";
    name = "unstable-date-layered";
    tag = "latest";
  };

}
