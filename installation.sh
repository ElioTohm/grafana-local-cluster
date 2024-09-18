#!/bin/bash
. $(pwd)/init.sh

./init-cluster.sh

./init-grafana-stack.sh
