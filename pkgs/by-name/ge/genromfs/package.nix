{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "genromfs";
  version = "0.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/romfs/genromfs/${finalAttrs.version}/genromfs-${finalAttrs.version}.tar.gz";
    sha256 = "0q6rpq7cmclmb4ayfyknvzbqysxs4fy8aiahlax1sb2p6k3pzwrh";
  };

  makeFlags = [
    "prefix:=$(out)"
    "CC:=$(CC)"
  ];

  meta = {
    description = "Tool for creating romfs file system images";
    homepage = "https://romfs.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.all;
    mainProgram = "genromfs";
  };
})
