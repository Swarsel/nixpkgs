{
  lib,
  stdenv,
  callPackage,
  fetchpatch2,
  gcc14Stdenv,
  gfortran14,
}:

let
  juliaWithPackages = callPackage ../../julia-modules { };

  wrapJulia =
    julia:
    julia.overrideAttrs (oldAttrs: {
      passthru = (oldAttrs.passthru or { }) // {
        withPackages = juliaWithPackages.override { inherit julia; };
      };
    });

in

{
  julia_110 = wrapJulia (
    callPackage
      (import ./generic.nix {
        version = "1.10.11";

        patches = [
          # Revert https://github.com/JuliaLang/julia/pull/55354
          # [build] Some improvements to the LLVM build system
          # Related: https://github.com/JuliaLang/julia/issues/55617
          (fetchpatch2 {
            hash = "sha256-gXC3LE3AuHMlSdA4dW+rbAhJpSB6ZMaz9X1qrHDPX7Y=";
            revert = true;
            url = "https://github.com/JuliaLang/julia/commit/0be37db8c5b5a440bd9a11960ae9c998027b7337.patch";
          })
        ];

        hash = "sha256-XItQngSzszyIGzSvqdXBV/yLQGDxf5x8SnrQ/DtzUtU=";
      })
      {
        gfortran = gfortran14;
        stdenv = gcc14Stdenv;
      }
  );

  julia_110-bin = wrapJulia (
    callPackage (import ./generic-bin.nix {
      version = "1.10.11";

      sha256 = {
        aarch64-darwin = "0nzh0zwjlagn4aglimyajmqv5m6qwdqz7lyjaszfxzyf1p0hcmxx";
        aarch64-linux = "1cn62bmrgz344zsml80rqpmryp8hk6bdni3zhh43lpqf8a0aj11h";
        x86_64-linux = "1grpvdzkh4b6mfdn1khbs1nz1b7q61rkzfip3q2x4330fjqwcjgv";
      };
    }) { }
  );

  julia_111 = wrapJulia (
    callPackage
      (import ./generic.nix {
        version = "1.11.9";
        hash = "sha256-SX5jIfJfxQQfP2P5sCGtglFn+GZlOIyHgnQ3qrr8GSI=";
      })
      {
        gfortran = gfortran14;
        stdenv = gcc14Stdenv;
      }
  );

  julia_111-bin = wrapJulia (
    callPackage (import ./generic-bin.nix {
      version = "1.11.9";

      sha256 = {
        aarch64-darwin = "1mrvycjlxs225sspdvvq4qbay1riyyjzqjs1d0xgqdkh6c6kv47d";
        aarch64-linux = "0gk2zxkwz2yyg3im23jpgaxzixchyywm19nbh51szmniah31y1x2";
        x86_64-linux = "0dfy4wlrz6jbs7kd9r0bjk9d6sqgf4fakrxrnzwfl1bsdlsn6qxk";
      };
    }) { }
  );

  julia_112 = wrapJulia (
    callPackage
      (import ./generic.nix {
        version = "1.12.6";

        patches = lib.optionals stdenv.hostPlatform.isDarwin [
          ./patches/1.12/0001-zlib-rpath.patch
          ./patches/1.12/0002-lbt-blas-detection.patch
        ];

        hash = "sha256-cR86qNbsXJAEWT6489U+NWTNdZrLqK1K2ulnr8IDMsw=";
      })
      (
        if stdenv.cc.isGNU then
          {
            gfortran = gfortran14;
            stdenv = gcc14Stdenv;
          }
        else
          { }
      )
  );

  julia_112-bin = wrapJulia (
    callPackage (import ./generic-bin.nix {
      version = "1.12.6";

      sha256 = {
        aarch64-darwin = "0cbarn632dxn1x1zi68k31plimvrr4yizr5kcc4rvagdsbxq4z97";
        aarch64-linux = "16a8gkaqzsxw5z8axdyp13qdlqxapg9q11csgxigs3xxayw976q2";
        x86_64-linux = "16h77px97qpzfcf5lfrj8kj8baq6fs07sxjasbdsj8cly6zg7axv";
      };
    }) { }
  );
}
