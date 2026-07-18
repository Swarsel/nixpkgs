{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "afio";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "kholtman";
    repo = "afio";
    tag = "v${finalAttrs.version}";
    sha256 = "1vbxl66r5rp5a1qssjrkfsjqjjgld1cq57c871gd0m4qiq9rmcfy";
  };

  patches = [
    /*
      A patch to simplify the installation and for removing the
      hard coded dependency on GCC.
    */
    ./0001-makefile-fix-installation.patch

    # fix darwin build (include headers)
    (fetchpatch {
      hash = "sha256-pK8mN29fC2mL4B69Fv82dWFIQMGwquyl825OBDTxzpo=";
      name = "darwin-headers.patch";
      url = "https://github.com/kholtman/afio/pull/18/commits/a726614f99913ced08f6ae74091c56969d5db210.patch";
    })
  ];

  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Fault tolerant cpio archiver targeting backups";
    homepage = "https://github.com/kholtman/afio";
    /*
      Licensing is complicated due to the age of the code base, but
      generally free. See the file ``afio_license_issues_v5.txt`` for
      a comprehensive discussion.
    */
    license = lib.licenses.free;
    platforms = lib.platforms.all;
    mainProgram = "afio";
  };
})
