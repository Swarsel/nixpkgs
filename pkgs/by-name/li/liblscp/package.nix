{
  lib,
  stdenv,
  fetchurl,
  cmake,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblscp";
  version = "1.0.1";

  src = fetchurl {
    url = "https://download.linuxsampler.org/packages/liblscp-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-21SjPA5emMRKEQIukhg7r3uXfnByEpNkGhCepNu09sc=";
  };

  postPatch = ''
    # fix prefix to only appear once
    substituteInPlace CMakeLists.txt \
      --replace-fail '"''${CONFIG_PREFIX}/' '"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  enableParallelBuilding = true;

  meta = {
    description = "LinuxSampler Control Protocol (LSCP) wrapper library";
    homepage = "http://www.linuxsampler.org";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
