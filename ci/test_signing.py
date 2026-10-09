"""Isolated shell workflow tests. Flutter/apksigner are explicit test doubles.
These tests do NOT compile Android or verify a real APK signature.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('build-signed-apk.sh')
DIGEST = '15264c0e108f783224d595daaf19e0ce63fe43668fe48dba69e3c95fc79aa49a'


class SigningWorkflowTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'android').mkdir()
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        tool = self.root / 'sdk/build-tools/36.0.0'
        tool.mkdir(parents=True)
        self.key = self.root / 'credential file.jks'
        self.key.write_text('TEST FIXTURE ONLY - NOT A KEYSTORE')
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                        ANDROID_HOME=str(self.root / 'sdk'), ANDROID_SDK_ROOT='',
                        ANDROID_KEYSTORE_FILE=str(self.key),
                        ANDROID_KEYSTORE_PASSWORD='TestPassword123',
                        TEST_DIGEST=DIGEST, TEST_BUILD_FAIL='0', TEST_VERIFY_FAIL='0',
                        TEST_EXTRA_SIGNER='0')
        self.program(self.bin / 'flutter', '''#!/usr/bin/env bash
set -eu
[ "$*" = "build apk --release" ]
[ "$(stat -c %a android/key.properties)" = 600 ]
grep -Fx "storeFile=$ANDROID_KEYSTORE_FILE" android/key.properties >/dev/null
grep -Fx "keyAlias=ciclotrack-release" android/key.properties >/dev/null
grep -Fx "storePassword=$ANDROID_KEYSTORE_PASSWORD" android/key.properties >/dev/null
grep -Fx "keyPassword=$ANDROID_KEYSTORE_PASSWORD" android/key.properties >/dev/null
if [ "$TEST_BUILD_FAIL" = 1 ]; then exit 12; fi
mkdir -p build/app/outputs/flutter-apk
printf 'TEST APK FIXTURE - NOT AN ANDROID ARTIFACT' > build/app/outputs/flutter-apk/app-release.apk
''')
        self.program(tool / 'apksigner', '''#!/usr/bin/env bash
set -eu
[ "$1" = verify ]
if [ "$TEST_VERIFY_FAIL" = 1 ]; then exit 13; fi
printf 'Signer #1 certificate SHA-256 digest: %s\n' "$TEST_DIGEST"
if [ "$TEST_EXTRA_SIGNER" = 1 ]; then
    printf 'Signer #2 certificate SHA-256 digest: %s\n' "$TEST_DIGEST"
fi
''')

    def program(self, path, content):
        path.write_text(content)
        path.chmod(0o700)

    def run_script(self):
        return subprocess.run(['bash', str(SCRIPT)], cwd=self.root,
                              env=self.env, text=True, capture_output=True)

    def test_success_cleans_properties(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Firma verificada', result.stdout)
        self.assertFalse((self.root / 'android/key.properties').exists())
        self.assertNotIn(self.env['ANDROID_KEYSTORE_PASSWORD'], result.stdout + result.stderr)

    def test_wrong_certificate_rejected(self):
        self.env['TEST_DIGEST'] = '0' * 64
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('certificado', result.stderr)
        self.assertFalse((self.root / 'android/key.properties').exists())

    def test_additional_signer_rejected(self):
        self.env['TEST_EXTRA_SIGNER'] = '1'
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)

    def test_build_failure_cleans_properties(self):
        self.env['TEST_BUILD_FAIL'] = '1'
        self.assertEqual(self.run_script().returncode, 12)
        self.assertFalse((self.root / 'android/key.properties').exists())

    def test_signature_verifier_failure_rejected(self):
        self.env['TEST_VERIFY_FAIL'] = '1'
        self.assertEqual(self.run_script().returncode, 13)
        self.assertFalse((self.root / 'android/key.properties').exists())

    def test_existing_properties_preserved(self):
        path = self.root / 'android/key.properties'
        path.write_text('LOCAL CONFIGURATION')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(path.read_text(), 'LOCAL CONFIGURATION')

    def test_dangling_symlink_preserved(self):
        path = self.root / 'android/key.properties'
        path.symlink_to(self.root / 'absent')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(path.is_symlink())
        self.assertFalse((self.root / 'absent').exists())

    def test_missing_keystore_rejected(self):
        self.key.unlink()
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('almacén', result.stderr)

    def test_unsupported_password_rejected_without_disclosure(self):
        self.env['ANDROID_KEYSTORE_PASSWORD'] = 'DoNotPrint\\Password'
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(self.env['ANDROID_KEYSTORE_PASSWORD'], result.stdout + result.stderr)
        self.assertFalse((self.root / 'android/key.properties').exists())

    def test_old_apk_removed_before_failed_build(self):
        apk = self.root / 'build/app/outputs/flutter-apk/app-release.apk'
        apk.parent.mkdir(parents=True)
        apk.write_text('STALE TEST FIXTURE')
        self.env['TEST_BUILD_FAIL'] = '1'
        self.assertEqual(self.run_script().returncode, 12)
        self.assertFalse(apk.exists())


if __name__ == '__main__':
    unittest.main(verbosity=2)
