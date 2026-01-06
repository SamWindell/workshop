{ pkgs ? import <nixpkgs> {} }:

let
  jdk = pkgs.jdk25_headless;
in

pkgs.maven.buildMavenPackage rec {
  pname = "convertwithmoss";
  version = "15.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "git-moss";
    repo = "ConvertWithMoss";
    rev = version;
    hash = "sha256-91EtTRg0XOAofWiTciKwirmT0A1qJBFAid7jk6Z5sag=";
  };

  inherit jdk;

  mvnHash = "sha256-EFvYJIPdcW4LkzpcV8EVsDPRibN783FomXl1M24iWjo=";
  mvnJdk = jdk;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  buildInputs = with pkgs; [
    glib
    glibc
    gsettings-desktop-schemas
    javaPackages.openjfx25
    libglibutil
    xorg.libXxf86vm
    jdk
  ];

  GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  # Fix for "date 1980-01-01T00:00:00Z is not within the valid range" error
  SOURCE_DATE_EPOCH = "315532802";

  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    install -dm755 $out/share/${pname}

    # Copy the main jar
    cp target/lib/convertwithmoss-*.jar $out/share/${pname}/convertwithmoss.jar

    # Copy all dependency jars (excluding the main jar which we already copied)
    for jar in target/lib/*.jar; do
      if [[ ! "$jar" =~ convertwithmoss-.*\.jar ]]; then
        cp "$jar" $out/share/${pname}/
      fi
    done

    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.desktop -t $out/share/applications/
    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.appdata.xml -t $out/share/metainfo/
    install -Dm644 icons/convertwithmoss.png -t $out/share/pixmaps/

    makeWrapper ${jdk}/bin/java \
        $out/bin/${pname} \
        --prefix PATH : ${jdk}/bin \
        --add-flags "-Xmx64G" \
        --add-flags "--module-path ${pkgs.javaPackages.openjfx25}/lib:$out/share/${pname}" \
        --add-flags "--add-modules javafx.controls,javafx.graphics" \
        --add-flags "-jar $out/share/${pname}/convertwithmoss.jar"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A tool for converting multi-sample from one format to another";
    longDescription = ''
      Converts multisamples from a source format (WAV, multisample, KMP, wavestate,
      NKI, SFZ, SoundFont 2) to a different destination format.
    '';
    homepage = "https://github.com/git-moss/ConvertWithMoss";
    license = licenses.lgpl3Only;
    maintainers = [ ];
    mainProgram = "convertwithmoss";
    platforms = platforms.linux;
  };
}
