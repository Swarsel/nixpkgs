{
  lib,
  stdenv,
  fetchurl,
  cmake,
  gpgme,
  libgpg-error,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpgmepp";
  version = "2.1.0";

  src = fetchurl {
    url = "mirror://gnupg/gpgmepp/gpgmepp-${finalAttrs.version}.tar.xz";
    hash = "sha256-V/gERo8CBFBLFyxrE5ywUSS0JjvnrVFJMsfExQYqFuI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-Fix-handling-of-absolute-install-dirs-in-.pc-install.patch
    ./0001-Don-t-hardcode-include-as-includedir.patch
  ];

  postPatch = ''
    # remove -unknown suffix from pkgconfig version
    substituteInPlace cmake/modules/G10GetFullVersion.cmake \
      --replace-fail '"''${version}-unknown"' '"''${version}"'
  '';

  nativeBuildInputs = [
    cmake
  ];

  propagatedBuildInputs = [
    gpgme
    libgpg-error
  ];

  passthru.tests = {
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };
  };

  meta = {
    description = "C++ bindings/wrapper for GPGME";
    homepage = "https://dev.gnupg.org/source/gpgmepp";
    changelog = "https://dev.gnupg.org/source/gpgmepp/browse/master/NEWS;gpgmepp-${finalAttrs.version}?as=remarkup";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "gpgmepp" ];
  };
})
