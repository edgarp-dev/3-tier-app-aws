#!/bin/bash

jq '{ Parameters: [ .[] |  { (.ParameterKey): .ParameterValue }  ] | add } ' < ./config/${1}.json > deploy.json