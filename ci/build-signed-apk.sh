#!/usr/bin/env bash
# Ejecutar desde la raíz del repositorio; secretos inyectados por Jenkins.
set +x
set -euo pipefail
export LC_ALL=C
umask 077

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

readonly expected_certificate='15264c0e108f783224d595daaf19e0ce63fe43668fe48dba69e3c95fc79aa49a'
readonly properties='android/key.properties'
readonly apk='build/app/outputs/flutter-apk/app-release.apk'

[[ -d android ]] || fail 'Ejecuta el script desde la raíz del repositorio.'
[[ ! -e "$properties" && ! -L "$properties" ]] ||
    fail 'Ya existe android/key.properties; no se sobrescribirá.'
[[ -n "${ANDROID_KEYSTORE_FILE:-}" && -f "$ANDROID_KEYSTORE_FILE" && -r "$ANDROID_KEYSTORE_FILE" ]] ||
    fail 'El almacén de firma no existe o no se puede leer.'
[[ -n "${ANDROID_KEYSTORE_PASSWORD:-}" ]] || fail 'Falta la contraseña de firma.'

# Contrato de esta credencial: contraseña aleatoria alfanumérica, como se generó.
# Rechazar otros formatos evita interpretarlos incorrectamente como Java Properties.
[[ "$ANDROID_KEYSTORE_PASSWORD" =~ ^[A-Za-z0-9]+$ ]] ||
    fail 'Esta configuración requiere una contraseña alfanumérica; no se ha mostrado ni modificado.'
[[ "$ANDROID_KEYSTORE_FILE" = /* && "$ANDROID_KEYSTORE_FILE" =~ ^[[:print:]]+$ && "$ANDROID_KEYSTORE_FILE" != *\\* ]] ||
    fail 'La ruta del almacén debe ser absoluta, ASCII imprimible y sin barras inversas.'

command -v flutter >/dev/null || fail 'Flutter no está disponible en PATH.'
sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
[[ -n "$sdk" && -d "$sdk/build-tools" ]] || fail 'No se encuentra Android SDK build-tools.'

# Elegir la versión estable más reciente que incluya apksigner.
shopt -s nullglob
signers=()
for candidate in "$sdk"/build-tools/*/apksigner; do
    version="${candidate%/apksigner}"
    version="${version##*/}"
    if [[ -x "$candidate" && "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        signers+=("$candidate")
    fi
done
[[ ${#signers[@]} -gt 0 ]] || fail 'No se encuentra apksigner en una versión estable de build-tools.'
mapfile -t signers < <(printf '%s\n' "${signers[@]}" | sort -V)
readonly apksigner="${signers[-1]}"

# Creación exclusiva: nunca sobrescribir una configuración local ni un enlace.
(set -o noclobber; : > "$properties") || fail 'No se pudo crear key.properties de forma exclusiva.'
cleanup() {
    rm -f -- "$properties"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

printf 'storeFile=%s\nstorePassword=%s\nkeyAlias=ciclotrack-release\nkeyPassword=%s\n' \
    "$ANDROID_KEYSTORE_FILE" "$ANDROID_KEYSTORE_PASSWORD" "$ANDROID_KEYSTORE_PASSWORD" \
    > "$properties"

# No permitir que un artefacto antiguo se confunda con el resultado de este build.
rm -f -- "$apk"
# Evitar persistir la configuración de firma en la caché de configuración de Gradle.
export GRADLE_OPTS="${GRADLE_OPTS:-} -Dorg.gradle.configuration-cache=false -Dorg.gradle.daemon=false"
flutter build apk --release
[[ -s "$apk" ]] || fail 'Flutter no ha generado el APK release esperado.'

# El proceso debe terminar correctamente Y usar exactamente el certificado esperado.
verification="$("$apksigner" verify --verbose --print-certs "$apk")"
printf '%s\n' "$verification"
digests=()
while IFS= read -r line; do
    if [[ "$line" =~ ^Signer\ \#[0-9]+\ certificate\ SHA-256\ digest:\ ([[:xdigit:]]{64})[[:space:]]*$ ]]; then
        digests+=("${BASH_REMATCH[1],,}")
    fi
done <<< "$verification"
[[ ${#digests[@]} -eq 1 ]] || fail 'Se esperaba exactamente un certificado firmante.'
[[ "${digests[0]}" == "$expected_certificate" ]] || fail 'El certificado del APK no coincide con el autorizado.'
printf 'Firma verificada: certificado de publicación de CicloTrack.\n'
