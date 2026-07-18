{
  lib,
  fetchcvs,
  version,
}:

fetchcvs {
  cvsRoot = ":pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot";
  hash = "sha256-+onT/ajWayaKALucaZBqoiEkvBBI400Fs2OCtMf/bYU=";
  module = "src";
  tag = "netbsd-${lib.replaceStrings [ "." ] [ "-" ] version}-RELEASE";
}
