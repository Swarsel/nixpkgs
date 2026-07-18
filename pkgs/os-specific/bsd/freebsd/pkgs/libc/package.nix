{
  csu,
  i18n,
  include,
  libcMinimal,
  libcrypt,
  libdevstat,
  libdl,
  libelf,
  libexecinfo,
  libgcc,
  libiconvModules,
  libkvm,
  libmd,
  libmemstat,
  libprocstat,
  librpcsvc,
  librt,
  libssp_nonshared,
  libthr,
  libutil,
  msun,
  rtld-elf,
  symlinkJoin,
  baseModules ? [
    include
    csu
    libcMinimal
    libssp_nonshared
    libgcc
    libmd
    libthr
    msun
    librpcsvc
    libutil
    librt
    libcrypt
    libelf
    libexecinfo
    libkvm
    libmemstat
    libprocstat
    libdevstat
    libiconvModules
    libdl
    i18n
    rtld-elf
  ],
  extraModules ? [ ],
}:

symlinkJoin {
  inherit (libcMinimal) version;
  pname = "libc";
  paths = baseModules ++ extraModules;
}
