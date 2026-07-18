{ lib, pkgs }:

let
  inherit (lib) optionalString;

  inherit (pkgs)
    autoconf
    automake
    checkinstall
    clang-analyzer
    cov-build
    enableGCOVInstrumentation
    lcov
    libtool
    makeGCOVReport
    runCommand
    stdenv
    vmTools
    xz
    ;
in

rec {

  aggregate =
    {
      constituents,
      name,
      meta ? { },
    }:
    pkgs.runCommand name
      {
        inherit constituents meta;
        _hydraAggregate = true;
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/nix-support
        touch $out/nix-support/hydra-build-products
        echo $constituents > $out/nix-support/hydra-aggregate-constituents

        # Propagate build failures.
        for i in $constituents; do
          if [ -e $i/nix-support/failed ]; then
            touch $out/nix-support/failed
          fi
        done
      '';

  binaryTarball =
    args:
    import ./binary-tarball.nix (
      {
        inherit lib stdenv;
      }
      // args
    );

  /*
    Create a channel job which success depends on the success of all of
    its contituents. Channel jobs are a special type of jobs that are
    listed in the channel tab of Hydra and that can be subscribed.
    A tarball of the src attribute is distributed via the channel.

    - constituents: a list of derivations on which the channel success depends.
    - name: the channel name that will be used in the hydra interface.
    - src: should point to the root folder of the nix-expressions used by the
           channel, typically a folder containing a `default.nix`.

      channel {
        constituents = [ foo bar baz ];
        name = "my-channel";
        src = ./.;
      };
  */
  channel =
    {
      name,
      src,
      constituents ? [ ],
      isNixOS ? true,
      meta ? { },
      ...
    }@args:
    stdenv.mkDerivation (
      {
        installPhase = ''
          mkdir -p $out/{tarballs,nix-support}

          tar cJf "$out/tarballs/nixexprs.tar.xz" \
            --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC" \
            --transform='s!^\.!${name}!' .

          echo "channel - $out/tarballs/nixexprs.tar.xz" > "$out/nix-support/hydra-build-products"
          echo $constituents > "$out/nix-support/hydra-aggregate-constituents"

          # Propagate build failures.
          for i in $constituents; do
            if [ -e "$i/nix-support/failed" ]; then
              touch "$out/nix-support/failed"
            fi
          done
        '';

        _hydraAggregate = true;
        dontBuild = true;
        dontConfigure = true;

        patchPhase = optionalString isNixOS ''
          touch .update-on-nixos-rebuild
        '';

        preferLocalBuild = true;

        meta = meta // {
          isHydraChannel = true;
        };
      }
      // removeAttrs args [ "meta" ]
    );

  clangAnalysis =
    args:
    nixBuild (
      {
        inherit clang-analyzer;
        doClangAnalysis = true;
      }
      // args
    );

  coverageAnalysis =
    args:
    nixBuild (
      {
        inherit lcov enableGCOVInstrumentation makeGCOVReport;
        doCoverageAnalysis = true;
      }
      // args
    );

  coverityAnalysis =
    args:
    nixBuild (
      {
        inherit cov-build xz;
        doCoverityAnalysis = true;
      }
      // args
    );

  debBuild =
    args:
    import ./debian-build.nix (
      {
        inherit
          lib
          stdenv
          vmTools
          checkinstall
          ;
      }
      // args
    );

  makeSourceTarball = sourceTarball; # compatibility

  mvnBuild =
    args:
    import ./maven-build.nix (
      {
        inherit lib stdenv;
      }
      // args
    );

  nixBuild =
    args:
    import ./nix-build.nix (
      {
        inherit lib stdenv;
      }
      // args
    );

  rpmBuild =
    args:
    import ./rpm-build.nix (
      {
        inherit lib vmTools;
      }
      // args
    );

  sourceTarball =
    args:
    import ./source-tarball.nix (
      {
        inherit
          lib
          stdenv
          autoconf
          automake
          libtool
          ;
      }
      // args
    );

}
