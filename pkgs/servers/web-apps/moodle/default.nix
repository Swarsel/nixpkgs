{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  writeText,
  plugins ? [ ],
}:

let
  version = "5.1.3";

  versionParts = lib.take 2 (lib.splitVersion version);
  # 4.2 -> 402, 3.11 -> 311
  stableVersion = lib.removePrefix "0" (
    lib.concatMapStrings (
      p:
      if (lib.toInt p) < 10 then
        (lib.concatStrings [
          "0"
          p
        ])
      else
        p
    ) versionParts
  );

  # Reference: https://docs.moodle.org/dev/Plugin_types
  pluginDirs = {
    antivirus = "lib/antivirus";
    assignfeedback = "mod/assign/feedback";
    assignsubmission = "mod/assign/submission";
    atto = "lib/editor/atto/plugins";
    auth = "auth";
    availability = "availability/condition";
    block = "blocks";
    booktool = "mod/book/tool";
    cachelock = "cache/locks";
    cachestore = "cache/stores";
    calendartype = "calendar/type";
    # assignment = "mod/assignment/type"; # Deprecated
    # report = "admin/report"; # Moved to /report
    contenttype = "contentbank/contenttype";
    customfield = "customfield/field";
    datafield = "mod/data/field";
    dataformat = "dataformat";
    datapreset = "mod/data/preset";
    editor = "lib/editor";
    enrol = "enrol";
    fileconverter = "files/converter";
    filter = "filter";
    format = "course/format";
    forumreport = "mod/forum/report";
    # coursereport = "course/report"; # Moved to /report
    gradeexport = "grade/export";
    gradeimport = "grade/import";
    gradereport = "grade/report";
    gradingform = "grade/grading/form";
    h5plib = "h5p/h5plib";
    local = "local";
    logstore = "admin/tool/log/store";
    ltiservice = "mod/lti/service";
    ltisource = "mod/lti/source";
    media = "media/player";
    message = "message/output";
    mlbackend = "lib/mlbackend";
    mnetservice = "mnet/service";
    mod = "mod";
    plagiarism = "plagiarism";
    portfolio = "portfolio";
    profilefield = "user/profile/field";
    qbank = "question/bank";
    qbehaviour = "question/behaviour";
    qformat = "question/format";
    qtype = "question/type";
    quiz = "mod/quiz/report";
    quizaccess = "mod/quiz/accessrule";
    report = "report";
    repository = "repository";
    scormreport = "mod/scorm/report";
    search = "search/engine";
    theme = "theme";
    tinymce = "lib/editor/tinymce/plugins";
    tool = "admin/tool";
    webservice = "webservice";
    workshopallocation = "mod/workshop/allocation";
    workshopeval = "mod/workshop/eval";
    workshopform = "mod/workshop/form";
  };

in
stdenv.mkDerivation rec {
  inherit version;
  pname = "moodle";

  src = fetchurl {
    url = "https://download.moodle.org/download.php/direct/stable${stableVersion}/${pname}-${version}.tgz";
    hash = "sha256-7N2aPfPdZu4WXmZeetup7hL/8XdCcH+5NwTdHxvG0qk=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/moodle
    cp -r . $out/share/moodle
    cp ${phpConfig} $out/share/moodle/config.php

    ${lib.concatStringsSep "\n" (
      map (
        p:
        let
          dir =
            if (lib.hasAttr p.pluginType pluginDirs) then
              pluginDirs.${p.pluginType}
            else
              throw "unknown moodle plugin type";
          # we have to copy it, because the plugins have refrences to .. inside
        in
        ''
          mkdir -p $out/share/moodle/${dir}/${p.name}
          cp -r ${p}/* $out/share/moodle/${dir}/${p.name}/
        ''
      ) plugins
    )}

    runHook postInstall
  '';

  phpConfig = writeText "config.php" ''
    <?php
      return require(getenv('MOODLE_CONFIG'));
    ?>
  '';

  passthru.tests = {
    inherit (nixosTests) moodle;
  };

  meta = {
    description = "Free and open-source learning management system (LMS) written in PHP";
    homepage = "https://moodle.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
