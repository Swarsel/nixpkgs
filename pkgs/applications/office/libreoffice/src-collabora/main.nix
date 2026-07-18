{ fetchgit, ... }:
fetchgit {
  fetchSubmodules = false;
  hash = "sha256-9NE5GCIUUyinteFUBBkmV+ZwT7rfnVvynQqhumlYYEc=";
  tag = "cp-25.04.9-4";
  url = "https://gerrit.libreoffice.org/core";
}
