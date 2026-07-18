{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  alsa-lib,
  boost,
  cairo,
  cmake,
  codec2,
  cppunit,
  cppzmq,
  doxygen,
  fetchpatch,
  fftwFloat,
  gobject-introspection,
  gsl,
  gsm,
  # GUI related
  gtk3,
  # Needed only if qt-gui is disabled, from some reason
  icu,
  libad9361,
  libiio,
  libjack2,
  libsForQt5,
  libsndfile,
  libsodium,
  libunwind,
  mpir,
  orc,
  pango,
  pkg-config,
  python,
  qt5,
  # Remove gcc and python references
  removeReferencesTo,
  soapysdr,
  spdlog,
  thrift,
  uhd,
  volk,
  # Features available to override, the list of them is in featuresInfo. They
  # are all turned on by default.
  features ? { },
  # If one wishes to use a different src or name for a very custom build
  overrideSrc ? { },
  pname ? "gnuradio",
  version ? "3.10.12.0",
}:

let
  sourceSha256 = "sha256-489Pc6z6Ha7jkTzZSEArDQJGkWdWRDIn1uhfFyLLiCo=";
  featuresInfo = {
    # Needed always
    basic = {
      native = [
        cmake
        pkg-config
        orc
      ];

      pythonNative = with python.pythonOnBuildForHost.pkgs; [
        mako
        six
      ];

      runtime = [
        volk
        boost
        spdlog
        mpir
      ]
      # when gr-qtgui is disabled, icu needs to be included, otherwise
      # building with boost 1.7x fails
      ++ lib.optionals (!(hasFeature "gr-qtgui")) [ icu ];
    };

    common-precompiled-headers = {
      cmakeEnableFlag = "COMMON_PCH";
    };

    doxygen = {
      cmakeEnableFlag = "DOXYGEN";
      native = [ doxygen ];
    };

    gnuradio-companion = {
      cmakeEnableFlag = "GRC";

      native = [
        python.pkgs.pytest
      ];

      pythonRuntime = with python.pkgs; [
        pyyaml
        mako
        numpy
        pygobject3
      ];

      runtime = [
        gtk3
        pango
        gobject-introspection
        cairo
        libsndfile
      ];
    };

    gnuradio-runtime = {
      cmakeEnableFlag = "GNURADIO_RUNTIME";

      pythonRuntime = [
        python.pkgs.pybind11
      ];
    };

    gr-analog = {
      cmakeEnableFlag = "GR_ANALOG";
    };

    gr-audio = {
      cmakeEnableFlag = "GR_AUDIO";

      runtime =
        [ ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          alsa-lib
          libjack2
        ];
    };

    gr-blocks = {
      cmakeEnableFlag = "GR_BLOCKS";

      runtime = [
        # Required to compile wavfile blocks.
        libsndfile
      ];
    };

    gr-blocktool = {
      cmakeEnableFlag = "GR_BLOCKTOOL";
    };

    gr-channels = {
      cmakeEnableFlag = "GR_CHANNELS";
    };

    gr-ctrlport = {
      cmakeEnableFlag = "GR_CTRLPORT";

      pythonRuntime = [
        python.pkgs.thrift
        # For gr-perf-monitorx
        python.pkgs.matplotlib
        python.pkgs.networkx
      ];

      runtime = [
        libunwind
        thrift
      ];
    };

    gr-digital = {
      cmakeEnableFlag = "GR_DIGITAL";
    };

    gr-dtv = {
      cmakeEnableFlag = "GR_DTV";
    };

    gr-fec = {
      cmakeEnableFlag = "GR_FEC";
    };

    gr-fft = {
      cmakeEnableFlag = "GR_FFT";
      runtime = [ fftwFloat ];
    };

    gr-filter = {
      cmakeEnableFlag = "GR_FILTER";

      pythonRuntime = with python.pkgs; [
        scipy
        pyqtgraph
        pyqt5
      ];

      runtime = [ fftwFloat ];
    };

    gr-iio = {
      cmakeEnableFlag = "GR_IIO";

      runtime = [
        libiio
      ];
    };

    gr-modtool = {
      cmakeEnableFlag = "GR_MODTOOL";

      pythonRuntime = with python.pkgs; [
        setuptools
        click
        click-plugins
        pygccxml
      ];
    };

    gr-network = {
      cmakeEnableFlag = "GR_NETWORK";
    };

    gr-pdu = {
      cmakeEnableFlag = "GR_PDU";

      runtime = [
        libiio
        libad9361
      ];
    };

    gr-qtgui = {
      cmakeEnableFlag = "GR_QTGUI";
      pythonRuntime = [ python.pkgs.pyqt5 ];

      runtime = [
        qt5.qtbase
        libsForQt5.qwt
      ];
    };

    gr-soapy = {
      cmakeEnableFlag = "GR_SOAPY";

      runtime = [
        soapysdr
      ];
    };

    gr-trellis = {
      cmakeEnableFlag = "GR_TRELLIS";
    };

    gr-uhd = {
      cmakeEnableFlag = "GR_UHD";

      runtime = [
        uhd
      ];
    };

    gr-uhd-rfnoc = {
      cmakeEnableFlag = "UHD_RFNOC";

      runtime = [
        uhd
      ];
    };

    gr-utils = {
      cmakeEnableFlag = "GR_UTILS";

      pythonRuntime = with python.pkgs; [
        # For gr_plot
        matplotlib
      ];
    };

    gr-video-sdl = {
      cmakeEnableFlag = "GR_VIDEO_SDL";
      runtime = [ SDL ];
    };

    gr-vocoder = {
      cmakeEnableFlag = "GR_VOCODER";

      runtime = [
        codec2
        gsm
      ];
    };

    gr-wavelet = {
      cmakeEnableFlag = "GR_WAVELET";

      runtime = [
        gsl
        libsodium
      ];
    };

    gr-zeromq = {
      cmakeEnableFlag = "GR_ZEROMQ";

      pythonRuntime = [
        # Will compile without this, but it is required by tests, and by some
        # gr blocks.
        python.pkgs.pyzmq
      ];

      runtime = [ cppzmq ];
    };

    jsonyaml_blocks = {
      cmakeEnableFlag = "JSONYAML_BLOCKS";

      pythonRuntime = [
        python.pkgs.jsonschema
      ];
    };

    man-pages = {
      cmakeEnableFlag = "MANPAGES";
    };

    post-install = {
      cmakeEnableFlag = "POSTINSTALL";
    };

    python-support = {
      cmakeEnableFlag = "PYTHON";

      native = [
        python
      ];

      pythonRuntime = [ python.pkgs.six ];
    };

    testing-support = {
      cmakeEnableFlag = "TESTING";
      native = [ cppunit ];
    };
  };
  shared = (
    import ./shared.nix {
      inherit
        stdenv
        lib
        python
        removeReferencesTo
        featuresInfo
        features
        version
        sourceSha256
        overrideSrc
        fetchFromGitHub
        ;

      gtk = gtk3;
      qt = qt5;
    }
  );
  inherit (shared.passthru) hasFeature; # function
in

stdenv.mkDerivation (
  finalAttrs:
  (
    shared
    // {
      inherit pname version;
      # Will still evaluate correctly if not used here. It only helps nix-update
      # find the right file in which version is defined.
      inherit (shared) src;

      patches = [
        # Not accepted upstream, see https://github.com/gnuradio/gnuradio/pull/5227
        ./modtool-newmod-permissions.patch

        # Finding `boost_system` fails because the stub compiled library of
        # Boost.System, which has been a header-only library since 1.69, was
        # removed in 1.89.
        (fetchpatch {
          hash = "sha256-TQxqsce1AhSjdwaG2IP11QTeOgdJHN6cAAnznBl8eM8=";
          url = "https://github.com/gnuradio/gnuradio/commit/d8814e0c3ef68372e5a1093603ef602e2119cd8a.patch";
        })
      ];

      postInstall =
        shared.postInstall
        # This is the only python reference worth removing, if needed.
        + lib.optionalString (!hasFeature "python-support") ''
          remove-references-to -t ${python} $out/lib/cmake/gnuradio/GnuradioConfig.cmake
        ''
        + lib.optionalString (!hasFeature "python-support" && hasFeature "gnuradio-runtime") ''
          remove-references-to -t ${python} $(readlink -f $out/lib/libgnuradio-runtime${stdenv.hostPlatform.extensions.sharedLibrary})
          remove-references-to -t ${python.pkgs.pybind11} $out/lib/cmake/gnuradio/gnuradio-runtimeTargets.cmake
        '';

      passthru = shared.passthru // {
        # Deps that are potentially overridden and are used inside GR plugins - the same version must
        inherit
          uhd
          boost
          volk
          libiio
          libad9361
          ;

        inherit (libsForQt5) qwt;
        # Used by many gnuradio modules, the same attribute is present in
        # previous gnuradio versions where there it's log4cpp.
        logLib = spdlog;
      };
    }
  )
)
