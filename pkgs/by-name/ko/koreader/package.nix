{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  dpkg,
  fetchpatch,
  glib,
  gnutar,
  gtk3-x11,
  luajit,
  makeWrapper,
  openssl,
  sdcv,
  sdl3,
  writeScript,
}:

let
  version = "2026.03";

  # LuaJIT with table.pack/unpack support for KOReader
  # https://github.com/koreader/koreader-base/tree/master/thirdparty/luajit
  luajit_koreader = luajit.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        hash = "sha256-tvx7eRoSwnumqK6H7+2RCAKRDFJtaRY/2mRPjy30fJA=";
        url = "https://raw.githubusercontent.com/koreader/koreader-base/master/thirdparty/luajit/koreader-luajit-enable-table_pack.patch";
      })
    ];
  });

  src_repo = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-KWpWlFoBEAhVDuRTiF7yj1wlKLzYmvcngI9iWqsDuQY=";
    owner = "koreader";
    repo = "koreader";
    tag = "v${version}";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "koreader";

  src =
    let
      selectSystem =
        attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      arch = selectSystem {
        aarch64-linux = "arm64";
        armv7l-linux = "armhf";
        x86_64-linux = "amd64";
      };
    in
    fetchurl {
      url = "https://github.com/koreader/koreader/releases/download/v${version}/koreader_${version}-1_${arch}.deb";

      hash = selectSystem {
        aarch64-linux = "sha256-4ulpMXYcICQ5/9Q0GGn9lkbW0ntzIfUHQ5woTAhyXLU=";
        armv7l-linux = "sha256-diMWFhL0D5bWPQFc9vvZZRPMfNxlxchGyT8Lz/TLHPs=";
        x86_64-linux = "sha256-OhBu3oj9IqNmK5ngCkXvucVQq5aJohObgENtjdDcQcE=";
      };
    };

  strictDeps = true;

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  buildInputs = [
    glib
    gnutar
    gtk3-x11
    luajit_koreader
    sdcv
    sdl3
    openssl
  ];

  installPhase = ''
    runHook preInstall

    cp --recursive usr $out
  ''
  # Link required binaries
  + ''
    ln -sf ${luajit_koreader}/bin/luajit $out/lib/koreader/luajit
    ln -sf ${sdcv}/bin/sdcv $out/lib/koreader/sdcv
    ln -sf ${gnutar}/bin/tar $out/lib/koreader/tar
  ''
  # Link SSL/network libraries
  + ''
    ln -sf ${lib.getLib openssl}/lib/libcrypto.so.3 $out/lib/koreader/libs/libcrypto.so.1.1
    ln -sf ${lib.getLib openssl}/lib/libssl.so.3 $out/lib/koreader/libs/libssl.so.1.1
    ln -sf ${lib.getLib sdl3}/lib/libSDL3.so.0 $out/lib/koreader/libs/libSDL3.so.0
  ''
  # Copy fonts
  + ''
    cp -r ${src_repo}/resources/fonts/* $out/lib/koreader/fonts/
  ''
  # Remove broken symlinks
  + ''
    find $out -xtype l -print -delete
  ''
  + ''
    wrapProgram $out/bin/koreader --prefix LD_LIBRARY_PATH : $out/lib/koreader/libs:${
      lib.makeLibraryPath [
        gtk3-x11
        sdl3
        glib
        stdenv.cc.cc
        openssl.out
      ]
    }

    runHook postInstall
  '';

  __structuredAttrs = true;

  passthru = {
    inherit src_repo luajit_koreader;

    updateScript = writeScript "update-koreader" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix curl jq nix-update common-updater-scripts
      set -eou pipefail
      version=$(nix eval --raw --file . koreader.version)
      nix-update koreader
      latestVersion=$(nix eval --raw --file . koreader.version)
      if [[ "$latestVersion" == "$version" ]]; then
        exit 0
      fi
      update-source-version koreader $latestVersion --source-key=src_repo --ignore-same-version
      systems=$(nix eval --json -f . koreader.meta.platforms | jq --raw-output '.[]')
      for system in $systems; do
        hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $(nix eval --raw -f . koreader.src.url --system "$system")))
        update-source-version koreader $latestVersion $hash --system=$system --ignore-same-version --ignore-same-hash
      done
    '';
  };

  meta = {
    description = "Ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices";
    homepage = "https://github.com/koreader/koreader";
    changelog = "https://github.com/koreader/koreader/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      contrun
      liberodark
    ];

    platforms = [
      "aarch64-linux"
      "armv7l-linux"
      "x86_64-linux"
    ];

    mainProgram = "koreader";
  };
}
