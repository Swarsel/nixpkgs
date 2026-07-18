{
  lib,
  buildPythonPackage,
  # native dependencies
  dbus,
  dbus-glib,
  fetchPypi,
  fetchpatch,
  isPyPy,
  # build-system
  meson,
  meson-python,
  pkg-config,
  python,
}:

lib.fix (
  finalPackage:
  buildPythonPackage rec {
    pname = "dbus-python";
    version = "1.4.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-mRZm5Jj2Db8+Sbi3Z49VWbimUDT99hquYs3s232Jx3A=";
    };

    outputs = [
      "out"
      "dev"
    ];

    patches = [
      # reduce required dependencies
      # https://gitlab.freedesktop.org/dbus/dbus-python/-/merge_requests/23
      (fetchpatch {
        hash = "sha256-Rmj/ByRLiLnIF3JsMBElJugxsG8IARcBdixLhoWgIYU=";
        url = "https://gitlab.freedesktop.org/dbus/dbus-python/-/commit/d5e19698a8d6e1485f05b67a5b2daa2392819aaf.patch";
      })
    ];

    postPatch = ''
      # we provide patchelf natively, not through the python package
      sed -i '/patchelf/d' pyproject.toml

      patchShebangs test/*.sh
    '';

    nativeBuildInputs = [
      dbus # build systems checks for `dbus-run-session` in PATH
      meson
      meson-python
      pkg-config
    ];

    buildInputs = [
      dbus
      dbus-glib
    ];

    mesonFlags = [ (lib.mesonBool "tests" finalPackage.doInstallCheck) ];
    nativeCheckInputs = [ dbus.out ];

    checkPhase = ''
      runHook preCheck

      meson test -C build --no-rebuild --print-errorlogs --timeout-multiplier 0

      runHook postCheck
    '';

    # workaround bug in meson-python
    # https://github.com/mesonbuild/meson-python/issues/240
    postInstall = ''
      mkdir -p $dev/lib
      mv $out/${python.sitePackages}/.dbus_python.mesonpy.libs/pkgconfig/ $dev/lib
    '';

    # make sure the Cflags in the pkgconfig file are correct and make the structure backwards compatible
    postFixup = ''
      ln -s $dev/include/*/dbus_python/dbus-1.0/ $dev/include/dbus-1.0
    '';

    disabled = isPyPy;
    pyproject = true;

    meta = {
      description = "Python DBus bindings";
      homepage = "https://gitlab.freedesktop.org/dbus/dbus-python";
      license = lib.licenses.mit;
      maintainers = [ ];
      platforms = dbus.meta.platforms;
    };
  }
)
