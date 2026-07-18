{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fetchpatch,
  flite,
  debug ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eflite";
  version = "0.4.1";

  src = fetchurl {
    url = "mirror://sourceforge/eflite/eflite/${finalAttrs.version}/eflite-${finalAttrs.version}.tar.gz";
    hash = "sha256-ka2FhV5Vo/w7l6GlJdtf0dIR1UNCu/yI0QJoExBPFyE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-BcgBZCbXWOaM4cSPeDPuIDviTymihAo9Puv4Wf8Ow2Q=";
      url = "https://sources.debian.org/data/main/e/eflite/0.4.1-14/debian/patches/cvs-update";
    })
    (fetchpatch {
      hash = "sha256-zAEJl473sk1H6Ltbbeo9IhWE5/Z6QL7EUV63S24bA10=";
      url = "https://sources.debian.org/data/main/e/eflite/0.4.1-14/debian/patches/link";
    })
    (fetchpatch {
      hash = "sha256-vc6dn4x0ortRp8TqHgNl0Ki10h3w9WnwOvasOUaYOBw=";
      url = "https://sources.debian.org/data/main/e/eflite/0.4.1-14/debian/patches/buf-overflow";
    })
    (fetchpatch {
      hash = "sha256-h7+OewOznlOrGNcn2zfE4kb/0rP+h9rTP3TLlyiPTJM=";
      url = "https://sources.debian.org/data/main/e/eflite/0.4.1-14/debian/patches/flags";
    })
    (fetchpatch {
      hash = "sha256-hiQaEM9Rf0KV8rgkXdjj3KIF+4jMYS4J4CT4UIfydGQ=";
      url = "https://sources.debian.org/data/main/e/eflite/0.4.1-14/debian/patches/gcc-15";
    })
    ./format.patch
  ];

  buildInputs = [
    flite
    alsa-lib
  ];

  configureFlags = [
    "flite_dir=${flite.dev}"
    "--with-audio=alsa"
    "--with-vox=cmu_us_kal16"
  ];

  env = lib.optionalAttrs debug {
    CFLAGS = " -DDEBUG=2";
  };

  meta = {
    description = "Speech server for screen readers";

    longDescription = ''
      EFlite is a speech server for Emacspeak and other screen
      readers that allows them to interface with Festival Lite,
      a free text-to-speech engine developed at the CMU Speech
      Center as an off-shoot of Festival.
    '';

    homepage = "https://eflite.sourceforge.net";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "eflite";
  };
})
