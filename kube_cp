#!/usr/bin/env bash

set -e

ff=$1
pat=${2:-apollon-backend}
di=$(dirname $ff)

function kube {
  kubectl --kubeconfig=$HOME/Downloads/wansong.kubeconfig -n c-dev "$@"
}

pods=$(kube get po | grep -E $pat | awk '{ print $1 }')

for po in $pods ; do
  kube cp "$ff" "${po}:$di"
done
