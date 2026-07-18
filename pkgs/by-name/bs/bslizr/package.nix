{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bslizr";
  version = "1.2.16";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BSlizr";
    tag = finalAttrs.version;
    sha256 = "sha256-5DvVkTz79CLvZMZ3XnI0COIfxnhERDSvzbVoJAcqNRI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    lv2
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Sequenced audio slicing effect LV2 plugin (step sequencer effect)";
    homepage = "https://github.com/sjaehn/BSlizr";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
