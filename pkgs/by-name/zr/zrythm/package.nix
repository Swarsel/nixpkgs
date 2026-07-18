{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  appstream,
  bash-completion,
  boost,
  carla,
  chromaprint,
  cmake,
  curl,
  dbus,
  dconf,
  fetchzip,
  fftw,
  fftwFloat,
  flex,
  glib,
  graphviz,
  gtk4,
  gtksourceview5,
  guile,
  help2man,
  jq,
  kdePackages,
  kissfft,
  libadwaita,
  libbacktrace,
  libcyaml,
  libepoxy,
  libjack2,
  libpanel,
  libpulseaudio,
  libsamplerate,
  libsndfile,
  libxml2,
  libyaml,
  lilv,
  lv2,
  meson,
  ninja,
  pcre2,
  pkg-config,
  python3,
  rtaudio_6,
  rtmidi,
  rubberband,
  sassc,
  serd,
  sord,
  sox,
  soxr,
  sratom,
  texi2html,
  vamp-plugin-sdk,
  wrapGAppsHook4,
  writeScript,
  xdg-utils,
  xxhash,
  yyjson,
  zix,
  zstd,
}:

let
  # Error: Dependency carla-host-plugin found: NO found 2.5.6 but need: '>=2.6.0'
  # So we need Carla unstable
  carla-unstable = carla.overrideAttrs (oldAttrs: {
    pname = "carla";
    version = "unstable-2024-04-26";

    src = fetchFromGitHub {
      owner = "falkTX";
      repo = "carla";
      rev = "948991d7b5104280c03960925908e589c77b169a";
      hash = "sha256-uGAuKheoMfP9hZXsw29ec+58dJM8wMuowe95QutzKBY=";
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zrythm";
  version = "1.0.0";

  src = fetchzip {
    url = "https://www.zrythm.org/releases/zrythm-${finalAttrs.version}.tar.xz";
    hash = "sha256-qI1UEIeIJdYQcOWMjJa55DaWjDIabx56dSwjhm64ROM=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "'/usr/lib', '/usr/local/lib', '/opt/homebrew/lib'" "'${fftw}/lib'"

    chmod +x scripts/meson-post-install.sh
    patchShebangs ext/sh-manpage-completions/run.sh scripts/generic_guile_wrap.sh \
      scripts/meson-post-install.sh tools/check_have_unlimited_memlock.sh
  '';

  nativeBuildInputs = [
    chromaprint
    cmake
    flex
    guile
    help2man
    jq
    libxml2
    lilv
    meson
    ninja
    pkg-config
    python3
    python3.pkgs.sphinx
    sassc
    serd
    sord
    sratom
    texi2html
    wrapGAppsHook4
  ];

  buildInputs = [
    alsa-lib
    appstream
    bash-completion
    boost
    carla-unstable
    curl
    dbus
    dconf
    fftw
    fftwFloat
    glib
    graphviz
    gtk4
    gtksourceview5
    kissfft
    libadwaita
    libbacktrace
    libcyaml
    libepoxy
    libjack2
    libpanel
    libpulseaudio
    libsamplerate
    libsndfile
    libyaml
    lv2
    pcre2
    rtaudio_6
    rtmidi
    rubberband
    sox
    soxr
    vamp-plugin-sdk
    xdg-utils
    xxhash
    yyjson
    zix
    zstd
  ];

  mesonFlags = [
    "-Db_lto=false"
    "-Dcarla=enabled"
    "-Dcarla_binaries_dir=${carla-unstable}/lib/carla"
    "-Ddebug=true"
    "-Dfftw3_threads_separate=false"
    "-Dfftw3_threads_separate_type=library"
    "-Dfftw3f_separate=false"
    "-Dlsp_dsp=disabled"
    "-Dmanpage=true"
    "-Drtaudio=enabled"
    "-Drtmidi=enabled"
    # "-Duser_manual=true" # needs sphinx-intl
  ];

  env = {
    GUILE_AUTO_COMPILE = 0;

    NIX_LDFLAGS = toString [
      "-lfftw3_threads"
      "-lfftw3f_threads"
    ];
  };

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GSETTINGS_SCHEMA_DIR : "$out/share/gsettings-schemas/zrythm-${finalAttrs.version}/glib-2.0/schemas/"
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${kdePackages.breeze-icons}/share"
    )
  '';

  dontStrip = true;
  # Zrythm uses meson to build, but requires cmake for dependency detection.
  dontUseCmakeConfigure = true;
  dontWrapQtApps = true;

  passthru.updateScript = writeScript "update-zrythm" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl common-updater-scripts

    version="$(curl -s https://www.zrythm.org/releases/ | grep -o -m 1 'href="zrythm-[^"]*\.tar\.xz"' | head -1 | sed 's/href="zrythm-\(.*\)\.tar\.xz"/\1/')"
    update-source-version zrythm "$version"
  '';

  meta = {
    description = "Automated and intuitive digital audio workstation";
    homepage = "https://www.zrythm.org";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      tshaynik
      magnetophon
      astavie
      PowerUser64
    ];

    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
