{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  jheiling-extras,
  jheiling-js,
}:
build-idris-package {
  pname = "electron";
  version = "2016-03-07";

  src = fetchFromGitHub {
    owner = "jheiling";
    repo = "idris-electron";
    rev = "f0e86f52b8e5a546a2bf714709b659c1c0b04395";
    sha256 = "1rpa7yjvfpzl06h0qbk54jd2n52nmgpf7nq5aamcinqh7h5gbiwn";
  };

  idrisDeps = [
    contrib
    jheiling-extras
    jheiling-js
  ];

  meta = {
    description = "Electron bindings for Idris";
    homepage = "https://github.com/jheiling/idris-electron";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
