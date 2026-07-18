{
  lib,
  stdenv,
  autoPatchelfHook,
  bash,
  curl,
  gcc,
  makeWrapper,
  platform,
  src,
  version,
  versionType,
  wrapRustc,
  zlib,
}:

let
  inherit (lib) optionalString;

  bootstrapping = versionType == "bootstrap";

  installComponents = "rustc,rust-std-${platform}" + (optionalString bootstrapping ",cargo");
in

rec {
  cargo = stdenv.mkDerivation {
    inherit version;
    inherit src;
    pname = "cargo-${versionType}";

    postPatch = ''
      patchShebangs .
    '';

    nativeBuildInputs = [
      makeWrapper
    ]
    ++ lib.optional (!stdenv.hostPlatform.isDarwin) autoPatchelfHook;

    buildInputs = [
      bash
    ]
    ++ lib.optional (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isFreeBSD) gcc.cc.lib;

    installPhase = ''
      patchShebangs ./install.sh
      ./install.sh --prefix=$out \
        --components=cargo
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install_name_tool -change "/usr/lib/libcurl.4.dylib" \
        "${lib.getLib curl}/lib/libcurl.4.dylib" "$out/bin/cargo"
    ''
    + ''
      wrapProgram "$out/bin/cargo" \
        --suffix PATH : "${rustc}/bin"
    '';

    meta = {
      description = "Rust package manager";
      homepage = "https://doc.rust-lang.org/cargo/";

      license = [
        lib.licenses.mit
        lib.licenses.asl20
      ];

      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ qknight ];
    };
  };

  rustc = wrapRustc rustc-unwrapped;

  rustc-unwrapped = stdenv.mkDerivation {
    inherit version;
    inherit src;
    pname = "rustc-${versionType}";

    postPatch = ''
      patchShebangs .
    '';

    nativeBuildInputs = lib.optional (!stdenv.hostPlatform.isDarwin) autoPatchelfHook;

    buildInputs = [
      bash
    ]
    ++ lib.optional (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isFreeBSD) gcc.cc.lib
    ++ lib.optional (!stdenv.hostPlatform.isDarwin) zlib;

    installPhase = ''
      ./install.sh --prefix=$out \
        --components=${installComponents}

      # Do NOT, I repeat, DO NOT use `wrapProgram` on $out/bin/rustc
      # (or similar) here. It causes strange effects where rustc loads
      # the wrong libraries in a bootstrap-build causing failures that
      # are very hard to track down. For details, see
      # https://github.com/rust-lang/rust/issues/34722#issuecomment-232164943
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install_name_tool -change "/usr/lib/libcurl.4.dylib" \
      "${lib.getLib curl}/lib/libcurl.4.dylib" "$out/bin/cargo"
    '';

    # The strip tool in cctools 973.0.1 and up appears to break rlibs in the
    # binaries. The lib.rmeta object inside the ar archive should contain an
    # .rmeta section, but it is removed. Luckily, this doesn't appear to be an
    # issue for Rust builds produced by Nix.
    dontStrip = true;
    setupHooks = ./setup-hook.sh;

    passthru = rec {
      badTargetPlatforms = [
        # Rust is currently unable to target the n32 ABI
        lib.systems.inspect.patterns.isMips64n32
      ];

      targetPlatforms = targetPlatformsWithHostTools ++ [
        # Platforms without host tools from
        # https://doc.rust-lang.org/nightly/rustc/platform-support.html
        "armv5tel-linux"
        "armv7a-linux"
        "m68k-linux"
        "mips-linux"
        "mips64-linux"
        "mipsel-linux"
        "mips64el-linux"
        "riscv32-linux"
        "armv6l-netbsd"
        "mipsel-netbsd"
        "riscv64-netbsd"
        "x86_64-redox"
        "wasm32-wasi"
      ];

      targetPlatformsWithHostTools = [
        # Platforms with host tools from
        # https://doc.rust-lang.org/nightly/rustc/platform-support.html
        "aarch64-darwin"
        "i686-freebsd"
        "x86_64-freebsd"
        "x86_64-solaris"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "i686-linux"
        "loongarch64-linux"
        "powerpc-linux"
        "powerpc64-linux"
        "powerpc64le-linux"
        "riscv64-linux"
        "s390x-linux"
        "x86_64-linux"
        "aarch64-netbsd"
        "armv7l-netbsd"
        "i686-netbsd"
        "powerpc-netbsd"
        "x86_64-netbsd"
        "i686-openbsd"
        "x86_64-openbsd"
        "i686-windows"
        "x86_64-windows"
      ];
    };

    meta = {
      description = "Safe, concurrent, practical language";
      homepage = "https://www.rust-lang.org/";

      license = [
        lib.licenses.mit
        lib.licenses.asl20
      ];

      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ qknight ];
      mainProgram = "rustc";
    };
  };
}
