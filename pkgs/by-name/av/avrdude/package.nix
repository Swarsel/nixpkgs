{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  callPackage,
  cmake,
  elfutils,
  flex,
  hidapi,
  libftdi1,
  libserialport,
  libusb-compat-0_1,
  libusb1,
  pkg-config,
  readline,
  texi2html,
  texinfo,
  texliveMedium,
  unixtools,
  # Documentation building doesn't work on Darwin. It fails with:
  #   Undefined subroutine &Locale::Messages::dgettext called in ... texi2html
  #
  # https://github.com/NixOS/nixpkgs/issues/224761
  docSupport ? (!stdenv.hostPlatform.isDarwin),
}:

let
  useElfutils = lib.meta.availableOn stdenv.hostPlatform elfutils;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "avrdude";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "avrdudes";
    repo = "avrdude";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-wUKUlJYbBo3oBUs/hWWN2epj4ji/9gsOGr5wrF9kz34=";
  };

  postPatch = lib.optionalString (!useElfutils) ''
    # vendored libelf is a static library
    sed -i "s/PREFERRED_LIBELF elf/PREFERRED_LIBELF libelf.a elf/" CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    bison
    flex
    pkg-config
  ]
  ++ lib.optionals docSupport [
    unixtools.more
    texliveMedium
    texinfo
    texi2html
  ];

  buildInputs = [
    (if useElfutils then elfutils else finalAttrs.finalPackage.passthru.libelf)
    hidapi
    libusb1
    libftdi1
    libserialport
    readline
    libusb-compat-0_1
  ];

  # Not used:
  #   -DHAVE_LINUXGPIO=ON    because it's incompatible with libgpiod 2.x
  cmakeFlags =
    lib.optionals docSupport [ "-DBUILD_DOC=ON" ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "-DHAVE_LINUXSPI=ON"
      "-DHAVE_PARPORT=ON"
    ];

  passthru = {
    # Vendored and mutated copy of libelf for avrdudes use.
    # Produces a static library only.
    libelf = callPackage ./libelf.nix { };
  };

  meta = {
    description = "Command-line tool for programming Atmel AVR microcontrollers";

    longDescription = ''
      AVRDUDE (AVR Downloader/UploaDEr) is an utility to
      download/upload/manipulate the ROM and EEPROM contents of AVR
      microcontrollers using the in-system programming technique (ISP).
    '';

    homepage = "https://www.nongnu.org/avrdude/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "avrdude";
  };
})
