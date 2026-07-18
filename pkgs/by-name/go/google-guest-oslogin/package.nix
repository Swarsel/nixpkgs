{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  json_c,
  nixosTests,
  pam,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "google-guest-oslogin";
  version = "20260214.00";

  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "guest-oslogin";
    rev = finalAttrs.version;
    hash = "sha256-xMelRZ3OGQwZLOC03TjpUcXWqsViVWffIZcSVLz58S4=";
  };

  postPatch = ''
    # change sudoers dir from /var/google-sudoers.d to /run/google-sudoers.d (managed through systemd-tmpfiles)
    substituteInPlace src/oslogin_utils.cc --replace-fail /var/google-sudoers.d /run/google-sudoers.d
    # fix "User foo not allowed because shell /bin/bash does not exist"
    substituteInPlace src/include/compat.h --replace-fail /bin/bash /run/current-system/sw/bin/bash
  '';

  buildInputs = [
    curl.dev
    pam
    json_c
  ];

  makeFlags = [
    "VERSION=${finalAttrs.version}"
    "PREFIX=$(out)"
    "MANDIR=$(out)/share/man"
    "SYSTEMDDIR=$(out)/etc/systemd/system"
    "PRESETDIR=$(out)/etc/systemd/system-preset"
    "GOOGLEUSERSDIR=$(out)/google-users.d" # A readme is installed to this directory
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-I${json_c.dev}/include/json-c" ];

  postInstall = ''
    sed -i "s,/usr/bin/,$out/bin/,g" $out/etc/systemd/system/google-oslogin-cache.service
  '';

  enableParallelBuilding = true;

  passthru.tests = {
    inherit (nixosTests) google-oslogin;
  };

  meta = {
    description = "OS Login Guest Environment for Google Compute Engine";
    homepage = "https://github.com/GoogleCloudPlatform/compute-image-packages";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
