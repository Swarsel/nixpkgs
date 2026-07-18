# See https://gitlab.com/porn-vault/porn-vault/-/blob/dev/config.example.json
{
  auth = {
    password = null;
  };

  binaries = {
    ffmpeg = "ffmpeg";
    ffprobe = "ffprobe";

    imagemagick = {
      convertPath = "convert";
      identifyPath = "identify";
      montagePath = "montage";
    };

    izzyPort = 8000;
  };

  import = {
    images = [
      {
        enable = true;
        exclude = [ ];

        extensions = [
          ".jpg"
          ".jpeg"
          ".png"
          ".gif"
        ];

        include = [ ];
        path = "/media/porn-vault/images";
      }
    ];

    scanInterval = 10800000;

    videos = [
      {
        enable = true;
        exclude = [ ];

        extensions = [
          ".mp4"
          ".mov"
          ".webm"
        ];

        include = [ ];
        path = "/media/porn-vault/videos";
      }
    ];
  };

  log = {
    level = "debug";
    maxFiles = "5";
    maxSize = "20m";

    writeFile = [
      {
        level = "debug";
        prefix = "errors-";
        silent = false;
      }
    ];
  };

  matching = {
    applyActorLabels = [
      "event:actor:create"
      "event:actor:find-unmatched-scenes"
      "plugin:actor:create"
      "event:scene:create"
      "plugin:scene:create"
      "event:image:create"
      "plugin:marker:create"
      "event:marker:create"
    ];

    applySceneLabels = true;

    applyStudioLabels = [
      "event:studio:create"
      "event:studio:find-unmatched-scenes"
      "plugin:studio:create"
      "event:scene:create"
      "plugin:scene:create"
    ];

    extractSceneActorsFromFilepath = true;
    extractSceneLabelsFromFilepath = true;
    extractSceneMoviesFromFilepath = true;
    extractSceneStudiosFromFilepath = true;
    matchCreatedActors = true;
    matchCreatedLabels = true;
    matchCreatedStudios = true;

    matcher = {
      options = {
        camelCaseWordGroups = true;
        enableWordGroups = true;

        filepathSeparators = [
          "[/\\\\&]"
        ];

        groupSeparators = [
          "[\\s',()[\\]{}*\\.]"
        ];

        ignoreDiacritics = true;
        ignoreSingleNames = false;
        overlappingMatchPreference = "longest";
        wordSeparatorFallback = true;

        wordSeparators = [
          "[-_]"
        ];
      };

      type = "word";
    };
  };

  persistence = {
    backup = {
      enable = true;
      maxAmount = 10;
    };

    libraryPath = "/media/porn-vault/lib";
  };

  plugins = {
    allowActorThumbnailOverwrite = false;
    allowMovieThumbnailOverwrite = false;
    allowSceneThumbnailOverwrite = false;
    allowStudioThumbnailOverwrite = false;
    createMissingActors = false;
    createMissingLabels = false;
    createMissingMovies = false;
    createMissingStudios = false;

    events = {
      actorCreated = [ ];
      actorCustom = [ ];
      movieCustom = [ ];
      sceneCreated = [ ];
      sceneCustom = [ ];
      studioCreated = [ ];
      studioCustom = [ ];
    };

    markerDeduplicationThreshold = 5;
    register = { };
  };

  processing = {
    generateImageThumbnails = true;
    generatePreviews = true;
    readImagesOnImport = false;
  };

  server = {
    https = {
      enable = false;
      certificate = "";
      key = "";
    };
  };

  transcode = {
    h264 = {
      crf = 23;
      preset = "veryfast";
    };

    hwaDriver = null;
    vaapiDevice = "/dev/dri/renderD128";

    webm = {
      cpuUsed = 3;
      crf = 31;
      deadline = "realtime";
    };
  };
}
