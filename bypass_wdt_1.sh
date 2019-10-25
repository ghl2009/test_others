#!/bin/bash
./bp_ctl5174 bpon 99 0 0
sleep 10
./bp_ctl5174  wdt 99 1 1 1
usleep 1200000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1250000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1300000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1310000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1380000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1400000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1500000
./bp_ctl5174 rbpon 0 1
./bp_ctl5174  wdt 99 1 1 1
usleep 1800000
./bp_ctl5174 rbpon 0 1