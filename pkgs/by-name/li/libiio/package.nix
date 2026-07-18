{
  lib,
  stdenv,
  fetchFromGitHub,
  avahi,
  bison,
  cmake,
  flex,
  libaio,
  libusb1,
  libxml2,
  pkg-config,
  python3,
  runtimeShell,
  avahiSupport ? true,
  pythonSupport ? stdenv.hostPlatform.hasSharedLibraries,
}:

stdenv.mkDerivation rec {
  pname = "libiio";
  version = "0.26";

  src = fetchFromGitHub {
    owner = "analogdevicesinc";
    repo = "libiio";
    tag = "v${version}";
    hash = "sha256-nrpGccj9Q3S9wYs0/dHC3YAy5ZvTiPiSUtPY6r5WlaE=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ]
  ++ lib.optional pythonSupport "python";

  # Revert after https://github.com/NixOS/nixpkgs/issues/125008 is
  # fixed properly
  patches = [
    ./cmake-fix-libxml2-find-package.patch
  ];

  postPatch = ''
    patchShebangs libiio.rules.cmakein
  ''
  + lib.optionalString pythonSupport ''
    # Hardcode path to the shared library into the bindings.
    sed "s#@libiio@#$lib/lib/libiio${stdenv.hostPlatform.extensions.sharedLibrary}#g" ${./hardcode-library-path.patch} | patch -p1
  ''
  + lib.optionalString (pythonSupport && stdenv.hostPlatform.isDarwin) ''
    # Because we’re not building the framework, always use the dylib.
    substituteInPlace bindings/python/setup.py.cmakein \
      --replace-fail '"iio" if "Darwin" in _system() else' ""
  '';

  nativeBuildInputs = [
    cmake
    flex
    bison
    pkg-config
  ]
  ++ lib.optionals pythonSupport (
    [
      python3
    ]
    ++ lib.optional python3.isPy3k python3.pkgs.setuptools
  );

  buildInputs = [
    libxml2
    libusb1
  ]
  ++ lib.optional avahiSupport avahi
  ++ lib.optional stdenv.hostPlatform.isLinux libaio;

  cmakeFlags = [
    "-DUDEV_RULES_INSTALL_DIR=${placeholder "out"}/lib/udev/rules.d"
    # osx framework is disabled,
    # the linux-like directory structure is used for proper output splitting
    "-DOSX_PACKAGE=off"
    "-DOSX_FRAMEWORK=off"
  ]
  ++ lib.optionals pythonSupport [
    "-DPython_EXECUTABLE=${python3.pythonOnBuildForHost.interpreter}"
    "-DPYTHON_BINDINGS=on"
  ]
  ++ lib.optionals (!avahiSupport) [
    "-DHAVE_DNS_SD=OFF"
  ];

  postInstall = lib.optionalString pythonSupport ''
    # Move Python bindings into a separate output.
    moveToOutput ${python3.sitePackages} "$python"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = lib.optionals pythonSupport [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [ "iio" ];

  meta = {
    description = "API for interfacing with the Linux Industrial I/O Subsystem";
    homepage = "https://github.com/analogdevicesinc/libiio";
    changelog = "https://github.com/analogdevicesinc/libiio/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
