{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  cmake,
  fetchpatch,
  freetype,
  libx11,
  libxdmcp,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  libxrandr,
  libxrender,
  nixosTests,
  pkg-config,
  python3,
  runtimeShell,
  xdotool,
  xorg-server,
  xsetroot,
  xterm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "herbstluftwm";
  version = "0.9.5";

  src = fetchurl {
    url = "https://herbstluftwm.org/tarballs/herbstluftwm-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-stRgCQnlvs5a1jgY37MLsZ/SrJ9ShHsaenStQEBxgQU=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  patches = [
    ./test-path-environment.patch
    # Adjust tests for compatibility with gcc 12 (https://github.com/herbstluftwm/herbstluftwm/issues/1512)
    # Can be removed with the next release (>0.9.5).
    (fetchpatch {
      hash = "sha256-uI6ErfDitT2Tw0txx4lMSBn/jjiiyL4Qw6AJa/CTh1E=";
      url = "https://github.com/herbstluftwm/herbstluftwm/commit/8678168c7a3307b1271e94974e062799e745ab40.patch";
    })
    # Fix tests with recent Xorg, can be removed with the next release (<0.9.5)
    # Details here: https://github.com/herbstluftwm/herbstluftwm/issues/1560
    (fetchpatch {
      hash = "sha256-srulWJQ9zTR4Kdxo40AdHND4nexDe2PDSR69yWsOpVA=";
      url = "https://github.com/herbstluftwm/herbstluftwm/commit/1a6e8ee24eac671569f54bfec22ab47ff285a52c.patch";
    })
    # Fix build with GCC 15 (missing #include <stdint.h>), can be removed with the next release (>0.9.5)
    (fetchpatch {
      hash = "sha256-mrViVcW3jZes1QMn5It0t2WfLfwl/WNF6k9yz1fm/Gs=";
      url = "https://github.com/herbstluftwm/herbstluftwm/commit/8ff75588a750704ae06ad59b843eb88138c95653.patch";
    })
  ];

  postPatch = ''
    patchShebangs doc/gendoc.py

    # fix /etc/xdg/herbstluftwm paths in documentation and scripts
    grep -rlZ /etc/xdg/herbstluftwm share/ doc/ scripts/ | while IFS="" read -r -d "" path; do
      substituteInPlace "$path" --replace /etc/xdg/herbstluftwm $out/etc/xdg/herbstluftwm
    done

    # fix shebang in generated scripts
    substituteInPlace tests/conftest.py --replace "/usr/bin/env bash" ${runtimeShell}
    substituteInPlace tests/test_herbstluftwm.py --replace "/usr/bin/env bash" ${runtimeShell}
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libx11
    libxext
    libxinerama
    libxrandr
    libxft
    libxrender
    libxdmcp
    libxfixes
    freetype
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONF_PREFIX=${placeholder "out"}/etc"
  ];

  doCheck = true;

  nativeCheckInputs = [
    (python3.withPackages (
      ps: with ps; [
        ewmh
        pytest
        python-xlib
      ]
    ))
    xdotool
    xorg-server
    xsetroot
    xterm
    python3.pkgs.pytestCheckHook
  ];

  # make the package's module available
  preCheck = ''
    export PYTHONPATH="$PYTHONPATH:../python"
  '';

  depsBuildBuild = [
    asciidoc
  ];

  disabledTests = [
    "test_autostart" # $PATH problems
    "test_wmexec_to_other" # timeouts in sandbox
    "test_rules" # timeouts
  ];

  enabledTestPaths = [ "../tests" ];

  passthru = {
    tests.herbstluftwm = nixosTests.herbstluftwm;
  };

  meta = {
    description = "Manual tiling window manager for X";
    homepage = "https://herbstluftwm.org/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thibautmarty ];
    platforms = lib.platforms.linux;
  };
})
