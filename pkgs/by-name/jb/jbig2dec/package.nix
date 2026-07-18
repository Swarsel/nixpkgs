{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  libtool,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jbig2dec";
  version = "0.20";

  src = fetchurl {
    url = "https://github.com/ArtifexSoftware/jbig2dec/archive/${finalAttrs.version}/jbig2dec-${finalAttrs.version}.tar.gz";
    hash = "sha256-qXBTaaZjOrpTJpNFDsgCxWI5fhuCRmLegJ7ekvZ6/yE=";
  };

  postPatch = ''
    patchShebangs test_jbig2dec.py
  '';

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  doCheck = true;
  nativeCheckInputs = [ python3 ];
  # `autogen.sh` runs `configure`, and expects that any flags needed
  # by `configure` (like `--host`) are passed to `autogen.sh`.
  configureScript = "./autogen.sh";

  meta = {
    description = "Decoder implementation of the JBIG2 image compression format";
    homepage = "https://www.jbig2dec.com/";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "jbig2dec";
  };
})
