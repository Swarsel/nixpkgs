{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  curl,
  doxygen,
  glib,
  gpgme,
  libselinux,
  libxml2,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  zchunk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librepo";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "rpm-software-management";
    repo = "librepo";
    tag = finalAttrs.version;
    hash = "sha256-KYBHImdGQgf/IZ5FMhzrbBTeZF76AIP3RjVPT3w0oT8=";
  };

  outputs = [
    "out"
    "dev"
    "py"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
  ];

  buildInputs = [
    python3
    libxml2
    glib
    openssl
    curl
    check
    gpgme
    zchunk
    libselinux
  ];

  # librepo/fastestmirror.h includes curl/curl.h, and pkg-config specfile refers to others in here
  propagatedBuildInputs = [
    curl
    gpgme
    libxml2
  ];

  cmakeFlags = [ "-DPYTHON_DESIRED=${lib.substring 0 1 python3.pythonVersion}" ];

  postFixup = ''
    moveToOutput "lib/${python3.libPrefix}" "$py"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library providing C and Python (libcURL like) API for downloading linux repository metadata and packages";
    homepage = "https://rpm-software-management.github.io/librepo/";
    changelog = "https://github.com/rpm-software-management/dnf5/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
