{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "twitch-chat-downloader";
  version = "2.5.5";

  # NOTE: Using maintained fork because upstream has stopped working, and it has
  # not been updated in a while.
  # https://github.com/PetterKraabol/Twitch-Chat-Downloader/issues/142
  src = fetchFromGitHub {
    owner = "TheDrHax";
    repo = "twitch-chat-downloader";
    rev = finalAttrs.version;
    hash = "sha256-9wIp0uttVBOdexOMb8VvpUEEdZ97SGSlZcFQ4jM/tqM=";
  };

  postPatch = ''
    # Update client ID for Twitch changes
    # See: <https://github.com/TheDrHax/Twitch-Chat-Downloader/pull/16>
    substituteInPlace tcd/example.settings.json \
      --replace-fail jzkbprff40iqj646a697cyrvl0zt2m6 kd1unb4b3q4t58fwlpcbzcbnm76a8fp
  '';

  doCheck = false; # no tests
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    iso8601
    progressbar2
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "tcd" ];

  meta = {
    description = "Twitch Chat Downloader";
    homepage = "https://github.com/TheDrHax/Twitch-Chat-Downloader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ assistant ];
    mainProgram = "tcd";
  };
})
