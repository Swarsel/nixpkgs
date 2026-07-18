{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

let
  # Disabled because tests rely on network requests
  disabledTests = [
    "TestTranscript"
    "TestSimpleTest"
    "TestGetPlaylist"
    "TestGetBigPlaylist"
    "TestDownload_SensitiveContent"
    "TestGetVideo_MultiLanguage"
    "TestParseVideo"
    "TestParse_PublishDate"
    "TestDownload_WhenPlayabilityStatusIsNotOK"
    "TestDownload_Regular"
    "TestYoutube_GetItagInfo"
    "TestClient_httpGetBodyBytes"
    "TestClient_httpGetBodyBytes"
    "TestGetStream"
    "TestGetVideoWithManifestURL"
    "TestWebClientGetVideoWithoutManifestURL"
    "TestGetVideoWithoutManifestURL"
    "TestClient_httpGetBodyBytes"
    "TestDownload_FirstStream"
  ];
in
buildGoModule (finalAttrs: {
  pname = "youtubedr";
  version = "2.10.6";

  src = fetchFromGitHub {
    owner = "kkdai";
    repo = "youtube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rkkqLBH4P5DMrbfsZwVgBjnQG1/fHdjVL4mU6amYUxM=";
  };

  vendorHash = "sha256-DIdDDS8U4UR3ZPmwqrhsOfejUJ4UHmwcr4JCpjkwOzs=";

  checkFlags = [
    "-skip=${lib.concatStringsSep "|" disabledTests}"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "YouTube video download CLI";
    homepage = "https://github.com/kkdai/youtube";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ligerothetiger ];
    mainProgram = "youtubedr";
  };
})
