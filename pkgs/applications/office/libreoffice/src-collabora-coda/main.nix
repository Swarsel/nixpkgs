{ fetchgit, ... }:
fetchgit {
  fetchSubmodules = false;
  hash = "sha256-wQYMqHZVxCst3fIZY2pd60QZkTaiZ+rOPnA+gDGyEYU=";
  rev = "coda-25.04.9.2-2";
  url = "https://gerrit.libreoffice.org/core";
}
