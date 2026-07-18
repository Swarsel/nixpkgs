{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  gettext,
  libiconv,
  pkg-config,
  xxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dosfstools";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "dosfstools";
    repo = "dosfstools";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-2gxB0lQixiHOHw8uTetHekaM57fvUd9zOzSxWnvUz/c=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  patches = [
    # macOS and FreeBSD build fixes backported from master
    # TODO: remove on the next release
    (fetchpatch {
      sha256 = "sha256-xHxIs3faHK/sK3vAVoG8JcTe4zAV+ZtkozWIIFBvPWI=";
      url = "https://github.com/dosfstools/dosfstools/commit/77ffb87e8272760b3bb2dec8f722103b0effb801.patch";
    })
    (fetchpatch {
      sha256 = "nlIuRDsNjk23MKZL9cZ05odOfTXvsyQaKcv/xEr4c+U=";
      url = "https://github.com/dosfstools/dosfstools/commit/2d3125c4a74895eae1f66b93287031d340324524.patch";
    })
    # reproducible builds fix backported from master
    # (respect SOURCE_DATE_EPOCH)
    # TODO: remove on the next release
    (fetchpatch {
      sha256 = "sha256-Quegj5uYZgACgjSZef6cjrWQ64SToGQxbxyqCdl8C7o=";
      url = "https://github.com/dosfstools/dosfstools/commit/8da7bc93315cb0c32ad868f17808468b81fa76ec.patch";
    })
    ./gettext-0.25.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    gettext
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  configureFlags = [ "--enable-compat-symlinks" ];
  doCheck = true;
  nativeCheckInputs = [ xxd ];

  meta = {
    description = "Utilities for creating and checking FAT and VFAT file systems";
    homepage = "https://github.com/dosfstools/dosfstools";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
})
