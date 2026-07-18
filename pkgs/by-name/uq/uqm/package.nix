{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  libGL,
  libGLU,
  libmikmod,
  libogg,
  libpng,
  libvorbis,
  pkg-config,
  haskellPackages ? null,
  requireFile ? null,
  use3DOVideos ? false,
  useRemixPacks ? false,
  writeText ? null,
}:

assert use3DOVideos -> requireFile != null && writeText != null && haskellPackages != null;

let
  videos = import ./3dovideo.nix {
    inherit
      stdenv
      lib
      requireFile
      writeText
      fetchFromGitHub
      haskellPackages
      ;
  };

  remixPacks =
    lib.imap1
      (
        num: sha256:
        fetchurl rec {
          inherit sha256;
          name = "uqm-remix-disc${toString num}.uqm";
          url = "mirror://sourceforge/sc2/${name}";
        }
      )
      [
        "1s470i6hm53l214f2rkrbp111q4jyvnxbzdziqg32ffr8m3nk5xn"
        "1pmsq65k8gk4jcbyk3qjgi9yqlm0dlaimc2r8hz2fc9f2124gfvz"
        "07g966ylvw9k5q9jdzqdczp7c5qv4s91xjlg4z5z27fgcs7rzn76"
        "1l46k9aqlcp7d3fjkjb3n05cjfkxx8rjlypgqy0jmdx529vikj54"
      ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "uqm";
  version = "0.8.0";

  src = fetchurl {
    url = "mirror://sourceforge/sc2/uqm-${finalAttrs.version}-src.tgz";
    sha256 = "JPL325z3+vU7lfniWA5vWWIFqY7QwzXP6DTGR4WtT1o=";
  };

  postPatch = ''
    # Using _STRINGS_H as include guard conflicts with glibc.
    sed -i -e '/^#/s/_STRINGS_H/_UQM_STRINGS_H/g' src/uqm/comm/*/strings.h
    # See https://github.com/NixOS/nixpkgs/pull/93560
    sed -i -e 's,/tmp/,$TMPDIR/,' build/unix/config_functions
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL2
    libpng
    libvorbis
    libogg
    libmikmod
    libGLU
    libGL
  ];

  buildPhase = ''
    ./build.sh uqm
  '';

  installPhase = ''
    ./build.sh uqm install
    sed -i $out/bin/uqm -e "s%/usr/local/games/%$out%g"
  '';

  # uqm has a 'unique' build system with a root script incidentally called
  # 'build.sh'.
  configurePhase = ''
    runHook preConfigure

    echo "INPUT_install_prefix_VALUE='$out'" >> config.state
    echo "INPUT_install_bindir_VALUE='$out/bin'" >> config.state
    echo "INPUT_install_libdir_VALUE='$out/lib'" >> config.state
    echo "INPUT_install_sharedir_VALUE='$out/share'" >> config.state
    PREFIX=$out ./build.sh uqm config

    runHook postConfigure
  '';

  content = fetchurl {
    sha256 = "d9dawl5vt1WjPEujs4p7e8Qfy8AolokbDMmskhS3Lu8=";
    url = "mirror://sourceforge/sc2/uqm-${finalAttrs.version}-content.uqm";
  };

  music = fetchurl {
    sha256 = "RM087H6VabQRettNd/FSKJCXJWYmc5GuCWMUhdIx2Lk=";
    url = "mirror://sourceforge/sc2/uqm-${finalAttrs.version}-3domusic.uqm";
  };

  postUnpack = ''
    mkdir -p uqm-${finalAttrs.version}/content/packages
    mkdir -p uqm-${finalAttrs.version}/content/addons
    ln -s "$content" "uqm-${finalAttrs.version}/content/packages/uqm-${finalAttrs.version}-content.uqm"
    ln -s "$music" "uqm-${finalAttrs.version}/content/addons/uqm-${finalAttrs.version}-3domusic.uqm"
    ln -s "$voice" "uqm-${finalAttrs.version}/content/addons/uqm-${finalAttrs.version}-voice.uqm"
  ''
  + lib.optionalString useRemixPacks (
    lib.concatMapStrings (disc: ''
      ln -s "${disc}" "uqm-$version/content/addons/${disc.name}"
    '') remixPacks
  )
  + lib.optionalString use3DOVideos ''
    ln -s "${videos}" "uqm-${finalAttrs.version}/content/addons/3dovideo"
  '';

  voice = fetchurl {
    sha256 = "ntv1HXfYtTM5nF86+1STFKghDXqrccosUbTySDIzekU=";
    url = "mirror://sourceforge/sc2/uqm-${finalAttrs.version}-voice.uqm";
  };

  meta = {
    description = "Remake of Star Control II";

    longDescription = ''
      The goals for the The Ur-Quan Masters project are:
        - to bring Star Control II to modern platforms, thereby making a lot of
          people happy
        - to make game translations easy, thereby making even more people happy
        - to adapt the code so that people can more easily make their own
          spin-offs, thereby making zillions more people happy!
    '';

    homepage = "https://sc2.sourceforge.net/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      jcumming
      aszlig
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "uqm";
  };
})
