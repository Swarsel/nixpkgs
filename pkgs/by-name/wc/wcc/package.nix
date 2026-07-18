{
  lib,
  stdenv,
  fetchFromGitHub,
  capstone,
  cargo,
  fetchpatch2,
  libbfd,
  libelf,
  libiberty,
  readline,
  rustPlatform,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wcc";
  version = "0.0.11";

  src = fetchFromGitHub {
    owner = "endrazine";
    repo = "wcc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cg8rf8R3xYNJTJhrDfIdVAUR/OOd6JjB0NYHRosUzvU=";
    fetchSubmodules = true;
  };

  patches = [
    # The upstream forgot to bump WVERSION in header before tagging `v0.0.11`.
    (fetchpatch2 {
      hash = "sha256-RK0ue8hdK/G+njwGmWpaewclRHprO8aBdZ9vBGQIQOc=";
      url = "https://github.com/endrazine/wcc/commit/4bea2dac8b49d82e4f72e42027d74fc654380f7b.patch?full_index=1";
    })
    # Fix build with gcc 15: function pointer requires explicit arguments
    (fetchpatch2 {
      hash = "sha256-7RsU3XJvJ2gvNsB1O/pvOrmd+3/wNfoOZj0JVlgJA8o=";
      url = "https://github.com/endrazine/wcc/commit/3dfd28cb53b4766032e1113cf508bf2f5dce87d5.patch?full_index=1";
    })
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    sed -i src/wsh/include/libwitch/wsh.h src/wsh/scripts/INDEX \
      -e "s#/usr/share/wcc#$out/share/wcc#"

    sed -i -e '/stropts.h>/d' src/wsh/include/libwitch/wsh.h

    sed -i '/wsh-static/d' src/wsh/Makefile
  '';

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    capstone
    libbfd
    libelf
    libiberty
    readline
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  preInstall = ''
    mkdir -p $out/usr/bin $out/lib/x86_64-linux-gnu
  '';

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
    mkdir -p $out/share/man/man1
    cp doc/manpages/*.1 $out/share/man/man1/
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = ''
    # not detected by patchShebangs
    substituteInPlace $out/bin/wcch --replace-fail '#!/usr/bin/wsh' "#!$out/bin/wsh"
  '';

  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  enableParallelBuilding = true;
  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Witchcraft compiler collection: tools to convert and script ELF files";
    homepage = "https://github.com/endrazine/wcc";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      DieracDelta
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "wcc";
  };
})
