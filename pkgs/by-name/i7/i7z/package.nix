{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libsForQt5,
  ncurses,
  withGui ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i7z";
  version = "0.27.4";

  src = fetchFromGitHub {
    owner = "DimitryAndric";
    repo = "i7z";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vieBgu1UWRBUgPj0MDQbv+L4bEsxPKI8gwj5DMazhAE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-eihvP8hhoZ+wc1xUFN9vrKatScVwvv+tI54ELrsBz0U=";
      url = "https://salsa.debian.org/debian/i7z/raw/ad1359764ee7a860a02e0c972f40339058fa9369/debian/patches/fix-insecure-tempfile.patch";
    })
    (fetchpatch {
      hash = "sha256-CmH5aZ/tVCYLK8o7JqVE8P6WEBwMH0+aWXjKAOrTRvs=";
      url = "https://salsa.debian.org/debian/i7z/raw/ad1359764ee7a860a02e0c972f40339058fa9369/debian/patches/nehalem.patch";
    })
    (fetchpatch {
      hash = "sha256-Nzw4PbS3P8l3lwA+r4epefD9ntO0gY8vI6kA7NvGIso=";
      url = "https://salsa.debian.org/debian/i7z/raw/ad1359764ee7a860a02e0c972f40339058fa9369/debian/patches/hyphen-used-as-minus-sign.patch";
    })
    ./qt5.patch
  ];

  strictDeps = true;
  buildInputs = [ ncurses ] ++ lib.optional withGui libsForQt5.qtbase;
  makeFlags = [ "prefix=${placeholder "out"}" ];

  postBuild = lib.optionalString withGui ''
    cd GUI
    qmake
    make clean
    make
    cd ..
  '';

  postInstall = lib.optionalString withGui ''
    install -Dm755 GUI/i7z_GUI $out/bin/i7z-gui
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Better i7 (and now i3, i5) reporting tool for Linux";
    homepage = "https://github.com/DimitryAndric/i7z";
    license = lib.licenses.gpl2Only;
    # broken on ARM
    platforms = [ "x86_64-linux" ];
    mainProgram = "i7z";
  };
})
