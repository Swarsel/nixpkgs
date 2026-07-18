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
  pname = "bschaffl";
  version = "1.4.10";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "bschaffl";
    tag = finalAttrs.version;
    sha256 = "sha256-zfhPYH4eUNWHV27ZtX2IIvobyPdKs5yGr/ryJRQa6as=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cairo
    libx11
    lv2
  ];

  enableParallelBuilding = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Pattern-controlled MIDI amp & time stretch LV2 plugin";
    homepage = "https://github.com/sjaehn/BSchaffl";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
