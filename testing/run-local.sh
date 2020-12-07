#!/bin/bash
export TEST_API_ENDPOINT=http://localhost:8080
export TEST_STAGE_TIME=10

k6 run loadtest.js
