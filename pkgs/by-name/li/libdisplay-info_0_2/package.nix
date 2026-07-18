{
  fetchFromGitLab,
  libdisplay-info,
}:

libdisplay-info.overrideAttrs (
  finalAttrs: oldAttrs: {
    version = "0.2.0";

    src = fetchFromGitLab {
      owner = "emersion";
      repo = "libdisplay-info";
      rev = finalAttrs.version;
      sha256 = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
      domain = "gitlab.freedesktop.org";
    };
  }
)
