#!/usr/bin/env python3
"""Build with Apple's Command Line Tools. No package downloads or developer subscription."""
from pathlib import Path
import plistlib
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build'
APP = BUILD / '轻右键.app'
EXT = APP / 'Contents/PlugIns/QingFinderExtension.appex'


def run(*args):
    subprocess.run([str(a) for a in args], check=True)


def plist(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(plistlib.dumps(value))


for bundle in [APP, EXT]:
    (bundle / 'Contents/MacOS').mkdir(parents=True, exist_ok=True)
    (bundle / 'Contents/Resources').mkdir(parents=True, exist_ok=True)

common = dict(CFBundleInfoDictionaryVersion='6.0', CFBundleVersion='1',
              CFBundleShortVersionString='0.1.0', LSMinimumSystemVersion='14.0')
plist(APP / 'Contents/Info.plist', dict(common,
    CFBundleIdentifier='local.qingfinder.app', CFBundleName='轻右键',
    CFBundleDisplayName='轻右键', CFBundleExecutable='QingFinder',
    CFBundlePackageType='APPL', NSPrincipalClass='NSApplication',
    NSHighResolutionCapable=True, LSUIElement=True,
    CFBundleURLTypes=[dict(CFBundleURLName='轻右键操作', CFBundleURLSchemes=['liang-finder'])]))
plist(EXT / 'Contents/Info.plist', dict(common,
    CFBundleIdentifier='local.qingfinder.app.extension', CFBundleName='轻右键访达扩展',
    CFBundleDisplayName='轻右键', CFBundleExecutable='QingFinderExtension',
    CFBundlePackageType='XPC!',
    NSExtension=dict(NSExtensionPointIdentifier='com.apple.FinderSync',
                    NSExtensionPrincipalClass='FinderExtension', NSExtensionAttributes={})))
plist(BUILD / 'extension.entitlements', {
    'com.apple.security.app-sandbox': True,
    'com.apple.security.files.user-selected.read-write': True,
})
shutil.copy2(ROOT / 'Sources/App.swift', BUILD / 'main.swift')
compiler = ['xcrun', 'swiftc', '-swift-version', '5', '-O', '-target', 'arm64-apple-macosx14.0',
            '-framework', 'AppKit', '-framework', 'FinderSync']
run(*compiler, ROOT / 'Sources/Core.swift', BUILD / 'main.swift',
    '-o', APP / 'Contents/MacOS/QingFinder')
run(*compiler, '-parse-as-library', '-emit-executable', '-application-extension',
    '-Xlinker', '-e', '-Xlinker', '_NSExtensionMain', '-module-name', 'QingFinderExtension',
    ROOT / 'Sources/Core.swift', ROOT / 'Sources/FinderExtension.swift',
    '-o', EXT / 'Contents/MacOS/QingFinderExtension')
run('codesign', '--force', '--sign', '-', '--entitlements', BUILD / 'extension.entitlements', EXT)
signed = subprocess.run(['codesign', '-d', '--entitlements', '-', '--xml', str(EXT)],
                        capture_output=True, check=True).stdout
assert plistlib.loads(signed).get('com.apple.security.app-sandbox') is True
run('codesign', '--force', '--sign', '-', APP)
run('codesign', '--verify', '--deep', '--strict', '--verbose=2', APP)
archive = BUILD / 'QingFinder-0.1.0-arm64.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as package:
    for path in sorted(APP.rglob('*')):
        if path.is_file():
            package.write(path, str(path.relative_to(BUILD)))
# Keep the original local package name for existing verification scripts.
shutil.copy2(archive, BUILD / '轻右键-0.1.0-arm64.zip')
print(APP)
