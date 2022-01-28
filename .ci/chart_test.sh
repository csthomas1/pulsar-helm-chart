#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e


BINDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PULSAR_HOME="$(cd "${BINDIR}/.." && pwd)"
VALUES_FILE=$1
TLS=${TLS:-"false"}
SYMMETRIC=${SYMMETRIC:-"false"}
FUNCTION=${FUNCTION:-"false"}
MANAGER=${MANAGER:-"false"}

source ${PULSAR_HOME}/.ci/helm.sh

# create cluster
ci::create_cluster

extra_opts=""
if [[ "x${SYMMETRIC}" == "xtrue" ]]; then
    extra_opts="-s"
fi

if [[ "x${EXTRA_SUPERUSERS}" != "x" ]]; then
    extra_opts="${extra_opts} --pulsar-superusers proxy-admin,broker-admin,admin,${EXTRA_SUPERUSERS}"
fi

# install pulsar chart
ci::install_pulsar_chart ${PULSAR_HOME}/${VALUES_FILE}

# test producer
ci::test_pulsar_producer

if [[ "x${FUNCTION}" == "xtrue" ]]; then
    # install cert manager
    ci::test_pulsar_function
fi

if [[ "x${MANAGER}" == "xtrue" ]]; then
    ci:test_pulsar_manager
fi

# delete the cluster
ci::delete_cluster
