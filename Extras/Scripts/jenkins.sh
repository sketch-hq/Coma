#!/usr/bin/env bash

# This script builds and runs the unit tests and produces output in a format that is compatible with Jenkins.

project=Coma

base=`dirname $0`
source "$base/../../Modules/ECLogging/Extras/Scripts/test-common.sh"

macbuild "Tool" test