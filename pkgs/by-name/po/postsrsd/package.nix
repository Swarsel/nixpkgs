{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libconfuse,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "postsrsd";
  version = "2.2.7";

  src = fetchFromGitHub {
    owner = "roehling";
    repo = "postsrsd";
    tag = finalAttrs.version;
    hash = "sha256-xBVkhhnLBzCaMFrYze+MdHDJQPJefQdr6jJDTVmN1dU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libconfuse
  ];

  cmakeFlags = [
    (lib.cmakeBool "GENERATE_SRS_SECRET" false)
    (lib.cmakeBool "INSTALL_SYSTEMD_SERVICE" false)
    (lib.cmakeFeature "FETCHCONTENT_TRY_FIND_PACKAGE_MODE" "ALWAYS")
  ];

  meta = {
    description = "Postfix Sender Rewriting Scheme daemon";
    homepage = "https://github.com/roehling/postsrsd";
    changelog = "https://github.com/roehling/postsrsd/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.hexa ];
    platforms = lib.platforms.all;
    mainProgram = "postsrsd";
  };
})
