import argparse
import logging

logging.getLogger().setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='Calculate versionCode given versionMinor')
parser.add_argument('-v', '--version-minor', default=20040, type=int)
args = parser.parse_args()

version_minor = args.version_minor

yy = version_minor // 1000
mm = (version_minor % 1000) // 10
it = version_minor % 10

total_it = (yy - 19) * 12 * 9 + (mm - 1) * 9 + it - 1
version_code = total_it * 10000

logging.info(version_code)
