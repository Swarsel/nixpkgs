{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoconf,
  automake,
  avahi,
  bluez,
  boost,
  buildPackages,
  bzip2,
  cmake,
  curl,
  cwiid,
  dbus,
  dcadec,
  doxygen,
  fetchpatch,
  fetchzip,
  ffmpeg,
  flac,
  flatbuffers,
  fontconfig,
  freetype,
  fribidi,
  fstrcmp,
  ftgl,
  gettext,
  giflib,
  glib,
  gnutls,
  gperf,
  gtest,
  harfbuzz,
  jre_headless,
  lame,
  lcms2,
  libGL,
  libGLU,
  libass,
  libbluray,
  libcdio,
  libcec,
  libcec_platform,
  libcrossguid,
  libdisplay-info,
  libdrm,
  libgbm,
  libgcrypt,
  libgpg-error,
  libidn2,
  libinput,
  libjpeg,
  libmad,
  libmicrohttpd,
  libmodplug,
  libmpeg2,
  libmysqlclient,
  libnfs,
  libogg,
  libplist,
  libpng,
  libpthread-stubs,
  libpulseaudio,
  libsamplerate,
  libssh,
  libtasn1,
  libtiff,
  libtool,
  libudfread,
  libunistring,
  libusb-compat-0_1,
  libuuid,
  libva,
  libvdpau,
  libvorbis,
  libx11,
  libxcrypt,
  libxdmcp,
  libxext,
  libxfixes,
  libxinerama,
  libxkbcommon,
  libxml2,
  libxmu,
  libxrandr,
  libxslt,
  libxt,
  libxtst,
  lirc,
  lzo,
  makeWrapper,
  mesa-demos,
  mesa-gl-headers,
  nasm,
  ncurses,
  openssl,
  p11-kit,
  pcre-cpp,
  pipewire,
  pkg-config,
  python3Packages,
  rapidjson,
  rtmpdump,
  samba,
  spdlog,
  sqlite,
  taglib,
  tinyxml,
  tinyxml-2,
  udev,
  unzip,
  wayland,
  wayland-protocols,
  which,
  xdpyinfo,
  xorgproto,
  yajl,
  yasm,
  zip,
  zlib,
  dbusSupport ? true,
  gbmSupport ? false,
  joystickSupport ? true,
  nfsSupport ? true,
  opticalSupport ? true,
  pipewireSupport ? true,
  pulseSupport ? true,
  rtmpSupport ? true,
  sambaSupport ? true,
  udevSupport ? true,
  usbSupport ? false,
  vdpauSupport ? true,
  waylandSupport ? false,
  waylandpp ? null,
  x11Support ? true,
}:

assert usbSupport -> !udevSupport; # libusb-compat-0_1 won't be used if udev is available
assert gbmSupport || waylandSupport || x11Support;

let
  # see https://github.com/xbmc/xbmc/blob/${kodiVersion}-${rel}/tools/depends/target/ to get suggested versions for all dependencies

  # We can build these externally but FindLibDvd.cmake forces us to build it
  # them, so we currently just use them for the src.
  libdvdcss = fetchFromGitHub {
    owner = "xbmc";
    repo = "libdvdcss";
    rev = "1.4.3-Next-Nexus-Alpha2-2";
    sha256 = "sha256-CJMGH50mNAkovccNcol5ArF3zUnZKfbVB9EXyQgu5k4=";
  };

  libdvdnav = fetchFromGitHub {
    owner = "xbmc";
    repo = "libdvdnav";
    rev = "6.1.1-Next-Nexus-Alpha2-2";
    sha256 = "sha256-m8SCjOokVbwJ7eVfYKHap1pQjVbI+BXaoxhGZQIg0+k=";
  };

  libdvdread = fetchFromGitHub {
    owner = "xbmc";
    repo = "libdvdread";
    rev = "6.1.3-Next-Nexus-Alpha2-2";
    sha256 = "sha256-AphBQhXud+a6wm52zjzC5biz53NnqWdgpL2QDt2ZuXc=";
  };

  groovy = fetchzip {
    sha256 = "sha256-OfZBiMVrhw6VqHRHCSC7ZV3FiZ26n4+F8hsskk+L6yU=";
    url = "mirror://apache/groovy/4.0.16/distribution/apache-groovy-binary-4.0.16.zip";
  };

  apache_commons_lang = fetchzip {
    sha512 = "sha512-eKF1IQ6PDtifb4pMHWQ2SYHIh0HbMi3qpc92lfbOo3uSsFJVR3n7JD0AdzrG17tLJQA4z5PGDhwyYw0rLeLsXw==";
    url = "mirror://apache/commons/lang/binaries/commons-lang3-3.14.0-bin.zip";
  };

  apache_commons_text = fetchzip {
    sha512 = "sha512-P2IvnrHSYRF70LllTMI8aev43h2oe8lq6rrMYw450PEhEa7OuuCjh1Krnc/A4OqENUcidVAAX5dK1RAsZHh8Dg==";
    url = "mirror://apache/commons/text/binaries/commons-text-1.11.0-bin.zip";
  };

  kodi_platforms =
    lib.optional gbmSupport "gbm"
    ++ lib.optional waylandSupport "wayland"
    ++ lib.optional x11Support "x11";
in
stdenv.mkDerivation (
  finalAttrs:
  let
    texturePacker = buildPackages.callPackage (
      {
        stdenv,
        cmake,
        giflib,
        libjpeg,
        libpng,
        lzo,
        pkg-config,
        zlib,
      }:
      stdenv.mkDerivation {
        inherit (finalAttrs) version src;
        pname = finalAttrs.pname + "-build-tool-texture-packer";

        nativeBuildInputs = [
          pkg-config
          cmake
        ];

        buildInputs = [
          giflib
          libjpeg
          libpng
          lzo
          zlib
        ];

        env.NIX_CFLAGS_COMPILE = lib.optionalString (!stdenv.hostPlatform.isWindows) "-DTARGET_POSIX";

        preConfigure = ''
          cmakeFlagsArray+=(-DKODI_SOURCE_DIR=$src -DCMAKE_MODULE_PATH=$src/cmake/modules)
        '';

        sourceRoot = "${finalAttrs.src.name}/tools/depends/native/TexturePacker/src";
        meta.mainProgram = "TexturePacker";
      }
    ) { };

    jsonSchemaBuilder = buildPackages.callPackage (
      { stdenv, cmake }:
      stdenv.mkDerivation {
        inherit (finalAttrs) version src;
        pname = finalAttrs.pname + "-build-tool-json-schema-builder";
        nativeBuildInputs = [ cmake ];
        sourceRoot = "${finalAttrs.src.name}/tools/depends/native/JsonSchemaBuilder/src";
        meta.mainProgram = "JsonSchemaBuilder";
      }
    ) { };
  in
  {
    # make  derivations declared in the let binding available here, so
    # they can be overridden
    inherit
      libdvdcss
      libdvdnav
      libdvdread
      groovy
      apache_commons_lang
      apache_commons_text
      ;

    pname = "kodi";
    version = "21.3";

    src = fetchFromGitHub {
      owner = "xbmc";
      repo = "xbmc";
      rev = "${finalAttrs.version}-${finalAttrs.kodiReleaseName}";
      hash = "sha256-36wBAqGEDCRZ4t1ygTg03Pyk7Gg9quUTUGD3SBp6nCk=";
    };

    patches = [
      # TexturePacker has some conditionals on GIFLIB 5, which break with
      # GIFLIB 6. This has been extended to support all versions >= 5 upstream,
      # but has not yet made it into a release.
      # https://github.com/xbmc/xbmc/pull/28016
      (fetchpatch {
        hash = "sha256-WNaODPCtRfn30jVU5HbBnAO2Vl/MQp2CYmKOTTyDGZI=";
        name = "texturepacker-giflib-6.patch";
        url = "https://github.com/xbmc/xbmc/commit/29492cbd20d4c90a9c00a30ab525d4d0e81a968b.patch";
      })
    ];

    nativeBuildInputs = [
      cmake
      doxygen
      makeWrapper
      which
      pkg-config
      autoconf
      automake
      libtool # still needed for some components. Check if that is the case with 19.0
      jre_headless
      yasm
      gettext
      python3Packages.python
      flatbuffers
    ]
    ++ lib.optionals waylandSupport [
      wayland-protocols
      waylandpp.bin
    ];

    buildInputs = [
      gnutls
      libidn2
      libtasn1
      nasm
      p11-kit
      libxml2
      python3Packages.python
      boost
      libmicrohttpd
      gettext
      pcre-cpp
      yajl
      fribidi
      libva
      libdrm
      openssl
      gperf
      tinyxml
      tinyxml-2
      taglib
      libssh
      ncurses
      spdlog
      alsa-lib
      libGL
      libGLU
      fontconfig
      freetype
      ftgl
      libjpeg
      libpng
      libtiff
      libmpeg2
      libsamplerate
      libmad
      libogg
      libvorbis
      flac
      libxslt
      lzo
      libcdio
      libmodplug
      libass
      libbluray
      libudfread
      sqlite
      libmysqlclient
      avahi
      lame
      curl
      bzip2
      zip
      unzip
      mesa-demos
      libcec
      libcec_platform
      dcadec
      libuuid
      libxcrypt
      libgcrypt
      libgpg-error
      libunistring
      libcrossguid
      libplist
      bluez
      glib
      harfbuzz
      lcms2
      libpthread-stubs
      ffmpeg
      flatbuffers
      fstrcmp
      rapidjson
      lirc
      mesa-gl-headers

      # Deps needed by TexturePacker, which is built and installed in normal
      # kodi build, however the one used during the build is not this one
      # in order to support cross-compilation.
      giflib
      zlib
    ]
    ++ lib.optionals x11Support [
      libx11
      xorgproto
      libxt
      libxmu
      libxext.dev
      libxdmcp
      libxinerama
      libxrandr.dev
      libxtst
      libxfixes
    ]
    ++ lib.optional dbusSupport dbus
    ++ lib.optional joystickSupport cwiid
    ++ lib.optional nfsSupport libnfs
    ++ lib.optional pulseSupport libpulseaudio
    ++ lib.optional pipewireSupport pipewire
    ++ lib.optional rtmpSupport rtmpdump
    ++ lib.optional sambaSupport samba
    ++ lib.optional udevSupport udev
    ++ lib.optional usbSupport libusb-compat-0_1
    ++ lib.optional vdpauSupport libvdpau
    ++ lib.optionals waylandSupport [
      wayland
      waylandpp.dev
      wayland-protocols
      # Not sure why ".dev" is needed here, but CMake doesn't find libxkbcommon otherwise
      libxkbcommon.dev
    ]
    ++ lib.optionals gbmSupport [
      libxkbcommon.dev
      libgbm
      libinput.dev
      libdisplay-info
    ];

    cmakeFlags = [
      "-DAPP_RENDER_SYSTEM=${if gbmSupport then "gles" else "gl"}"
      "-Dlibdvdcss_URL=${finalAttrs.libdvdcss}"
      "-Dlibdvdnav_URL=${finalAttrs.libdvdnav}"
      "-Dlibdvdread_URL=${finalAttrs.libdvdread}"
      "-Dgroovy_SOURCE_DIR=${finalAttrs.groovy}"
      "-Dapache-commons-lang_SOURCE_DIR=${finalAttrs.apache_commons_lang}"
      "-Dapache-commons-text_SOURCE_DIR=${finalAttrs.apache_commons_text}"
      # Upstream derives this from the git HEADs hash and date.
      # LibreElec (minimal distro for kodi) uses the equivalent to this.
      "-DGIT_VERSION=${finalAttrs.version}-${finalAttrs.kodiReleaseName}"
      "-DENABLE_EVENTCLIENTS=ON"
      "-DENABLE_INTERNAL_CROSSGUID=OFF"
      "-DENABLE_INTERNAL_RapidJSON=OFF"
      "-DENABLE_OPTICAL=${if opticalSupport then "ON" else "OFF"}"
      "-DENABLE_VDPAU=${if vdpauSupport then "ON" else "OFF"}"
      "-DLIRC_DEVICE=/run/lirc/lircd"
      "-DSWIG_EXECUTABLE=${buildPackages.swig}/bin/swig"
      "-DFLATBUFFERS_FLATC_EXECUTABLE=${buildPackages.flatbuffers}/bin/flatc"
      "-DPYTHON_EXECUTABLE=${buildPackages.python3Packages.python}/bin/python"
      "-DPYTHON_LIB_PATH=${python3Packages.python.sitePackages}"
      "-DWITH_JSONSCHEMABUILDER=${lib.getExe jsonSchemaBuilder}"
      # When wrapped KODI_HOME will likely contain symlinks to static assets
      # that Kodi's built in webserver will cautiously refuse to serve up
      # (because their realpaths are outside of KODI_HOME and the other
      # whitelisted directories). This adds the entire nix store to the Kodi
      # webserver whitelist to avoid this problem.
      "-DKODI_WEBSERVER_EXTRA_WHITELIST=${builtins.storeDir}"
    ]
    ++ lib.optionals waylandSupport [
      "-DWAYLANDPP_SCANNER=${buildPackages.waylandpp}/bin/wayland-scanner++"
    ]
    ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      "-DWITH_TEXTUREPACKER=${lib.getExe texturePacker}"
    ];

    preConfigure = ''
      cmakeFlagsArray+=("-DCORE_PLATFORM_NAME=${lib.concatStringsSep " " kodi_platforms}")
    '';

    doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

    nativeCheckInputs = [
      gtest
    ];

    checkPhase = ''
      runHook preCheck

      make -j $NIX_BUILD_CORES kodi-test

      ./kodi-test --gtest_filter=-${
        lib.concatStringsSep ":" [
          "TestCPUInfo.GetCPUFrequency"
          "TestNetwork.PingHost"
          "TestSystemInfo.GetOsName"
          "TestSystemInfo.GetOsPrettyNameWithVersion"
        ]
      }

      runHook postCheck
    '';

    postInstall = ''
      # TODO: figure out which binaries should be wrapped this way and which shouldn't
      for p in $(ls --ignore=kodi-send $out/bin/) ; do
        wrapProgram $out/bin/$p \
          --prefix PATH ":" "${
            lib.makeBinPath (
              [
                python3Packages.python
                mesa-demos
              ]
              ++ lib.optional x11Support xdpyinfo
              ++ lib.optional sambaSupport samba
            )
          }" \
          --prefix LD_LIBRARY_PATH ":" "${
            lib.makeLibraryPath (
              [
                curl
                libmad
                libcec
                libcec_platform
                libass
              ]
              ++ lib.optional vdpauSupport libvdpau
              ++ lib.optional nfsSupport libnfs
              ++ lib.optional rtmpSupport rtmpdump
            )
          }"
      done

      wrapProgram $out/bin/kodi-send \
        --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages}

      substituteInPlace $out/share/xsessions/kodi.desktop \
        --replace kodi-standalone $out/bin/kodi-standalone
    '';

    doInstallCheck = true;
    installCheckPhase = "$out/bin/kodi --version";

    depsBuildBuild = [
      buildPackages.stdenv.cc
    ];

    kodiReleaseName = "Omega";

    passthru = {
      ffmpeg = ffmpeg;
      kodi = finalAttrs.finalPackage;
      pythonPackages = python3Packages;
    };

    meta = {
      description = "Media center";
      homepage = "https://kodi.tv/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
      mainProgram = "kodi";
      teams = [ lib.teams.kodi ];
    };
  }
)
