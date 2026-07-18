{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cppunit,
  libiconv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpp-utilities";
  version = "5.34.2";

  src = fetchFromGitHub {
    owner = "Martchus";
    repo = "cpp-utilities";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-8nmbA8DGQfP55GD1EETGeeJHQb6Wjs+3uvqOH9AYjZc=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv # needed on Darwin, see https://github.com/Martchus/cpp-utilities/issues/4
  ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];
  # tests fail on Darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ cppunit ];

  # Otherwise, tests fail since the resulting shared object libc++utilities.so is only available in PWD of the make files
  preCheck = ''
    checkFlagsArray+=(
      "LD_LIBRARY_PATH=$PWD"
    )
  '';

  meta = {
    description = "Common C++ classes and routines used by @Martchus' applications featuring argument parser, IO and conversion utilities";
    homepage = "https://github.com/Martchus/cpp-utilities";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
