{
  lib,
  fetchPypi,
  fetchpatch,
  lynx,
  nixosTests,
  postfix,
  python3,
}:

with python3.pkgs;

buildPythonPackage (finalAttrs: {
  pname = "mailman";
  version = "3.3.10";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-DeR4/PMm8l2TGTjDdE5hxc1nWWtG5bHjuyq/mdVEVjI=";
  };

  patches = [
    (fetchpatch {
      sha256 = "06axmrn74p81wvcki36c7gfj5fp5q15zxz2yl3lrvijic7hbs4n2";
      url = "https://gitlab.com/mailman/mailman/-/commit/4b206e2a5267a0e17f345fd7b2d957122ba57566.patch";
    })
    (fetchpatch {
      sha256 = "0vyw87s857vfxbf7kihwb6w094xyxmxbi1bpdqi3ybjamjycp55r";
      url = "https://gitlab.com/mailman/mailman/-/commit/9613154f3c04fa2383fbf017031ef263c291418d.patch";
    })
    (fetchpatch {
      hash = "sha256-KCXVP+5zqgluUXQCGmMRC+G1hEDnFBlTUETGpmFDOOk=";
      name = "python-3.13.patch";
      url = "https://gitlab.com/mailman/mailman/-/commit/685d9a7bdbd382d9e8d4a2da74bd973e93356e05.patch";
    })
    ./log-stderr.patch
  ];

  postPatch = ''
    substituteInPlace src/mailman/config/postfix.cfg \
      --replace /usr/sbin/postmap ${postfix}/bin/postmap
    substituteInPlace src/mailman/config/schema.cfg \
      --replace /usr/bin/lynx ${lynx}/bin/lynx

    # Backport of
    # https://gitlab.com/mailman/mailman/-/commit/3a22537382d41ab3e46b859054547755963b069d.patch
    substituteInPlace pyproject.toml \
      --replace-fail '"nntplib;' '"standard-nntplib;'
  '';

  checkInputs = [
    sphinx
  ];

  build-system = with python3.pkgs; [
    pdm-backend
  ];

  dependencies = with python3.pkgs; [
    aiosmtpd
    alembic
    authheaders
    click
    dnspython
    falcon
    flufl-bounce
    flufl-i18n
    flufl-lock
    gunicorn
    lazr-config
    passlib
    python-dateutil
    requests
    sqlalchemy
    standard-nntplib
    zope-component
    zope-configuration
  ];

  # Mailman assumes that those scripts in $out/bin are Python scripts. Wrapping
  # them in shell code breaks this assumption. Use the wrapped version (see
  # wrapped.nix) if you need the CLI (rather than the Python library).
  #
  # This gives a properly wrapped 'mailman' command plus an interpreter that
  # has all the necessary search paths to execute unwrapped 'master' and
  # 'runner' scripts.
  dontWrapPythonPrograms = true;
  pyproject = true;
  passthru.tests = { inherit (nixosTests) mailman; };

  meta = {
    description = "Free software for managing electronic mail discussion and newsletter lists";
    homepage = "https://www.gnu.org/software/mailman/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
  };
})
