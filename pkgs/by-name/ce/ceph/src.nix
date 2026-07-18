{
  fetchurl,
  applyPatches,
  fetchpatch2,
}:

applyPatches (final: {
  pname = "ceph-src";
  version = "20.2.2";

  src = fetchurl {
    url = "https://download.ceph.com/tarballs/ceph-${final.version}.tar.gz";
    hash = "sha256-G76ZcCdadt4KP7Ry0yzqPrbi1ydZlrcZb2IhGd2Fd1M=";
  };

  patches = [
    # required to be able to compile s3select against nixpkgs' arrow-cpp
    # See: https://github.com/ceph/s3select/pull/169
    (fetchpatch2 {
      extraPrefix = "src/s3select/";
      hash = "sha256-0jn5X4jIdluCufFXWHeO6skMz6XQpliHkC1tPLK6dbk=";
      name = "ceph-s3select-arrow-cpp-20.patch";
      stripLen = 1;
      url = "https://github.com/ceph/s3select/pull/169.diff?full_index=1";
    })
    # fixes issues when python3 is not on the PATH
    # See: https://github.com/ceph/ceph/pull/67904
    ./patches/0001-mgr-python-interpreter.patch
  ];
})
