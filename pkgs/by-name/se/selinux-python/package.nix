{
  lib,
  stdenv,
  fetchurl,
  gettext,
  libselinux,
  libsemanage,
  libsepol,
  python3,
  setools,
}:

let
  selinuxPython3 = python3.withPackages (
    ps: with ps; [
      pip
      setuptools
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  inherit (libsepol) se_url;
  pname = "selinux-python";
  version = "3.10";

  src = fetchurl {
    url = "${finalAttrs.se_url}/${finalAttrs.version}/selinux-python-${finalAttrs.version}.tar.gz";
    hash = "sha256-nQpbafL7zOjlzNjg8X1W9x5gBadWOG+Ps2wx+UJBkaI=";
  };

  postPatch = ''
    # We would like to disable build isolation so we use the provided setuptools (this is part of a `pip install` command)
    substituteInPlace sepolicy/Makefile --replace-fail 'echo --root' 'echo --no-build-isolation --root'

    # Replace hardcoded paths.
    substituteInPlace sepolgen/src/share/Makefile --replace-fail "/var/lib/sepolgen" \
                                                            '$(PREFIX)/var/lib/sepolgen'
    substituteInPlace po/Makefile --replace-fail "/usr/bin/install" "install"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    selinuxPython3
    python3.pkgs.wrapPython
    gettext
  ];

  buildInputs = [
    python3
    libsepol
    libselinux
  ];

  makeFlags = [
    "PREFIX=$(out)"
    # This makes pip successfully install it (note the test -n "$(DESTDIR)" nonsense)
    # https://github.com/SELinuxProject/selinux/blob/d1e3170556e1023e07b3c071ce89543ead6ba6f8/python/sepolicy/Makefile#L30
    "DESTDIR=/"
    "LOCALEDIR=$(out)/share/locale"
    "BASHCOMPLETIONDIR=$(out)/share/bash-completion/completions"
    "PYTHON=python"
    "PYTHONLIBDIR=$(out)/${python3.sitePackages}"
    "LIBSEPOLA=${lib.getLib libsepol}/lib/libsepol.a"
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    # Version hasn't changed in 17 years, if it suddenly does these tests deserve to break
    $out/bin/audit2allow --version | grep -Fm1 'audit2allow .1'
    $out/bin/audit2why --version | grep -Fm1 'audit2allow .1'
    $out/bin/sepolgen-ifgen --version | grep -Fm1 'sepolgen-ifgen .1'

    # "chcat: Requires a mls enabled system" or help, which includes chcat
    { $out/bin/chcat --help || true; } | grep -Fm1 'chcat'

    $out/bin/semanage --help | grep -Fm1 'semanage'
    $out/bin/sepolgen --help | grep -Fm1 'sepolicy'
    $out/bin/sepolicy --help | grep -Fm1 'sepolicy'

    # Should at least run, even if we can't provide it a policy file and need to provide /dev/zero
    { $out/bin/sepolgen-ifgen-attr-helper test /dev/null 2>&1 || true; } | grep -Fm1 'error(s) encountered' >/dev/null

    runHook postInstallCheck
  '';

  preFixup = ''
    patchShebangs --host $out/bin/*
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonPath = [
    python3.pkgs.libselinux.py
    libsemanage.py
    setools
  ];

  meta = {
    inherit (libsepol.meta) maintainers;
    description = "SELinux policy core utilities written in Python";
    homepage = "https://selinuxproject.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
