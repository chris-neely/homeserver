#!/bin/bash

set -ouex pipefail

rsync -rvK /tmp/system_files/ /
